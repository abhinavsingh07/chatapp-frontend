package com.example.chatsphere.security;

import com.example.chatsphere.dto.JwtResponse;
import com.example.chatsphere.service.TokenStoreService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
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
    private TokenStoreService tokenStoreService;

    private static final List<String> EXCLUDED_PATHS = List.of(
            "/login",
            "/register",
            "/authenticate",
            "/error",
            "/css/",
            "/js/",
            "/images/",
            "/icons/");


    public CustomSessionJwtFilter(TokenStoreService tokenStoreService) {
        this.tokenStoreService = tokenStoreService;
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

        HttpSession session = request.getSession(false);// false means don't create a new session if one doesn't exist
        if (session != null) {
            String loggedInUserId = session.getAttribute("userid").toString();
            JwtResponse jwtResponse = tokenStoreService.getToken(loggedInUserId);
            String jwt = jwtResponse.getJwtToken();
            if (jwt != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                //we are authenticating on jwt so creating dummy UsernamePasswordAuthenticationToken and setting in SecurityContextHolder
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken("user", null, List.of());
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                //Why is this needed?
                //Spring Security uses the SecurityContextHolder to determine if a user is authenticated.
                // If it's empty or null, Spring will block access to secured URLs.
                // Since you're handling login manually (outside Spring Security), this code tells Spring:
                //“Hey, trust me, this request is authenticated.”
                SecurityContextHolder.getContext().setAuthentication(authToken);//we sets every time for each request but check for null before if internally in any place we need or any route we again dont set it
            }
        }

        filterChain.doFilter(request, response);
    }
}
