CREATE DATABASE IF NOT EXISTS pet_transfer DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE pet_transfer;

DROP TABLE IF EXISTS transfer_request;
DROP TABLE IF EXISTS live_pet;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS store;

CREATE TABLE store (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '分店名称',
    address VARCHAR(255) COMMENT '分店地址',
    is_warehouse TINYINT(1) DEFAULT 0 COMMENT '是否为总仓(1是0否)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='分店/仓库表';

CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL COMMENT '所属分店ID',
    item_type VARCHAR(50) NOT NULL COMMENT '类型: SUPPLY用品 / LIVE活体',
    item_name VARCHAR(100) NOT NULL COMMENT '品名',
    breed VARCHAR(100) COMMENT '品种(活体专用)',
    quantity INT NOT NULL DEFAULT 0 COMMENT '数量',
    unit VARCHAR(20) DEFAULT '只' COMMENT '单位',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='库存表';

CREATE TABLE live_pet (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_id BIGINT COMMENT '关联库存ID',
    store_id BIGINT NOT NULL COMMENT '当前所在分店',
    name VARCHAR(100) COMMENT '宠物昵称',
    species VARCHAR(50) NOT NULL COMMENT '物种: 猫/狗',
    breed VARCHAR(100) NOT NULL COMMENT '品种',
    gender VARCHAR(10) COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    health_status VARCHAR(50) DEFAULT '健康' COMMENT '健康状态',
    last_vaccine_date DATE COMMENT '最近接种日期',
    vaccine_records TEXT COMMENT '疫苗接种记录(JSON)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='活体宠物表';

CREATE TABLE transfer_request (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_no VARCHAR(64) NOT NULL UNIQUE COMMENT '调拨单号',
    from_store_id BIGINT NOT NULL COMMENT '调出分店ID',
    to_store_id BIGINT NOT NULL COMMENT '调入分店ID',
    item_type VARCHAR(50) NOT NULL COMMENT '类型: SUPPLY/LIVE',
    item_name VARCHAR(100) NOT NULL COMMENT '品名',
    breed VARCHAR(100) COMMENT '品种',
    quantity INT NOT NULL COMMENT '数量',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '状态: PENDING待审/APPROVED已批/REJECTED已拒/COMPLETED已完成',
    applicant VARCHAR(100) COMMENT '申请人',
    approver VARCHAR(100) COMMENT '审批人',
    remark VARCHAR(500) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='调拨申请表';

INSERT INTO store (name, address, is_warehouse) VALUES
('总仓库', '高新区天府大道总部', 1),
('高新分店', '高新区益州大道88号', 0),
('锦江分店', '锦江区春熙路166号', 0),
('武侯分店', '武侯区桐梓林路22号', 0);

INSERT INTO inventory (store_id, item_type, item_name, breed, quantity, unit) VALUES
(1, 'LIVE', '英国短毛猫', '英国短毛猫', 20, '只'),
(1, 'LIVE', '金毛寻回犬', '金毛寻回犬', 15, '只'),
(1, 'SUPPLY', '皇家猫粮K36', NULL, 200, '袋'),
(2, 'LIVE', '英国短毛猫', '英国短毛猫', 3, '只'),
(2, 'SUPPLY', '皇家猫粮K36', NULL, 30, '袋'),
(3, 'LIVE', '布偶猫', '布偶猫', 5, '只'),
(4, 'SUPPLY', '驱虫药', NULL, 100, '盒');

INSERT INTO live_pet (inventory_id, store_id, name, species, breed, gender, birth_date, health_status, last_vaccine_date, vaccine_records) VALUES
(1, 1, '小蓝', '猫', '英国短毛猫', '公', '2025-01-15', '健康', '2025-05-10', '[{"name":"猫三联","date":"2025-05-10"},{"name":"狂犬疫苗","date":"2025-05-10"}]'),
(1, 1, '小灰', '猫', '英国短毛猫', '母', '2025-02-20', '健康', '2025-06-01', '[{"name":"猫三联","date":"2025-06-01"}]'),
(1, 1, '团团', '猫', '英国短毛猫', '公', '2025-03-10', '健康', '2025-06-15', '[{"name":"猫三联","date":"2025-06-15"}]'),
(2, 1, '旺财', '狗', '金毛寻回犬', '公', '2024-12-01', '健康', '2025-04-20', '[{"name":"犬八联","date":"2025-04-20"},{"name":"狂犬疫苗","date":"2025-04-20"}]'),
(4, 2, '豆豆', '猫', '英国短毛猫', '母', '2025-04-05', '健康', '2025-08-01', '[{"name":"猫三联","date":"2025-08-01"}]');
