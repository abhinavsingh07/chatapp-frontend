package com.example.chatsphere.util;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.mappings.EndpointRegistry;
import com.example.chatsphere.security.JwtResponse;
import com.example.chatsphere.service.TokenStoreService;
import com.example.chatsphere.service.impl.LoginServiceImpl;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
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

    //Builds api request
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
            String queryString = queryParams.entrySet().stream().map(entry -> entry.getKey() + "=" + UriUtils.encodeQueryParam(entry.getValue(), StandardCharsets.UTF_8)).collect(Collectors.joining("&"));
            pathWithParams += "?" + queryString;
        }

        if (logger.isDebugEnabled()) {
            logger.debug("Built path for key={}, finalPath={}", key, pathWithParams);
        }

        return ApiRequest.builder().withPath(pathWithParams).withMethod(endpoint.getMethod()).withHeaders(getDefaultHeaders(endpoint));
    }

    public HttpHeaders getDefaultHeaders(ApiEndpoint apiEndpoint) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        if (apiEndpoint.getPath().contains("/authenticate") || apiEndpoint.getPath().contains("/register")) {
            return headers;
        }
        //setting auth token from cookie if present
        ServletRequestAttributes attr = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attr != null) {
            HttpServletRequest httpRequest = attr.getRequest();
            if (httpRequest.getCookies() != null) {
                for (Cookie cookie : httpRequest.getCookies()) {
                    if ("jwt".equals(cookie.getName())) {
                        headers.setBearerAuth(cookie.getValue());
                        if (logger.isDebugEnabled()) {
                            logger.debug("JWT token added to headers for path={}", apiEndpoint.getPath());
                        }
                    }
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

