package com.farmerassist.backend.controller;

import com.farmerassist.backend.dto.SellAdvisory;
import com.farmerassist.backend.service.CropAdvisoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/crop-advisory")
public class CropAdvisoryController {

    private final CropAdvisoryService cropAdvisoryService;

    public CropAdvisoryController(CropAdvisoryService cropAdvisoryService) {
        this.cropAdvisoryService = cropAdvisoryService;
    }

    @GetMapping
    public SellAdvisory getSellAdvisory(
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String district,
            @RequestParam String commodity,
            @RequestParam(required = false) String market
    ) {
        return cropAdvisoryService.getSellAdvisory(state, district, commodity, market);
    }
}