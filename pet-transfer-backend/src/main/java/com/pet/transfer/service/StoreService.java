package com.pet.transfer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.pet.transfer.entity.Store;

import java.util.List;

public interface StoreService extends IService<Store> {

    List<Store> listAll();
}
