package com.pet.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.pet.transfer.entity.Store;
import com.pet.transfer.mapper.StoreMapper;
import com.pet.transfer.service.StoreService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StoreServiceImpl extends ServiceImpl<StoreMapper, Store> implements StoreService {

    @Override
    public List<Store> listAll() {
        return list();
    }
}
