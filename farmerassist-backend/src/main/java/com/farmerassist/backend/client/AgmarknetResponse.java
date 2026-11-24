package com.farmerassist.backend.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * Raw shape of the data.gov.in resource API response. The government API
 * returns prices/dates as strings with inconsistent formatting, so this
 * is kept separate from the clean MandiPrice DTO we expose to clients -
 * AgmarknetClient is responsible for converting between the two.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record AgmarknetResponse(
        List<Record> records
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Record(
            String state,
            String district,
            String market,
            String commodity,
            String variety,
            String grade,
            String arrival_date,
            String min_price,
            String max_price,
            String modal_price
    ) {
    }
}
