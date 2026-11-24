package com.farmerassist.backend.dto;

public record WeatherInfo(
        String locationName,
        double temperature,
        double feelsLike,
        int humidity,
        double windSpeed,
        String condition,
        String description,
        String icon
) {
}