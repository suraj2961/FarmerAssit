package com.farmerassist.backend.controller;

import com.farmerassist.backend.dto.WeatherInfo;
import com.farmerassist.backend.service.WeatherService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping
    public WeatherInfo getCurrentWeather(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon,
            @RequestParam(required = false) String city
    ) {
        if (city != null && !city.isBlank()) {
            return weatherService.getCurrentWeatherByCity(city);
        }
        if (lat != null && lon != null) {
            return weatherService.getCurrentWeather(lat, lon);
        }
        throw new IllegalArgumentException("Provide either 'city' or both 'lat' and 'lon'");
    }
}