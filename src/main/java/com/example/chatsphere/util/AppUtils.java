package com.example.chatsphere.util;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

public class AppUtils {
    // Utility class for common application methods
    public static HttpHeaders getDefaultHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        // Add auth token if needed
        return headers;
    }
}

