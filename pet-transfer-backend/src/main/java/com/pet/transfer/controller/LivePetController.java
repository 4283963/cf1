package com.pet.transfer.controller;

import com.pet.transfer.common.Result;
import com.pet.transfer.entity.LivePet;
import com.pet.transfer.service.LivePetService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pets")
public class LivePetController {

    private final LivePetService livePetService;

    public LivePetController(LivePetService livePetService) {
        this.livePetService = livePetService;
    }

    @GetMapping
    public Result<List<LivePet>> list(@RequestParam(required = false) Long storeId) {
        if (storeId != null) {
            return Result.ok(livePetService.listByStoreId(storeId));
        }
        return Result.ok(livePetService.listAll());
    }

    @GetMapping("/{id}")
    public Result<LivePet> getDetail(@PathVariable Long id) {
        return Result.ok(livePetService.getDetail(id));
    }
}
