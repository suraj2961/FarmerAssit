package com.farmerassist.backend.service;

import com.farmerassist.backend.client.AgmarknetClient;
import com.farmerassist.backend.dto.MandiPrice;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Sits between the controller and the Agmarknet client. Adds caching so
 * repeated requests for the same filters (e.g. many farmers checking
 * "Tomato prices in Kolar" on the same day) don't each hit data.gov.in -
 * mandi prices only update once a day anyway.
 */
@Service
public class MandiPriceService {

    private final AgmarknetClient agmarknetClient;

    public MandiPriceService(AgmarknetClient agmarknetClient) {
        this.agmarknetClient = agmarknetClient;
    }

    /**
     * Cache key is built from all filter params so different filter
     * combinations don't collide. Defaults state to Karnataka to prevent
     * arbitrary nationwide results when no state is specified.
     */
    @Cacheable(value = "mandiPrices", key = "T(String).format('%s|%s|%s|%d|%d', #state, #district, #commodity, #limit, #offset)")
    public List<MandiPrice> getMandiPrices(String state, String district, String commodity, int limit, int offset) {
        String queryState = (state == null || state.isBlank()) ? "Karnataka" : state;
        return agmarknetClient.fetchPrices(queryState, district, commodity, limit, offset);
    }
}
