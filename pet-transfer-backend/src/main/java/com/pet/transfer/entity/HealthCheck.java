package com.pet.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("health_check")
public class HealthCheck {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long transferId;

    private Long livePetId;

    private String checker;

    private String location;

    private BigDecimal temperature;

    private String mentalStatus;

    private String remark;

    private LocalDateTime checkTime;

    private LocalDateTime createdAt;

    @TableField(exist = false)
    private String petName;

    @TableField(exist = false)
    private String petBreed;

    @TableField(exist = false)
    private String mentalStatusLabel;
}
