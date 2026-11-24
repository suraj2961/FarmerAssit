package com.farmerassist.backend.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record OpenWeatherResponse(
        String name,
        Main main,
        List<Weather> weather,
        Wind wind
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Main(
            double temp,
            double feels_like,
            int humidity
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Weather(
            String main,
            String description,
            String icon
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Wind(
            double speed
    ) {
    }
}