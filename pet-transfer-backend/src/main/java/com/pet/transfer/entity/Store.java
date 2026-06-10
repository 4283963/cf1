package com.pet.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("store")
public class Store {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String address;

    private Integer isWarehouse;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
