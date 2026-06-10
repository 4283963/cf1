package com.pet.transfer.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.pet.transfer.entity.Inventory;
import com.pet.transfer.entity.TransferRequest;
import com.pet.transfer.mapper.InventoryMapper;
import com.pet.transfer.mapper.TransferRequestMapper;
import com.pet.transfer.service.TransferRequestService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReentrantLock;

@Service
public class TransferRequestServiceImpl extends ServiceImpl<TransferRequestMapper, TransferRequest>
        implements TransferRequestService {

    private final InventoryMapper inventoryMapper;

    private final AtomicInteger counter = new AtomicInteger(0);

    private final ConcurrentHashMap<String, ReentrantLock> businessLockMap = new ConcurrentHashMap<>();

    public TransferRequestServiceImpl(InventoryMapper inventoryMapper) {
        this.inventoryMapper = inventoryMapper;
    }

    @Override
    @Transactional
    public TransferRequest createTransfer(TransferRequest request) {
        String businessKey = buildBusinessKey(request);
        ReentrantLock lock = businessLockMap.computeIfAbsent(businessKey, k -> new ReentrantLock());

        try {
            if (!lock.tryLock(0, TimeUnit.SECONDS)) {
                throw new RuntimeException("您提交得太快了，请稍候再试");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断，请重试");
        }

        try {
            checkDuplicateSubmission(request);

            LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Inventory::getStoreId, request.getFromStoreId())
                   .eq(Inventory::getItemName, request.getItemName());
            if (request.getBreed() != null) {
                wrapper.eq(Inventory::getBreed, request.getBreed());
            }
            Inventory fromInventory = inventoryMapper.selectOne(wrapper);

            if (fromInventory == null) {
                throw new RuntimeException("调出方无此库存: " + request.getItemName());
            }
            if (fromInventory.getQuantity() < request.getQuantity()) {
                throw new RuntimeException("调出方库存不足，当前库存: " + fromInventory.getQuantity());
            }

            request.setRequestNo(generateRequestNo());
            request.setStatus("PENDING");
            request.setCreatedAt(LocalDateTime.now());
            request.setUpdatedAt(LocalDateTime.now());
            save(request);

            return request;
        } finally {
            lock.unlock();
            businessLockMap.remove(businessKey, lock);
        }
    }

    @Override
    @Transactional
    public TransferRequest approveTransfer(Long id, String approver) {
        String lockKey = "approve:" + id;
        ReentrantLock lock = businessLockMap.computeIfAbsent(lockKey, k -> new ReentrantLock());

        try {
            if (!lock.tryLock(0, TimeUnit.SECONDS)) {
                throw new RuntimeException("正在处理中，请稍候再试");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断，请重试");
        }

        try {
            TransferRequest request = getById(id);
            if (request == null) {
                throw new RuntimeException("调拨申请不存在");
            }
            if (!"PENDING".equals(request.getStatus())) {
                throw new RuntimeException("当前状态不允许审批: " + request.getStatus());
            }

            LambdaQueryWrapper<Inventory> fromWrapper = new LambdaQueryWrapper<>();
            fromWrapper.eq(Inventory::getStoreId, request.getFromStoreId())
                       .eq(Inventory::getItemName, request.getItemName());
            if (request.getBreed() != null) {
                fromWrapper.eq(Inventory::getBreed, request.getBreed());
            }
            Inventory fromInventory = inventoryMapper.selectOne(fromWrapper);
            if (fromInventory == null || fromInventory.getQuantity() < request.getQuantity()) {
                throw new RuntimeException("调出方库存不足，无法完成审批");
            }

            fromInventory.setQuantity(fromInventory.getQuantity() - request.getQuantity());
            inventoryMapper.updateById(fromInventory);

            LambdaQueryWrapper<Inventory> toWrapper = new LambdaQueryWrapper<>();
            toWrapper.eq(Inventory::getStoreId, request.getToStoreId())
                     .eq(Inventory::getItemName, request.getItemName());
            if (request.getBreed() != null) {
                toWrapper.eq(Inventory::getBreed, request.getBreed());
            }
            Inventory toInventory = inventoryMapper.selectOne(toWrapper);

            if (toInventory != null) {
                toInventory.setQuantity(toInventory.getQuantity() + request.getQuantity());
                inventoryMapper.updateById(toInventory);
            } else {
                Inventory newInventory = new Inventory();
                newInventory.setStoreId(request.getToStoreId());
                newInventory.setItemType(request.getItemType());
                newInventory.setItemName(request.getItemName());
                newInventory.setBreed(request.getBreed());
                newInventory.setQuantity(request.getQuantity());
                newInventory.setUnit("只");
                inventoryMapper.insert(newInventory);
            }

            request.setStatus("APPROVED");
            request.setApprover(approver);
            request.setUpdatedAt(LocalDateTime.now());
            updateById(request);

            return request;
        } finally {
            lock.unlock();
            businessLockMap.remove(lockKey, lock);
        }
    }

    @Override
    @Transactional
    public TransferRequest rejectTransfer(Long id, String approver) {
        String lockKey = "reject:" + id;
        ReentrantLock lock = businessLockMap.computeIfAbsent(lockKey, k -> new ReentrantLock());

        try {
            if (!lock.tryLock(0, TimeUnit.SECONDS)) {
                throw new RuntimeException("正在处理中，请稍候再试");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断，请重试");
        }

        try {
            TransferRequest request = getById(id);
            if (request == null) {
                throw new RuntimeException("调拨申请不存在");
            }
            if (!"PENDING".equals(request.getStatus())) {
                throw new RuntimeException("当前状态不允许操作: " + request.getStatus());
            }

            request.setStatus("REJECTED");
            request.setApprover(approver);
            request.setUpdatedAt(LocalDateTime.now());
            updateById(request);

            return request;
        } finally {
            lock.unlock();
            businessLockMap.remove(lockKey, lock);
        }
    }

    @Override
    public List<TransferRequest> listWithStoreNames() {
        return baseMapper.selectWithStoreNames();
    }

    private String generateRequestNo() {
        String datePart = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int seq = counter.incrementAndGet() % 10000;
        return "TR" + datePart + String.format("%04d", seq);
    }

    private String buildBusinessKey(TransferRequest request) {
        StringBuilder sb = new StringBuilder();
        sb.append(request.getFromStoreId()).append(":")
          .append(request.getToStoreId()).append(":")
          .append(request.getItemType()).append(":")
          .append(request.getItemName()).append(":")
          .append(request.getQuantity()).append(":");
        if (request.getBreed() != null) {
            sb.append(request.getBreed()).append(":");
        }
        if (request.getApplicant() != null) {
            sb.append(request.getApplicant());
        }
        return sb.toString();
    }

    private void checkDuplicateSubmission(TransferRequest request) {
        LocalDateTime fiveSecondsAgo = LocalDateTime.now().minusSeconds(5);
        LambdaQueryWrapper<TransferRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TransferRequest::getFromStoreId, request.getFromStoreId())
               .eq(TransferRequest::getToStoreId, request.getToStoreId())
               .eq(TransferRequest::getItemType, request.getItemType())
               .eq(TransferRequest::getItemName, request.getItemName())
               .eq(TransferRequest::getQuantity, request.getQuantity())
               .ge(TransferRequest::getCreatedAt, fiveSecondsAgo);
        if (request.getBreed() != null) {
            wrapper.eq(TransferRequest::getBreed, request.getBreed());
        }
        if (request.getApplicant() != null) {
            wrapper.eq(TransferRequest::getApplicant, request.getApplicant());
        }
        Long count = baseMapper.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new RuntimeException("相同的调拨申请已在5秒内提交过，请不要重复提交");
        }
    }
}
