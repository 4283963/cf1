package com.pet.transfer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.pet.transfer.entity.Inventory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InventoryMapper extends BaseMapper<Inventory> {

    @Select("SELECT i.*, s.name AS store_name FROM inventory i LEFT JOIN store s ON i.store_id = s.id")
    List<Inventory> selectWithStoreName();
}
