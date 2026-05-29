package com.example.chatsphere.security;

import com.example.chatsphere.service.TokenStoreService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/***
 * CustomSessionJwtFilter is a Spring Security filter that checks for a JWT in
 * the user's session.
 * If a JWT is found and the user is not already authenticated, it creates an
 * authentication token
 * and sets it in the SecurityContextHolder.
 * Why is this needed?
 * Because we've disabled Spring's formLogin() and are not using built-in
 * authentication providers,
 * Spring Security doesn't know if a request is authenticated or not.
 * it will secure each application route urls we dont need explicitly to check
 * session in every controller method
 */
public class CustomSessionJwtFilter extends OncePerRequestFilter {
    private static final Logger logger = LoggerFactory.getLogger(CustomSessionJwtFilter.class);

    private final JwtUtil jwtUtil;
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    // Standard public endpoints that do NOT require JWT validation
    private static final List<String> EXCLUDED_PATHS = List.of(
            "/login", "/register", "/authenticate", "/error",
            "/api/authenticate", "/api/register", "/");

    public CustomSessionJwtFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // 1. Properly handle context path exclusion checking
        String servletPath = request.getServletPath();
        for (String excludePath : EXCLUDED_PATHS) {
            if (pathMatcher.match(excludePath, servletPath)) {
                filterChain.doFilter(request, response);
                return;
            }
        }

        // 2. Dynamic Token Extraction: Check Header FIRST, then fallback to Cookie
        String token = null;
        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7); // Extract token after "Bearer "
        } else if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("jwt".equals(cookie.getName())) {
                    token = cookie.getValue();
                    break;
                }
            }
        }

        // 3. Process the found token
        if (token != null) {
            try {
                // Check token expiration and validity
                if (jwtUtil.isTokenValid(token)) {
                    String userid = jwtUtil.extractId(token);
                    String username = jwtUtil.extractName(token);

                    // Attach user data to request context attributes for controller layers
                    request.setAttribute("userId", userid);
                    request.setAttribute("username", username);

                    // Set Spring Security Context with the REAL user details if not already present
                    if (SecurityContextHolder.getContext().getAuthentication() == null) {
                        UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                                username, // FIX: Use real extracted username instead of hardcoded string
                                null,
                                List.of() // Provide user roles/authorities here if available
                        );
                        authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        SecurityContextHolder.getContext().setAuthentication(authToken);
                    }
                } else {
                    logger.warn("JWT validation failed for incoming request.");
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or Expired Token");
                    return;
                }
            } catch (Exception e) {
                logger.error("Error evaluating security context processing JWT token", e);
                SecurityContextHolder.clearContext();
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized Session Token Request");
                return;
            }
        }

        // 4. Send request down the rest of the application filter pipe
        filterChain.doFilter(request, response);
    }
}
