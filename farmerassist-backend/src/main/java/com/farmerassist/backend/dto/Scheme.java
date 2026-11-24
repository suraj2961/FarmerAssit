package com.farmerassist.backend.dto;

import java.util.List;

public record Scheme(
        String id,
        String name,
        String category,
        String level,
        String description,
        List<String> eligibility,
        List<String> benefits,
        String applicationLink,
        String applicationProcess
) {
}