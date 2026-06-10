USE pet_transfer;

-- 扩展调拨单状态和新增字段
ALTER TABLE transfer_request 
  MODIFY COLUMN status VARCHAR(20) DEFAULT 'PENDING' COMMENT '状态: PENDING待审/APPROVED已批/SHIPPING运输中/COMPLETED已完成/REJECTED已拒',
  ADD COLUMN shipper VARCHAR(100) COMMENT '发货人' AFTER approver,
  ADD COLUMN driver VARCHAR(100) COMMENT '司机姓名' AFTER shipper,
  ADD COLUMN shipped_at DATETIME COMMENT '发货时间' AFTER driver,
  ADD COLUMN estimated_arrival DATETIME COMMENT '预计到达时间' AFTER shipped_at;

-- 扩展活体宠物运输状态
ALTER TABLE live_pet 
  ADD COLUMN transfer_id BIGINT COMMENT '运输中关联的调拨单ID' AFTER store_id,
  ADD COLUMN transport_status VARCHAR(20) DEFAULT 'IN_STORE' COMMENT '运输状态: IN_STORE店内/SHIPPING运输中/ARRIVED已到达' AFTER health_status;

-- 创建健康打卡表
CREATE TABLE IF NOT EXISTS health_check (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transfer_id BIGINT NOT NULL COMMENT '关联调拨单ID',
    live_pet_id BIGINT COMMENT '关联活体宠物ID(可空，整批打卡时为空)',
    checker VARCHAR(100) NOT NULL COMMENT '打卡人(司机)',
    location VARCHAR(200) NOT NULL COMMENT '打卡地点(服务区)',
    temperature DECIMAL(4,1) COMMENT '体温(℃)',
    mental_status VARCHAR(20) NOT NULL COMMENT '精神状态: GOOD好/NORMAL一般/POOR差',
    remark VARCHAR(500) COMMENT '备注',
    check_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '打卡时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_live_pet_id (live_pet_id)
) COMMENT='健康打卡表';

-- 初始化现有活体宠物的运输状态
UPDATE live_pet SET transport_status = 'IN_STORE' WHERE transport_status IS NULL;
