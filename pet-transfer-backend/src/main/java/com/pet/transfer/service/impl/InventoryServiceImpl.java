package com.pet.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.pet.transfer.entity.Inventory;
import com.pet.transfer.mapper.InventoryMapper;
import com.pet.transfer.service.InventoryService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InventoryServiceImpl extends ServiceImpl<InventoryMapper, Inventory> implements InventoryService {

    @Override
    public List<Inventory> listWithStoreName() {
        return baseMapper.selectWithStoreName();
    }

    @Override
    public List<Inventory> listByStoreId(Long storeId) {
        return lambdaQuery().eq(Inventory::getStoreId, storeId).list();
    }
}
