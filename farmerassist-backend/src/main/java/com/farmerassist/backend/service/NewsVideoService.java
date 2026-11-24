package com.farmerassist.backend.service;

import com.farmerassist.backend.client.YouTubeClient;
import com.farmerassist.backend.dto.NewsVideo;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NewsVideoService {

    private static final String DEFAULT_QUERY = "ಕೃಷಿ ಸುದ್ದಿ ಕರ್ನಾಟಕ ರೈತ";
    private static final int DEFAULT_MAX_RESULTS = 15;

    private final YouTubeClient youTubeClient;

    public NewsVideoService(YouTubeClient youTubeClient) {
        this.youTubeClient = youTubeClient;
    }

    @Cacheable(value = "newsVideos", key = "'default'")
    public List<NewsVideo> getLatestFarmingNews() {
        return youTubeClient.searchVideos(DEFAULT_QUERY, DEFAULT_MAX_RESULTS);
    }

    @Cacheable(value = "newsVideosByQuery", key = "#query")
    public List<NewsVideo> searchFarmingNews(String query) {
        String scopedQuery = query + " ಕೃಷಿ ಕರ್ನಾಟಕ";
        return youTubeClient.searchVideos(scopedQuery, DEFAULT_MAX_RESULTS);
    }
}