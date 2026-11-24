package com.farmerassist.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class RootController {

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        return ResponseEntity.ok(Map.of(
                "service", "FarmerAssist Backend API (ನೇಗಿಲು)",
                "status", "ONLINE",
                "version", "1.0.0",
                "webAppUrl", "https://suraj2961.github.io/FarmerAssit/",
                "timestamp", Instant.now().toString(),
                "endpoints", Map.of(
                        "health", "/api/health",
                        "mandiPrices", "/api/mandi-prices?state=Karnataka",
                        "cropAdvisory", "/api/advisory",
                        "weather", "/api/weather?district=Dakshina Kannada",
                        "schemes", "/api/schemes",
                        "news", "/api/news"
                )
        ));
    }
}
