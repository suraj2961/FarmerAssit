package com.farmerassist.backend.controller;

import com.farmerassist.backend.dto.MandiPrice;
import com.farmerassist.backend.service.MandiPriceService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Public API consumed by the FarmerAssist Flutter app. All filters are
 * optional - e.g. GET /api/mandi-prices?state=Karnataka&commodity=Tomato
 */
@RestController
@RequestMapping("/api/mandi-prices")
@Validated
public class MandiPriceController {

    private final MandiPriceService mandiPriceService;

    public MandiPriceController(MandiPriceService mandiPriceService) {
        this.mandiPriceService = mandiPriceService;
    }

    @GetMapping
    public List<MandiPrice> getMandiPrices(
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String commodity,
            @RequestParam(defaultValue = "100") @Min(1) @Max(500) int limit,
            @RequestParam(defaultValue = "0") @Min(0) int offset
    ) {
        return mandiPriceService.getMandiPrices(state, district, commodity, limit, offset);
    }
}
