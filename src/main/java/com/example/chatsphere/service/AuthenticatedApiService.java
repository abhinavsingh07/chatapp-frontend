package com.example.chatsphere.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import com.apiservice.client.ApiDispatcherService;
import com.apiservice.client.ApiException;
import com.apiservice.client.ApiRequest;
import com.example.chatsphere.exception.SessionExpiredException;
import com.example.chatsphere.util.ApiRequestBuilderUtil;

@Service
public class AuthenticatedApiService {
    private static final Logger logger = LoggerFactory.getLogger(AuthenticatedApiService.class);

    private final ApiDispatcherService apiDispatcherService; // from jar
    private final RefreshTokenService refreshTokenService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public AuthenticatedApiService(ApiDispatcherService apiDispatcherService,
            @Lazy RefreshTokenService refreshTokenService,
            ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.apiDispatcherService = apiDispatcherService;
        this.refreshTokenService = refreshTokenService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    // from serviceimpl this will call.
    public <T> T call(ApiRequest apiRequest, Class<T> responseType) {
        return callInternal(apiRequest, responseType, true);
    }

    // for simple response types like JwtResponse, UserDTO etc.
    private <T> T callInternal(ApiRequest apiRequest, Class<T> responseType, boolean retryAllowed) {
        try {
            logger.info("AuthenticatedApiService.call invoked for simple response type for path: {}",
                    apiRequest.getPath());
            return apiDispatcherService.call(apiRequest, responseType);

        } catch (ApiException ex) {
            logger.warn(
                    "Authenticated API request failed for simple response type for path: {}. retryAllowed={}, exception={}",
                    apiRequest.getPath(), retryAllowed, ex.getMessage());

            if (!retryAllowed) {
                logger.error(
                        "Retry already exhausted for simple response type for path: {}. Throwing SessionExpiredException",
                        apiRequest.getPath());
                throw new SessionExpiredException("Session expired after retry: " + ex.getMessage());
            }

            /*** Refresh token call ***/
            boolean refreshed = refreshTokenService.refreshCurrentSession();
            logger.info("Refresh token attempt completed for simple response type for path: {}. refreshed={}",
                    apiRequest.getPath(), refreshed);

            if (!refreshed) {
                logger.error("Session refresh failed for simple response type: {}. Throwing SessionExpiredException");
                throw new SessionExpiredException("Session expired and unable to refresh: " + ex.getMessage());
            }

            logger.info(
                    "Retrying authenticated API request after successful session refresh for simple response type for path: {}",
                    apiRequest.getPath());
            // cookie refresh building headers again to fetch latest cookie data
            HttpHeaders httpheaders = apiRequestBuilderUtil.getDefaultHeaders();
            apiRequest.withHeaders(httpheaders);

            return callInternal(apiRequest, responseType, false);//retry flag prevents infinite call
        }
    }

    // from serviceimpl this will call.
    public <T> T call(ApiRequest apiRequest, ParameterizedTypeReference<T> responseType) {
        return callInternal(apiRequest, responseType, true);
    }

    // for complex response types like SuccessResponse<List<UserDTO>> etc.
    private <T> T callInternal(ApiRequest apiRequest,
            ParameterizedTypeReference<T> responseType,
            boolean retryAllowed) {
        try {
            logger.info("Dispatching authenticated API request for parameterized response type for path: {}",
                    apiRequest.getPath());
            return apiDispatcherService.call(apiRequest, responseType);

        } catch (ApiException ex) {
            logger.warn(
                    "Authenticated API request failed for parameterized response type for path: {}. retryAllowed={}, reason={}",
                    apiRequest.getPath(), retryAllowed, ex.getMessage());

            if (!retryAllowed) {
                logger.error(
                        "Retry already exhausted for parameterized response type for path: {}. Throwing SessionExpiredException",
                        apiRequest.getPath());
                throw new SessionExpiredException("Session expired after retry: " + ex.getMessage());
            }

            /*** Refresh token call ***/
            boolean refreshed = refreshTokenService.refreshCurrentSession();
            logger.info("Refresh token attempt completed for parameterized response type for path: {}. refreshed={}",
                    apiRequest.getPath(), refreshed);

            if (!refreshed) {
                logger.error(
                        "Session refresh failed for parameterized response type for path: {}. Throwing SessionExpiredException",
                        apiRequest.getPath());
                throw new SessionExpiredException("Unable to refresh session: " + ex.getMessage());
            }

            logger.info(
                    "Retrying authenticated API request after successful session refresh for parameterized response type for path: {}",
                    apiRequest.getPath());
            // cookie refresh building headers again to fetch latest cookie data
            HttpHeaders httpheaders = apiRequestBuilderUtil.getDefaultHeaders();
            apiRequest.withHeaders(httpheaders);
            return callInternal(apiRequest, responseType, false);
        }
    }
}