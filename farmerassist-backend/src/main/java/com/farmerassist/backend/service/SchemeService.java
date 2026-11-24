package com.farmerassist.backend.service;

import com.farmerassist.backend.dto.Scheme;
import com.farmerassist.backend.exception.ExternalApiException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@Service
public class SchemeService {

    private final ObjectMapper objectMapper;
    private List<Scheme> schemes;

    public SchemeService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    public void loadSchemes() {
        try (InputStream is = new ClassPathResource("data/schemes.json").getInputStream()) {
            schemes = objectMapper.readValue(is, objectMapper.getTypeFactory()
                    .constructCollectionType(List.class, Scheme.class));
        } catch (IOException e) {
            throw new ExternalApiException("Failed to load schemes.json at startup: " + e.getMessage(), e);
        }
    }

    public List<Scheme> getAllSchemes() {
        return schemes;
    }

    public List<Scheme> getSchemesByCategory(String category) {
        return schemes.stream()
                .filter(s -> s.category().equalsIgnoreCase(category))
                .toList();
    }

    public List<Scheme> getSchemesByLevel(String level) {
        return schemes.stream()
                .filter(s -> s.level().equalsIgnoreCase(level))
                .toList();
    }

    public Scheme getSchemeById(String id) {
        return schemes.stream()
                .filter(s -> s.id().equalsIgnoreCase(id))
                .findFirst()
                .orElse(null);
    }
}