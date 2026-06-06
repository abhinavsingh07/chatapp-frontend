package com.example.chatsphere.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

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
        try {
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
            logger.warn("Error fetching user details in interceptor: {}", e.getMessage());
        }

        return true;
    }
}