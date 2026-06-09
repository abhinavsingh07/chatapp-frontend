package com.example.chatsphere.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@Component
public class CspNonceFilter extends OncePerRequestFilter {
    private static final Logger logger = LoggerFactory.getLogger(CspNonceFilter.class);

    private static final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String nonce = generateNonce();
        // all app jsp script tag need to apply
        request.setAttribute("cspNonce", nonce);
        
        String cspPolicy = "default-src 'self'; " +
                "script-src 'self' 'nonce-" + nonce + "' https://kit.fontawesome.com; " +
                "style-src 'self' 'unsafe-inline' https://ka-f.fontawesome.com; " +
                "font-src 'self' data: https://ka-f.fontawesome.com; " +
                "img-src 'self' data: blob:; " +
                "connect-src 'self' ws://localhost:8080 https://ka-f.fontawesome.com; " +
                "frame-ancestors 'none'; " +
                "object-src 'none'; " +
                "base-uri 'self'; " +
                "form-action 'self'";

        response.setHeader("Content-Security-Policy", cspPolicy);

        filterChain.doFilter(request, response);
    }

    private String generateNonce() {
        byte[] nonceBytes = new byte[16];
        secureRandom.nextBytes(nonceBytes);
        return Base64.getEncoder().encodeToString(nonceBytes);
    }
}