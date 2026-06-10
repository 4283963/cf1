package com.pet.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("inventory")
public class Inventory {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long storeId;

    private String itemType;

    private String itemName;

    private String breed;

    private Integer quantity;

    private String unit;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String storeName;
}
