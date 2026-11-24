package com.farmerassist.backend.dto;

public record NewsVideo(
        String videoId,
        String title,
        String description,
        String channelTitle,
        String thumbnailUrl,
        String publishedAt,
        String videoUrl
) {
}