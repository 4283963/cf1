package com.pet.transfer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.pet.transfer.entity.LivePet;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LivePetMapper extends BaseMapper<LivePet> {
}
