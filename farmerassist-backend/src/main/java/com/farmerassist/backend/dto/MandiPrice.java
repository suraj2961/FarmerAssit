package com.farmerassist.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;

/**
 * Mirrors the Flutter MandiPrice model field-for-field so the JSON this
 * API returns can be dropped straight into MandiPrice.fromJson() on the
 * client with zero mapping changes.
 */
public record MandiPrice(
        String state,
        String district,
        String market,
        String commodity,
        String variety,
        String grade,

        @JsonProperty("arrival_date")
        @JsonFormat(pattern = "dd/MM/yyyy")
        LocalDate arrivalDate,

        @JsonProperty("min_price")
        double minPrice,

        @JsonProperty("max_price")
        double maxPrice,

        @JsonProperty("modal_price")
        double modalPrice
) {
}
