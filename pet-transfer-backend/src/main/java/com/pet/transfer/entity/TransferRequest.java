package com.pet.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("transfer_request")
public class TransferRequest {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String requestNo;

    private Long fromStoreId;

    private Long toStoreId;

    private String itemType;

    private String itemName;

    private String breed;

    private Integer quantity;

    private String status;

    private String applicant;

    private String approver;

    private String shipper;

    private String driver;

    private LocalDateTime shippedAt;

    private LocalDateTime estimatedArrival;

    private String remark;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String fromStoreName;

    @TableField(exist = false)
    private String toStoreName;
}
