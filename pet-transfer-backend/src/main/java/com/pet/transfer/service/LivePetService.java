package com.pet.transfer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.pet.transfer.entity.LivePet;

import java.util.List;

public interface LivePetService extends IService<LivePet> {

    List<LivePet> listByStoreId(Long storeId);

    List<LivePet> listAll();

    LivePet getDetail(Long id);
}
