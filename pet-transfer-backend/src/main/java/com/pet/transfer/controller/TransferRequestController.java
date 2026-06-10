package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
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

    @PostMapping
    public Result<TransferRequest> create(@RequestBody TransferRequest request) {
        try {
            TransferRequest created = transferRequestService.createTransfer(request);
            return Result.ok(created);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PutMapping("/{id}/approve")
    public Result<TransferRequest> approve(@PathVariable Long id, @RequestBody Map<String, String> body) {
        try {
            String approver = body.getOrDefault("approver", "管理员");
            TransferRequest approved = transferRequestService.approveTransfer(id, approver);
            return Result.ok(approved);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }

    @PutMapping("/{id}/reject")
    public Result<TransferRequest> reject(@PathVariable Long id, @RequestBody Map<String, String> body) {
        try {
            String approver = body.getOrDefault("approver", "管理员");
            TransferRequest rejected = transferRequestService.rejectTransfer(id, approver);
            return Result.ok(rejected);
        } catch (RuntimeException e) {
            return Result.fail(e.getMessage());
        }
    }
}
