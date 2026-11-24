package com.farmerassist.backend.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;
import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown = true)
public record YouTubeSearchResponse(
        List<Item> items
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Item(
            Id id,
            Snippet snippet
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Id(
            String videoId
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Snippet(
            String title,
            String description,
            String channelTitle,
            String publishedAt,
            Map<String, Thumbnail> thumbnails
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Thumbnail(
            String url
    ) {
    }
}