package com.pet.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("live_pet")
public class LivePet {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long inventoryId;

    private Long storeId;

    private String name;

    private String species;

    private String breed;

    private String gender;

    private LocalDate birthDate;

    private String healthStatus;

    private LocalDate lastVaccineDate;

    private String vaccineRecords;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
