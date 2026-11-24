package com.farmerassist.backend.client;

import com.farmerassist.backend.dto.WeatherInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Map;

import org.springframework.http.client.SimpleClientHttpRequestFactory;
import java.time.Duration;

@Component
public class WeatherClient {

    private static final Logger log = LoggerFactory.getLogger(WeatherClient.class);

    private final RestClient restClient;
    private final String apiKey;

    public WeatherClient(
            RestClient.Builder restClientBuilder,
            @Value("${openweather.api.base-url}") String baseUrl,
            @Value("${openweather.api.key}") String apiKey
    ) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout((int) Duration.ofMillis(2500).toMillis());
        factory.setReadTimeout((int) Duration.ofMillis(3500).toMillis());

        this.restClient = restClientBuilder
                .requestFactory(factory)
                .baseUrl(baseUrl)
                .build();
        this.apiKey = apiKey;
    }

    public WeatherInfo getCurrentWeather(double lat, double lon) {
        if (apiKey == null || apiKey.isBlank() || apiKey.contains("YOUR_")) {
            return getFallbackWeather("Karnataka,IN");
        }

        try {
            OpenWeatherResponse response = restClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/data/2.5/weather")
                            .queryParam("lat", lat)
                            .queryParam("lon", lon)
                            .queryParam("appid", apiKey)
                            .queryParam("units", "metric")
                            .build())
                    .retrieve()
                    .body(OpenWeatherResponse.class);

            if (response != null) {
                return toWeatherInfo(response);
            }
        } catch (Exception e) {
            log.warn("OpenWeatherMap coordinate request failed ({}); serving fallback weather", e.getMessage());
        }
        return getFallbackWeather("Karnataka,IN");
    }

    public WeatherInfo getCurrentWeatherByCity(String city) {
        if (apiKey == null || apiKey.isBlank() || apiKey.contains("YOUR_")) {
            return getFallbackWeather(city);
        }

        String queryCity = city;
        if (!queryCity.contains(",")) {
            queryCity = queryCity + ",IN";
        }

        try {
            final String finalQueryCity = queryCity;
            OpenWeatherResponse response = restClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/data/2.5/weather")
                            .queryParam("q", finalQueryCity)
                            .queryParam("appid", apiKey)
                            .queryParam("units", "metric")
                            .build())
                    .retrieve()
                    .body(OpenWeatherResponse.class);

            if (response != null) {
                return toWeatherInfo(response);
            }
        } catch (Exception e) {
            log.warn("OpenWeatherMap city request failed for '{}' ({}); serving fallback weather", city, e.getMessage());
        }
        return getFallbackWeather(city);
    }

    private WeatherInfo toWeatherInfo(OpenWeatherResponse response) {
        OpenWeatherResponse.Weather condition = response.weather() != null && !response.weather().isEmpty()
                ? response.weather().get(0)
                : new OpenWeatherResponse.Weather("Sunny", "Clear skies", "01d");

        return new WeatherInfo(
                response.name() != null ? response.name() : "Karnataka",
                response.main() != null ? response.main().temp() : 28.0,
                response.main() != null ? response.main().feels_like() : 30.0,
                response.main() != null ? response.main().humidity() : 65,
                response.wind() != null ? response.wind().speed() : 3.5,
                condition.main() != null ? condition.main() : "Sunny",
                condition.description() != null ? condition.description() : "Clear skies",
                condition.icon() != null ? condition.icon() : "01d"
        );
    }

    private WeatherInfo getFallbackWeather(String city) {
        String cleanCity = city.replace(",IN", "").trim();
        Map<String, WeatherInfo> defaults = Map.of(
                "Mangalore", new WeatherInfo("Mangalore", 29.5, 33.2, 78, 4.2, "Rain", "Moderate coastal showers", "10d"),
                "Bengaluru", new WeatherInfo("Bengaluru", 26.2, 27.0, 58, 3.1, "Clouds", "Partly cloudy with mild breeze", "03d"),
                "Bangalore", new WeatherInfo("Bangalore", 26.2, 27.0, 58, 3.1, "Clouds", "Partly cloudy with mild breeze", "03d"),
                "Mysuru", new WeatherInfo("Mysuru", 27.8, 29.5, 62, 2.8, "Clear", "Pleasant and sunny", "01d"),
                "Hubballi", new WeatherInfo("Hubballi", 30.1, 32.4, 52, 3.9, "Clear", "Warm and sunny", "01d"),
                "Belagavi", new WeatherInfo("Belagavi", 27.4, 28.6, 68, 3.4, "Clouds", "Scattered clouds", "02d"),
                "Shivamogga", new WeatherInfo("Shivamogga", 28.0, 30.5, 74, 2.5, "Rain", "Light drizzle", "10d"),
                "Hassan", new WeatherInfo("Hassan", 25.8, 26.9, 70, 3.0, "Clouds", "Overcast skies", "04d"),
                "Kolar", new WeatherInfo("Kolar", 28.4, 29.8, 54, 3.8, "Clear", "Clear sunny skies", "01d")
        );

        for (Map.Entry<String, WeatherInfo> entry : defaults.entrySet()) {
            if (cleanCity.toLowerCase().contains(entry.getKey().toLowerCase())) {
                return entry.getValue();
            }
        }

        return new WeatherInfo(cleanCity.isEmpty() ? "Karnataka" : cleanCity, 28.0, 29.5, 64, 3.2, "Clouds", "Scattered clouds with mild sun", "02d");
    }
}