package com.farmerassist.backend.dto;

import java.util.List;

public record SellAdvisory(
        String commodity,
        String market,
        String district,
        String state,
        double currentPrice,
        double earliestPrice,
        double changeAmount,
        double changePercent,
        String trend,
        String recommendation,
        String recommendationKannada,
        String actionVerdict,
        int confidenceScore,
        String perishabilityGrade,
        double predictedPrice7Days,
        double predictedPrice14Days,
        double expectedNetHoldingBenefit,
        double volatilityPercent,
        int historicalPercentile,
        List<MarketSignal> keySignals,
        List<MandiComparison> nearbyMandis,
        List<PricePoint> priceHistory,
        List<ForecastPoint> forecastHistory
) {
    public record PricePoint(String date, double modalPrice) {
    }

    public record ForecastPoint(String date, double expectedPrice, double lowerBound, double upperBound) {
    }

    public record MarketSignal(String type, String title, String description, boolean isPositive) {
    }

    public record MandiComparison(String market, String district, double price, double difference) {
    }

    /**
     * Backward-compatible constructor for minimal responses.
     */
    public SellAdvisory(
            String commodity,
            String market,
            double currentPrice,
            double earliestPrice,
            double changeAmount,
            double changePercent,
            String trend,
            String recommendation,
            List<PricePoint> priceHistory
    ) {
        this(
                commodity,
                market,
                "",
                "Karnataka",
                currentPrice,
                earliestPrice,
                changeAmount,
                changePercent,
                trend,
                recommendation,
                "",
                trend.equals("RISING") ? "HOLD_AND_WAIT" : (trend.equals("FALLING") ? "SELL_NOW" : "MONITOR"),
                70,
                "SEMI_PERISHABLE",
                currentPrice,
                currentPrice,
                0.0,
                5.0,
                50,
                List.of(),
                List.of(),
                priceHistory,
                List.of()
        );
    }
}