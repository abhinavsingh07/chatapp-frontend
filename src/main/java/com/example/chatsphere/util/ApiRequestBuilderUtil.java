package com.example.chatsphere.util;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.mappings.EndpointRegistry;
import com.example.chatsphere.security.JwtResponse;
import com.example.chatsphere.service.TokenStoreService;
import com.example.chatsphere.service.impl.LoginServiceImpl;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Utility class to build API requests using a builder pattern.
 * This class uses the EndpointRegistry to map logical keys to API endpoints.
 * It provides a method to create an ApiRequest object with the specified key
 * and body.
 * The ApiRequest object includes the path, HTTP method, body, and default
 * headers.
 * * Example usage:
 * * ApiRequestBuilderUtil requestBuilder = new ApiRequestBuilderUtil();
 * * ApiRequest request = requestBuilder.build("auth.login", authDTO);
 * * This will create an ApiRequest with the path "/auth/authenticate", method
 * POST,
 * * and the provided authDTO as the body.
 * * Note: The body object should have getters and setters for serialization.
 * * The headers will include the default Content-Type set to JSON.
 */
@Component
public class ApiRequestBuilderUtil {

    private static final Logger logger = LoggerFactory.getLogger(ApiRequestBuilderUtil.class);
    @Autowired
    private EndpointRegistry endpointRegistry;
    @Autowired
    private TokenStoreService tokenStoreService;

    public ApiRequest build(String key, Object body) {
        ApiEndpoint endpoint = endpointRegistry.get(key);

        if (endpoint == null) {
            throw new IllegalArgumentException("No endpoint mapping found for key: " + key);
        }
        // builder pattern for ApiRequest
        return ApiRequest.builder()
                .withPath(endpoint.getPath())
                .withMethod(endpoint.getMethod())
                .withBody(body)// DTO class Make sure body has getters and setters for serialization
                .withHeaders(getDefaultHeaders(endpoint)); // should set Content-Type to JSON. getDefaultHeaders Our
                                                           // custom headers utility method
    }

    /**
     * Overloaded build method to support GET or other HTTP requests with both
     * path parameters (placeholders in the endpoint path) and query parameters.
     *
     * Example:
     * Endpoint path: "/api/contact/{contactId}"
     * pathParams: { "contactId": "12345" }
     * queryParams: { "status": "active", "sort": "asc" }
     * Result: "/api/contact/12345?status=active&sort=asc"
     *
     * @param key         The endpoint key in the registry
     * @param pathParams  Map of path parameters (placeholder → value) to replace in
     *                    the endpoint path
     * @param queryParams Map of query parameters (name → value) to append after '?'
     * @return ApiRequest Built API request with placeholders replaced and query
     *         string appended
     * @throws IllegalArgumentException If no endpoint mapping is found for the
     *                                  given key
     */
    public ApiRequest build(String key, Map<String, String> pathParams, Map<String, String> queryParams) {
        ApiEndpoint endpoint = endpointRegistry.get(key);
        logger.info("Building API request for key: {} & pathParams: {} & queryParams: {}", key, pathParams,
                queryParams);

        if (endpoint == null) {
            throw new IllegalArgumentException("No endpoint mapping found for key: " + key);
        }

        String pathWithParams = endpoint.getPath();

        // Replace path parameters like /users/{userId} with actual encoded values
        if (pathParams != null && !pathParams.isEmpty()) {
            for (Map.Entry<String, String> entry : pathParams.entrySet()) {
                String placeholder = "{" + entry.getKey() + "}";//this should passed in pathParams map
                String encodedValue = UriUtils.encodePathSegment(entry.getValue(), StandardCharsets.UTF_8);
                pathWithParams = pathWithParams.replace(placeholder, encodedValue);//url also contains that placeholder.
            }
        }

        // Append query parameters if provided, properly encoding each value
        if (queryParams != null && !queryParams.isEmpty()) {
            String queryString = queryParams.entrySet()
                    .stream()
                    .map(entry -> entry.getKey() + "=" +
                            UriUtils.encodeQueryParam(entry.getValue(), StandardCharsets.UTF_8))
                    .collect(Collectors.joining("&"));
            pathWithParams += "?" + queryString;
        }

        return ApiRequest.builder()
                .withPath(pathWithParams)
                .withMethod(endpoint.getMethod())
                .withHeaders(getDefaultHeaders(endpoint));
    }

    public HttpHeaders getDefaultHeaders(ApiEndpoint apiEndpoint) {
        logger.info("Building default headers for API endpoint: {}", apiEndpoint.getPath());
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Skip adding token for authenticate & register APIs
        if (apiEndpoint.getPath().contains("/authenticate") || apiEndpoint.getPath().contains("/register")) {
            return headers;
        }
        // Get current HTTP session
        ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attr != null) {
            HttpSession session = attr.getRequest().getSession(false);
            if (session != null) {
                String userId = (String) session.getAttribute("userid");
                logger.debug("fetching userId from session: {}", userId);
                if (userId != null) {
                    JwtResponse jwtResponse = tokenStoreService.getToken(userId); // Retrieve JWT from token store
                    if (jwtResponse.getJwtToken() != null && !jwtResponse.getJwtToken().isBlank()) {
                        headers.set("Authorization", "Bearer " + jwtResponse.getJwtToken());
                    }
                }
            }
        }

        return headers;
    }

    // Helper DTO to represent endpoint info
    public static class ApiEndpoint {
        private final String path;
        private final HttpMethod method;

        public ApiEndpoint(String path, HttpMethod method) {
            this.path = path;
            this.method = method;
        }

        public String getPath() {
            return path;
        }

        public HttpMethod getMethod() {
            return method;
        }
    }
}
