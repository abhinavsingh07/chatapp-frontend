package com.example.chatsphere.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import com.example.chatsphere.util.JwtResponse;
import com.example.chatsphere.util.RefreshTokenRequest;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Service
public class RefreshTokenService {

    private static final Logger logger = LoggerFactory.getLogger(RefreshTokenService.class);

    private final CookieService cookieService;
    private final AuthService authService;

    public RefreshTokenService(CookieService cookieService, AuthService authService) {
        this.cookieService = cookieService;
        this.authService = authService;
    }

    /**
     * Refreshes the current session's access token using the stored refresh token.
     * 
     * This method performs the following operations:
     * 1. Retrieves the current HTTP request and response from the request context
     * 2. Extracts the refresh token from the request cookies
     * 3. Calls the authentication service to obtain new tokens
     * 4. Updates the response with new JWT access and refresh tokens
     *
     * @return {@code true} if token refresh was successful; {@code false} if the
     *         refresh token
     *         is missing, invalid, or the authentication service returns null
     * 
     * @see #currentRequest()
     * @see #currentResponse()
     */

    public boolean refreshCurrentSession() {
        try {
            // Retrieve the current HTTP request and response from Spring's
            // RequestContextHolder
            HttpServletRequest request = currentRequest();
            HttpServletResponse response = currentResponse();

            logger.debug("Attempting to refresh token from current session");

            // Extract refresh token from cookies; returns Optional for null-safety
            String refreshToken = cookieService.getRefreshToken(request)
                    .orElse(null);

            // Check if refresh token is missing
            if (refreshToken == null) {
                logger.warn("Refresh token not found in cookies");
                return false;
            }

            logger.debug("Refresh token found, calling authentication service");

            // Call the authentication service with the refresh token to obtain new JWT
            // tokens
            JwtResponse jwtResponse = authService.refreshToken(new RefreshTokenRequest(refreshToken));

            // Validate response from authentication service
            if (jwtResponse == null || jwtResponse.getJwtToken() == null) {
                logger.error("Authentication service returned null or invalid JWT response");
                return false;
            }

            // Write the new access token and refresh token to the response cookies
            cookieService.writeTokenCookies(response, jwtResponse);

            //important step
            request.setAttribute("tokenRefreshedInOngoingRequest", "true");
            request.setAttribute("afterRefreshJwtToken", jwtResponse.getJwtToken());

            logger.info("Token refresh successful for user");
            return true;

        } catch (IllegalStateException e) {
            // RequestContextHolder throws IllegalStateException when called outside request
            // context
            logger.error("Unable to refresh token: request context not available", e.getMessage());
            return false;
        } catch (Exception e) {
            // Catch any unexpected exceptions during token refresh
            logger.error("Unexpected error during token refresh", e.getMessage());
            return false;
        }
    }

    /**
     * Retrieves the current HTTP request from Spring's RequestContextHolder.
     * 
     * @return the current {@link HttpServletRequest}
     * @throws IllegalStateException if called outside of a request context
     */
    private HttpServletRequest currentRequest() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            throw new IllegalStateException(
                    "Request context not available - this method must be called within an HTTP request");
        }
        return attrs.getRequest();
    }

    /**
     * Retrieves the current HTTP response from Spring's RequestContextHolder.
     * 
     * @return the current {@link HttpServletResponse}
     * @throws IllegalStateException if called outside of a request context
     */
    private HttpServletResponse currentResponse() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            throw new IllegalStateException(
                    "Request context not available - this method must be called within an HTTP request");
        }
        return attrs.getResponse();
    }
}
