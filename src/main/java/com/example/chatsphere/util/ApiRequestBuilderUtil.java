package com.example.chatsphere.util;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.mappings.EndpointRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;

/**
 * Utility class to build API requests using a builder pattern.
 * This class uses the EndpointRegistry to map logical keys to API endpoints.
 * It provides a method to create an ApiRequest object with the specified key and body.
 * The ApiRequest object includes the path, HTTP method, body, and default headers.
 * * Example usage:
 * * ApiRequestBuilderUtil requestBuilder = new ApiRequestBuilderUtil();
 * * ApiRequest request = requestBuilder.build("auth.login", authDTO);
 * * This will create an ApiRequest with the path "/auth/authenticate", method POST,
 * * and the provided authDTO as the body.
 * * Note: The body object should have getters and setters for serialization.
 * * The headers will include the default Content-Type set to JSON.
 */
@Component
public class ApiRequestBuilderUtil {


    @Autowired
    private EndpointRegistry endpointRegistry;

    public ApiRequest build(String key, Object body) {
        ApiEndpoint endpoint = endpointRegistry.get(key);

        if (endpoint == null) {
            throw new IllegalArgumentException("No endpoint mapping found for key: " + key);
        }
        //builder pattern for ApiRequest
        return ApiRequest.builder()
                .withPath(endpoint.path())
                .withMethod(endpoint.method())
                .withBody(body)// DTO class Make sure body has getters and setters for serialization
                .withHeaders(AppUtils.getDefaultHeaders()); // should set Content-Type to JSON. getDefaultHeaders Our custom headers utility method
    }

    // Helper DTO to represent endpoint info
    public static class ApiEndpoint {
        private final String path;
        private final HttpMethod method;

        public ApiEndpoint(String path, HttpMethod method) {
            this.path = path;
            this.method = method;
        }

        public String path() {
            return path;
        }

        public HttpMethod method() {
            return method;
        }
    }
}
