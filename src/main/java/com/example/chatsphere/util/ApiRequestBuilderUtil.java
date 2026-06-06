package com.example.chatsphere.util;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.mappings.EndpointRegistry;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
import java.util.Collection;
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

    // Builds api request
    public ApiRequest build(String key, Object body) {
        ApiEndpoint endpoint = endpointRegistry.get(key);

        if (endpoint == null) {
            throw new IllegalArgumentException("No endpoint mapping found for key: " + key);
        }

        if (logger.isDebugEnabled()) {
            logger.debug("Building API request for key={} with body={}", key, body);
        }

        return ApiRequest.builder()
                .withPath(endpoint.getPath())
                .withMethod(endpoint.getMethod())
                .withBody(body)
                .withHeaders(getDefaultHeaders(endpoint));
    }

    public ApiRequest build(String key, Map<String, String> pathParams, Map<String, String> queryParams) {
        ApiEndpoint endpoint = endpointRegistry.get(key);

        if (endpoint == null) {
            throw new IllegalArgumentException("No endpoint mapping found for key: " + key);
        }

        String pathWithParams = endpoint.getPath();

        if (pathParams != null && !pathParams.isEmpty()) {
            for (Map.Entry<String, String> entry : pathParams.entrySet()) {
                String placeholder = "{" + entry.getKey() + "}";
                String encodedValue = UriUtils.encodePathSegment(entry.getValue(), StandardCharsets.UTF_8);
                pathWithParams = pathWithParams.replace(placeholder, encodedValue);
            }
        }

        if (queryParams != null && !queryParams.isEmpty()) {
            String queryString = queryParams.entrySet().stream().map(
                    entry -> entry.getKey() + "=" + UriUtils.encodeQueryParam(entry.getValue(), StandardCharsets.UTF_8))
                    .collect(Collectors.joining("&"));
            pathWithParams += "?" + queryString;
        }

        if (logger.isDebugEnabled()) {
            logger.debug("Built path for key={}, finalPath={}", key, pathWithParams);
        }

        return ApiRequest.builder()
                .withPath(pathWithParams)
                .withMethod(endpoint.getMethod())
                .withHeaders(getDefaultHeaders(endpoint));
    }

    /**
     * Setting bearer auth token in headers (Bearer <JWT Token>)
     * 
     * @param apiEndpoint
     * @return
     */
    public HttpHeaders getDefaultHeaders(ApiEndpoint apiEndpoint) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 1. Bypass authentication headers for public/anonymous endpoints (Login,
        // Registration, etc.)
        if (apiEndpoint.getPath().contains("/authenticate") || apiEndpoint.getPath().contains("/register")) {
            return headers;
        }

        // 2. Retrieve the active HTTP request context from Spring's thread-local
        // storage
        ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attr != null) {
            HttpServletRequest httpRequest = attr.getRequest();

            // Extract lifecycle synchronization flags set during interceptor/refresh flow
            String isToKenRefreshedInCurrentRequest = (String) httpRequest
                    .getAttribute("tokenRefreshedInOngoingRequest");
            String afterRefreshJwtToken = (String) httpRequest.getAttribute("afterRefreshJwtToken");

            // 3. STRATEGY A: Prioritise the freshly minted token if a refresh event
            // occurred mid-request.
            // This prevents downstream API calls in the same lifecycle from using the
            // expired browser cookie.
            if (isToKenRefreshedInCurrentRequest != null && "true".equals(isToKenRefreshedInCurrentRequest)) {
                headers.setBearerAuth(afterRefreshJwtToken);
            }
            // 4. STRATEGY B: Fall back to extracting the original token from incoming
            // browser cookies.
            else {
                if (httpRequest.getCookies() != null) {
                    for (Cookie cookie : httpRequest.getCookies()) {
                        if ("jwt".equals(cookie.getName())) {
                            headers.setBearerAuth(cookie.getValue());

                            // Guarded logging to maintain application performance under load
                            if (logger.isDebugEnabled()) {
                                logger.debug("JWT token added to headers for path={}", apiEndpoint.getPath());
                            }
                        }
                    }
                }
            }
        }

        return headers;
    }

    /**
     * Setting bearer auth token in headers (Bearer <JWT Token>)
     * 
     * @return
     */

    // using in Authenticated API service class
    public HttpHeaders getDefaultHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        // setting auth token from cookie if present
        ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attr != null) {
            // when cookie is setting after refresh it is setting in response so for retry
            // request we fetch from response
            HttpServletResponse httpResponse = attr.getResponse();
            Collection<String> headers1 = httpResponse.getHeaders("Set-Cookie");
            for (String header : headers1) {
                if (header.startsWith("jwt" + "=")) {
                    String token = header.split(";")[0].split("=")[1];
                    headers.setBearerAuth(token);
                }
            }
        }

        return headers;
    }

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
