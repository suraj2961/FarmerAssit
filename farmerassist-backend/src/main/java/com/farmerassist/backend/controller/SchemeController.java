package com.farmerassist.backend.controller;

import com.farmerassist.backend.dto.Scheme;
import com.farmerassist.backend.service.SchemeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/schemes")
public class SchemeController {

    private final SchemeService schemeService;

    public SchemeController(SchemeService schemeService) {
        this.schemeService = schemeService;
    }

    @GetMapping
    public List<Scheme> getSchemes(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String level
    ) {
        if (category != null && !category.isBlank()) {
            return schemeService.getSchemesByCategory(category);
        }
        if (level != null && !level.isBlank()) {
            return schemeService.getSchemesByLevel(level);
        }
        return schemeService.getAllSchemes();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Scheme> getSchemeById(@PathVariable String id) {
        Scheme scheme = schemeService.getSchemeById(id);
        if (scheme == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(scheme);
    }
}