package com.pet.transfer.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.pet.transfer.entity.LivePet;
import com.pet.transfer.mapper.LivePetMapper;
import com.pet.transfer.service.LivePetService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LivePetServiceImpl extends ServiceImpl<LivePetMapper, LivePet> implements LivePetService {

    @Override
    public List<LivePet> listByStoreId(Long storeId) {
        return lambdaQuery().eq(LivePet::getStoreId, storeId).list();
    }

    @Override
    public List<LivePet> listAll() {
        return list();
    }

    @Override
    public LivePet getDetail(Long id) {
        return getById(id);
    }
}
