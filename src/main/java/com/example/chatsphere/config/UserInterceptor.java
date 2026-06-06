package com.example.chatsphere.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.service.UserService;
import com.example.chatsphere.util.SuccessResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class UserInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(UserInterceptor.class);

    @Autowired
    @Lazy
    private UserService userService;

    @Override
    public boolean preHandle(HttpServletRequest request,
            HttpServletResponse response,
            Object handler) throws Exception {

        // 1. Skip interceptor for login/public pages to avoid infinite loops
        String path = request.getRequestURI();
        logger.info("Interceptor intercepting path:: {} ----------", path);
        if (path.contains("/login")
                || path.contains("/register")
                || path.contains("/api")
                || path.contains("/authenticate")
                || path.contains("/icons")) {
            logger.info("Skipping getUserMe Api call------");
            return true;
        }

        try {
            // getUserMe internally calling APIAuthenticatedService 
            //this calls servers 2 purpose 
            // 1. get latest user details 
            // 2. check token is expired (calls APIAutheticatService which internally handles refresh token flow)
            SuccessResponse<UserDTO> userResponse = userService.getUserMe();

            if (userResponse != null
                    && userResponse.getData() != null
                    && !userResponse.getData().isEmpty()) {

                UserDTO user = userResponse.getData().get(0);
                request.setAttribute("userId", user.getId());
                request.setAttribute("username", user.getName());

                logger.debug("User details populated for userId: {}", user.getId());
            }
        } catch (Exception e) {
            //also catching SessionExpiredException from ApiAuthenticateService
            logger.warn("Error fetching user details in interceptor: {}", e.getMessage());
            // Refresh token failed/expired too -> Force login
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        return true;
    }
}