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
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;


/***
 * CustomSessionJwtFilter is a Spring Security filter that checks for a JWT in the user's session.
 * If a JWT is found and the user is not already authenticated, it creates an authentication token
 * and sets it in the SecurityContextHolder.
 * Why is this needed?
 * Because we've disabled Spring's formLogin() and are not using built-in authentication providers,
 * Spring Security doesn't know if a request is authenticated or not.
 * it will secure each application route urls we dont need explicitly to check session in every controller method
 */
public class CustomSessionJwtFilter extends OncePerRequestFilter {
    private static final Logger logger = LoggerFactory.getLogger(CustomSessionJwtFilter.class);


    @Autowired
    private JwtUtil jwtUtil;

    private static final List<String> EXCLUDED_PATHS = List.of(
            "/login",
            "/register",
            "/authenticate",
            "/error",
            "/css/",
            "/js/",
            "/images/",
            "/icons/");
    public CustomSessionJwtFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    public CustomSessionJwtFilter() {
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        //This filter runs for every request either is authenticated or not, so we can check if the user is authenticated
        // Check if the request path is excluded from authentication
        String requestURI = request.getRequestURI();
        for (String excludePath : EXCLUDED_PATHS) {
            if (requestURI.contains(excludePath)) {
                filterChain.doFilter(request, response);
                return;
            }
        }

        // 1. Read JWT from cookie
        String token = null;
        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("jwt".equals(cookie.getName())) {
                    token = cookie.getValue();
                }
            }
        }
        //append userid and username in request attribute for further use in controller
        if (token != null) {
            try {
                String userid= jwtUtil.extractId(token);
                String username= jwtUtil.extractName(token);
                request.setAttribute("userId", userid);
                request.setAttribute("username", username);
            } catch (Exception e) {
                logger.error("Invalid JWT", e);
            }
        }
        //if user is not authenticated it can give 404 for page even if page is correctly returned from controller.
        // 2. If token present and not already authenticated
        if (token != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                // validate token (signature + expiry)
                boolean isTokenValid = jwtUtil.isTokenValid(token);
                if (isTokenValid) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken("username", null, List.of());
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                } else {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    return;
                }

            } catch (Exception e) {
                // invalid/expired token → clear context
                SecurityContextHolder.clearContext();
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
        }
        // 3. Continue filter chain
        filterChain.doFilter(request, response);
    }
}

