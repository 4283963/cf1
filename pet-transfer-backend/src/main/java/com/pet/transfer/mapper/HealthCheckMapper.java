package com.pet.transfer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.pet.transfer.entity.HealthCheck;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface HealthCheckMapper extends BaseMapper<HealthCheck> {

    @Select("SELECT h.*, p.name AS pet_name, p.breed AS pet_breed " +
            "FROM health_check h LEFT JOIN live_pet p ON h.live_pet_id = p.id " +
            "WHERE h.transfer_id = #{transferId} ORDER BY h.check_time DESC")
    List<HealthCheck> selectByTransferIdWithPetInfo(@Param("transferId") Long transferId);

    @Select("SELECT h.*, p.name AS pet_name, p.breed AS pet_breed " +
            "FROM health_check h LEFT JOIN live_pet p ON h.live_pet_id = p.id " +
            "WHERE h.live_pet_id = #{livePetId} ORDER BY h.check_time DESC")
    List<HealthCheck> selectByLivePetIdWithPetInfo(@Param("livePetId") Long livePetId);
}
