package com.pet.transfer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.pet.transfer.entity.Inventory;

import java.util.List;

public interface InventoryService extends IService<Inventory> {

    List<Inventory> listWithStoreName();

    List<Inventory> listByStoreId(Long storeId);
}
