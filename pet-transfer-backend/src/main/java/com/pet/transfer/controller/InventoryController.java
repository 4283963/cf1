package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
import com.pet.transfer.entity.Inventory;
import com.pet.transfer.service.InventoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventories")
public class InventoryController {

    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping
    public Result<List<Inventory>> list(@RequestParam(required = false) Long storeId) {
        if (storeId != null) {
            return Result.ok(inventoryService.listByStoreId(storeId));
        }
        return Result.ok(inventoryService.listWithStoreName());
    }
}
