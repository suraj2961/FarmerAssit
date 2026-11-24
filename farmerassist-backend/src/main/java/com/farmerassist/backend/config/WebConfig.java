package com.farmerassist.backend.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .maxAge(3600);
    }

    /**
     * Security Headers Filter: protects against clickjacking, MIME-sniffing, XSS, and information leakage.
     */
    @Bean
    public FilterRegistrationBean<Filter> securityHeadersAndRateLimitFilter() {
        Filter filter = new Filter() {
            private final Map<String, RequestCounter> requestCounts = new ConcurrentHashMap<>();
            private static final int MAX_REQUESTS_PER_MINUTE = 300;

            @Override
            public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
                    throws IOException, ServletException {
                HttpServletRequest request = (HttpServletRequest) req;
                HttpServletResponse response = (HttpServletResponse) res;

                // Add vital HTTP Security Headers
                response.setHeader("X-Content-Type-Options", "nosniff");
                response.setHeader("X-Frame-Options", "SAMEORIGIN");
                response.setHeader("X-XSS-Protection", "1; mode=block");
                response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
                response.setHeader("Permissions-Policy", "geolocation=(self), camera=(), microphone=()");
                response.setHeader("Cache-Control", "public, max-age=60");

                // Lightweight Rate-limiting per client IP to safeguard backend availability
                String clientIp = request.getHeader("X-Forwarded-For");
                if (clientIp == null || clientIp.isBlank()) {
                    clientIp = request.getRemoteAddr();
                } else if (clientIp.contains(",")) {
                    clientIp = clientIp.split(",")[0].trim();
                }

                long currentMinute = System.currentTimeMillis() / 60000;
                RequestCounter counter = requestCounts.compute(clientIp, (ip, c) -> {
                    if (c == null || c.minute != currentMinute) {
                        return new RequestCounter(currentMinute, new AtomicInteger(1));
                    }
                    c.count.incrementAndGet();
                    return c;
                });

                if (counter.count.get() > MAX_REQUESTS_PER_MINUTE) {
                    response.setStatus(429);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"error\":\"Too Many Requests\",\"message\":\"Rate limit exceeded. Please wait a moment.\"}");
                    return;
                }

                // Periodic cleanup of stale rate limits
                if (requestCounts.size() > 5000) {
                    requestCounts.entrySet().removeIf(e -> e.getValue().minute < currentMinute);
                }

                chain.doFilter(req, res);
            }
        };

        FilterRegistrationBean<Filter> registration = new FilterRegistrationBean<>(filter);
        registration.addUrlPatterns("/api/*");
        registration.setOrder(1);
        return registration;
    }

    private static class RequestCounter {
        final long minute;
        final AtomicInteger count;

        RequestCounter(long minute, AtomicInteger count) {
            this.minute = minute;
            this.count = count;
        }
    }
}