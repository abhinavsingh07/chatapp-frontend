package com.example.chatsphere.service;

import java.time.Duration;
import java.util.Arrays;
import java.util.Optional;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.example.chatsphere.util.JwtResponse;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Service for managing JWT authentication cookies.
 * Handles reading and writing secure HTTP-only cookies for JWT access and refresh tokens.
 */
@Service
public class CookieService {
    private static final Logger logger = LoggerFactory.getLogger(CookieService.class);

    public static final String ACCESS_COOKIE = "jwt";
    public static final String REFRESH_COOKIE = "jwt_refresh";

    private static final Duration ACCESS_TTL = Duration.ofMinutes(30); //30 minutes
    private static final Duration REFRESH_TTL = Duration.ofDays(7);//7 days

    /**
     * Retrieves the JWT access token from request cookies.
     *
     * @param request the HTTP request containing cookies
     * @return Optional containing the access token if present
     */
    public Optional<String> getAccessToken(HttpServletRequest request) {
        return getCookieValue(request, ACCESS_COOKIE);
    }

    /**
     * Retrieves the JWT refresh token from request cookies.
     *
     * @param request the HTTP request containing cookies
     * @return Optional containing the refresh token if present
     */
    public Optional<String> getRefreshToken(HttpServletRequest request) {
        return getCookieValue(request, REFRESH_COOKIE);
    }

    /**
     * Helper method to extract a cookie value by name from the request.
     *
     * @param request the HTTP request containing cookies
     * @param name    the name of the cookie to retrieve
     * @return Optional containing the cookie value if found
     */
    private Optional<String> getCookieValue(HttpServletRequest request, String name) {
        // Handle requests with no cookies
        if (request.getCookies() == null) {
            logger.debug("No cookies found in request");
            return Optional.empty();
        }

        return Arrays.stream(request.getCookies())
                .filter(c -> name.equals(c.getName()))
                .map(Cookie::getValue)
                .findFirst();
    }

    /**
     * Writes JWT access token to response cookie with security settings.
     * Cookie is HTTP-only, secure, and strict SameSite policy.
     *
     * @param response the HTTP response to add cookie to
     * @param token    the JWT access token
     */
    public void writeAccessTokenCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(ACCESS_COOKIE, token)
                .httpOnly(true)         // Protects against XSS attacks
                .secure(false)          // Required for HTTPS (set to false ONLY for local HTTP testing)
                .path("/")            // Global site access
                .sameSite("Strict")  // Protects against CSRF attacks
                .maxAge(ACCESS_TTL)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
        logger.debug("Access token cookie written");
    }

    /**
     * Writes JWT refresh token to response cookie with security settings.
     * Cookie is HTTP-only, secure, and strict SameSite policy.
     *
     * @param response the HTTP response to add cookie to
     * @param token    the JWT refresh token
     */
    public void writeRefreshTokenCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(REFRESH_COOKIE, token)
                .httpOnly(true)
                .secure(false)
                .path("/")
                .sameSite("Strict")
                .maxAge(REFRESH_TTL)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
        logger.debug("Refresh token cookie written");
    }

    /**
     * Clears both access and refresh token cookies from the response.
     * Used during logout to invalidate stored tokens.
     *
     * @param response the HTTP response to clear cookies from
     */
    public void clearAuthCookies(HttpServletResponse response) {
        // Set maxAge to 0 to delete existing cookies
        ResponseCookie access = ResponseCookie.from(ACCESS_COOKIE, "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .sameSite("Strict")
                .maxAge(0)
                .build();

        ResponseCookie refresh = ResponseCookie.from(REFRESH_COOKIE, "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .sameSite("Strict")
                .maxAge(0)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, access.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, refresh.toString());
        logger.info("Auth cookies cleared");
    }

    /**
     * Writes both access and refresh tokens to response cookies.
     * Refresh token is only written if present and not blank.
     *
     * @param response the HTTP response to add cookies to
     * @param jwtresp  the JWT response containing access and refresh tokens
     */
    public void writeTokenCookies(HttpServletResponse response, JwtResponse jwtresp) {
        writeAccessTokenCookie(response, jwtresp.getJwtToken());
        
        // Write refresh token if available (ensure all cookie params match for logout to work properly)
        if (jwtresp.getRefreshToken() != null && !jwtresp.getRefreshToken().isBlank()) {
            writeRefreshTokenCookie(response, jwtresp.getRefreshToken());
        }
    }
}