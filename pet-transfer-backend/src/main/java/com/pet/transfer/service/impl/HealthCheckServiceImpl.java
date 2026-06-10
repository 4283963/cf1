package com.pet.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.pet.transfer.entity.HealthCheck;
import com.pet.transfer.entity.TransferRequest;
import com.pet.transfer.mapper.HealthCheckMapper;
import com.pet.transfer.service.HealthCheckService;
import com.pet.transfer.service.TransferRequestService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class HealthCheckServiceImpl extends ServiceImpl<HealthCheckMapper, HealthCheck>
        implements HealthCheckService {

    private final TransferRequestService transferRequestService;

    public HealthCheckServiceImpl(TransferRequestService transferRequestService) {
        this.transferRequestService = transferRequestService;
    }

    @Override
    @Transactional
    public HealthCheck addCheck(HealthCheck check) {
        TransferRequest transfer = transferRequestService.getById(check.getTransferId());
        if (transfer == null) {
            throw new RuntimeException("调拨单不存在");
        }
        if (!"SHIPPING".equals(transfer.getStatus())) {
            throw new RuntimeException("当前调拨单状态不允许打卡，状态: " + transfer.getStatus());
        }
        if (check.getCheckTime() == null) {
            check.setCheckTime(LocalDateTime.now());
        }
        check.setCreatedAt(LocalDateTime.now());
        save(check);
        return check;
    }

    @Override
    public List<HealthCheck> listByTransferId(Long transferId) {
        List<HealthCheck> list = baseMapper.selectByTransferIdWithPetInfo(transferId);
        list.forEach(this::enrichMentalStatusLabel);
        return list;
    }

    @Override
    public List<HealthCheck> listByLivePetId(Long livePetId) {
        List<HealthCheck> list = baseMapper.selectByLivePetIdWithPetInfo(livePetId);
        list.forEach(this::enrichMentalStatusLabel);
        return list;
    }

    private void enrichMentalStatusLabel(HealthCheck check) {
        switch (check.getMentalStatus()) {
            case "GOOD":
                check.setMentalStatusLabel("好 😊");
                break;
            case "NORMAL":
                check.setMentalStatusLabel("一般 😐");
                break;
            case "POOR":
                check.setMentalStatusLabel("差 😟");
                break;
            default:
                check.setMentalStatusLabel(check.getMentalStatus());
        }
    }
}
