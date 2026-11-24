package com.farmerassist.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.ManagementFactory;
import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    private final long startTime = System.currentTimeMillis();

    @GetMapping
    public ResponseEntity<Map<String, Object>> checkHealth() {
        long uptimeSeconds = (System.currentTimeMillis() - startTime) / 1000;
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "farmerassist-backend",
                "timestamp", Instant.now().toString(),
                "uptimeSeconds", uptimeSeconds,
                "jvmUptimeMs", ManagementFactory.getRuntimeMXBean().getUptime()
        ));
    }
}
