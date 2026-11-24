package com.farmerassist.backend.service;

import com.farmerassist.backend.client.WeatherClient;
import com.farmerassist.backend.dto.WeatherInfo;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class WeatherService {

    private final WeatherClient weatherClient;

    public WeatherService(WeatherClient weatherClient) {
        this.weatherClient = weatherClient;
    }

    @Cacheable(value = "weatherByCoords", key = "T(String).format('%.2f,%.2f', #lat, #lon)")
    public WeatherInfo getCurrentWeather(double lat, double lon) {
        return weatherClient.getCurrentWeather(lat, lon);
    }

    @Cacheable(value = "weatherByCity", key = "#city")
    public WeatherInfo getCurrentWeatherByCity(String city) {
        return weatherClient.getCurrentWeatherByCity(city);
    }
}