package com.pet.transfer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.pet.transfer.entity.TransferRequest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface TransferRequestMapper extends BaseMapper<TransferRequest> {

    @Select("SELECT t.*, s1.name AS from_store_name, s2.name AS to_store_name " +
            "FROM transfer_request t " +
            "LEFT JOIN store s1 ON t.from_store_id = s1.id " +
            "LEFT JOIN store s2 ON t.to_store_id = s2.id " +
            "ORDER BY t.created_at DESC")
    List<TransferRequest> selectWithStoreNames();
}
