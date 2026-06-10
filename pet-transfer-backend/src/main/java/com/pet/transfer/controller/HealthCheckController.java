package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
import com.pet.transfer.entity.HealthCheck;
import com.pet.transfer.service.HealthCheckService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/health-checks")
public class HealthCheckController {

    private final HealthCheckService healthCheckService;

    public HealthCheckController(HealthCheckService healthCheckService) {
        this.healthCheckService = healthCheckService;
    }

    @PostMapping
    public Result<HealthCheck> add(@RequestBody HealthCheck check) {
        HealthCheck created = healthCheckService.addCheck(check);
        return Result.ok(created);
    }

    @GetMapping("/transfer/{transferId}")
    public Result<List<HealthCheck>> listByTransfer(@PathVariable Long transferId) {
        return Result.ok(healthCheckService.listByTransferId(transferId));
    }

    @GetMapping("/pet/{livePetId}")
    public Result<List<HealthCheck>> listByPet(@PathVariable Long livePetId) {
        return Result.ok(healthCheckService.listByLivePetId(livePetId));
    }
}
