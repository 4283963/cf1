package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
import com.pet.transfer.entity.LivePet;
import com.pet.transfer.entity.TransferRequest;
import com.pet.transfer.service.TransferRequestService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/transfers")
public class TransferRequestController {

    private final TransferRequestService transferRequestService;

    public TransferRequestController(TransferRequestService transferRequestService) {
        this.transferRequestService = transferRequestService;
    }

    @GetMapping
    public Result<List<TransferRequest>> list() {
        return Result.ok(transferRequestService.listWithStoreNames());
    }

    @GetMapping("/shipping")
    public Result<List<TransferRequest>> listShipping() {
        return Result.ok(transferRequestService.listShipping());
    }

    @GetMapping("/{id}/pets")
    public Result<List<LivePet>> listPets(@PathVariable Long id) {
        return Result.ok(transferRequestService.listPetsInTransfer(id));
    }

    @PostMapping
    public Result<TransferRequest> create(@RequestBody TransferRequest request) {
        TransferRequest created = transferRequestService.createTransfer(request);
        return Result.ok(created);
    }

    @PutMapping("/{id}/approve")
    public Result<TransferRequest> approve(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String approver = body.getOrDefault("approver", "管理员");
        TransferRequest approved = transferRequestService.approveTransfer(id, approver);
        return Result.ok(approved);
    }

    @PutMapping("/{id}/reject")
    public Result<TransferRequest> reject(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String approver = body.getOrDefault("approver", "管理员");
        TransferRequest rejected = transferRequestService.rejectTransfer(id, approver);
        return Result.ok(rejected);
    }

    @PutMapping("/{id}/ship")
    public Result<TransferRequest> ship(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String shipper = (String) body.getOrDefault("shipper", "管理员");
        String driver = (String) body.getOrDefault("driver", "司机");
        int estimatedHours = body.get("estimatedHours") != null ?
                ((Number) body.get("estimatedHours")).intValue() : 0;
        TransferRequest shipped = transferRequestService.shipTransfer(id, shipper, driver, estimatedHours);
        return Result.ok(shipped);
    }

    @PutMapping("/{id}/complete")
    public Result<TransferRequest> complete(@PathVariable Long id) {
        TransferRequest completed = transferRequestService.completeTransfer(id);
        return Result.ok(completed);
    }
}
