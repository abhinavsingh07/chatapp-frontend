package com.example.chatsphere.service;

import java.time.Duration;
import java.util.Arrays;
import java.util.Optional;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Service;

import com.example.chatsphere.util.JwtResponse;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Service
public class TokenCookieService {

    public static final String ACCESS_COOKIE = "jwt";
    public static final String REFRESH_COOKIE = "jwt_refresh";

    private static final Duration ACCESS_TTL = Duration.ofMinutes(30);
    private static final Duration REFRESH_TTL = Duration.ofDays(7);

    public Optional<String> getAccessToken(HttpServletRequest request) {
        return getCookieValue(request, ACCESS_COOKIE);
    }

    public Optional<String> getRefreshToken(HttpServletRequest request) {
        return getCookieValue(request, REFRESH_COOKIE);
    }

    private Optional<String> getCookieValue(HttpServletRequest request, String name) {
        if (request.getCookies() == null) {
            return Optional.empty();
        }

        return Arrays.stream(request.getCookies())
                .filter(c -> name.equals(c.getName()))
                .map(Cookie::getValue)
                .findFirst();
    }

    public void writeAccessTokenCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(ACCESS_COOKIE, token)
                .httpOnly(true)         // Protects against XSS attacks
                .secure(true)          // Required for HTTPS (set to false ONLY for local HTTP testing)
                .path("/")            // Sets the path (usually "/" for global site access)
                .sameSite("Strict")  // Protects against CSRF attacks
                .maxAge(ACCESS_TTL)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    public void writeRefreshTokenCookie(HttpServletResponse response, String token) {
        ResponseCookie cookie = ResponseCookie.from(REFRESH_COOKIE, token)
                .httpOnly(true)
                .secure(true)
                .path("/")
                .sameSite("Strict")
                .maxAge(REFRESH_TTL)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    public void clearAuthCookies(HttpServletResponse response) {
        ResponseCookie access = ResponseCookie.from(ACCESS_COOKIE, "")
                .httpOnly(true)
                .secure(true)
                .path("/")
                .sameSite("Strict")
                .maxAge(0)
                .build();

        ResponseCookie refresh = ResponseCookie.from(REFRESH_COOKIE, "")
                .httpOnly(true)
                .secure(true)
                .path("/")
                .sameSite("Strict")
                .maxAge(0)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, access.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, refresh.toString());
    }
    // both login and logout cookie should match every param to logout properly 
    public void writeTokenCookies(HttpServletResponse response, JwtResponse jwtresp) {
        writeAccessTokenCookie(response, jwtresp.getJwtToken());
        if (jwtresp.getRefreshToken() != null && !jwtresp.getRefreshToken().isBlank()) {
            writeRefreshTokenCookie(response, jwtresp.getRefreshToken());
        }
    }
}