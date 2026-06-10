package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
import com.pet.transfer.entity.Store;
import com.pet.transfer.service.StoreService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/stores")
public class StoreController {

    private final StoreService storeService;

    public StoreController(StoreService storeService) {
        this.storeService = storeService;
    }

    @GetMapping
    public Result<List<Store>> list() {
        return Result.ok(storeService.listAll());
    }
}
