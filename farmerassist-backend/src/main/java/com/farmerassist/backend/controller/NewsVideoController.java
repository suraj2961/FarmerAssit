package com.farmerassist.backend.controller;

import com.farmerassist.backend.dto.NewsVideo;
import com.farmerassist.backend.service.NewsVideoService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/news")
public class NewsVideoController {

    private final NewsVideoService newsVideoService;

    public NewsVideoController(NewsVideoService newsVideoService) {
        this.newsVideoService = newsVideoService;
    }

    @GetMapping
    public List<NewsVideo> getNews(@RequestParam(required = false) String query) {
        if (query != null && !query.isBlank()) {
            return newsVideoService.searchFarmingNews(query);
        }
        return newsVideoService.getLatestFarmingNews();
    }
}