package com.pet.transfer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.pet.transfer.entity.HealthCheck;

import java.util.List;

public interface HealthCheckService extends IService<HealthCheck> {

    HealthCheck addCheck(HealthCheck check);

    List<HealthCheck> listByTransferId(Long transferId);

    List<HealthCheck> listByLivePetId(Long livePetId);
}
