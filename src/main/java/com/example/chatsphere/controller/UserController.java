package com.example.chatsphere.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.dto.UserStatusDTO;
import com.example.chatsphere.service.UserService;
import com.example.chatsphere.util.SuccessResponse;

@Controller
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/api/user/all")
    @ResponseBody
    public SuccessResponse<UserDTO> getAllUsers() {
        // Debug-level log to avoid clutter in production
        logger.debug("Fetching all users");
        SuccessResponse<UserDTO> userResponse = userService.getAllUsers();
        logger.info("Total users fetched: {}", userResponse.getData().size());
        return userResponse;
    }

    @GetMapping("/api/user/{userId}")
    @ResponseBody
    public SuccessResponse<UserDTO> getByUserId(@PathVariable("userId") String userId) {
        logger.debug("Fetching user details for userId={}", userId);
        SuccessResponse<UserDTO> userResponse = userService.getByUserId(userId);

        if (userResponse.getData() != null && !userResponse.getData().isEmpty()) {
            logger.info("User found for userId={}", userId);
        } else {
            logger.warn("User not found for userId={}", userId);
        }

        return userResponse;
    }

    @GetMapping("/api/user/lastActiveStatus")
    @ResponseBody
    public SuccessResponse<UserStatusDTO> getUserLastActiveStatus(@RequestParam("userId") String userId) {
        logger.debug("Fetching last active status for userId={}", userId);
        SuccessResponse<UserStatusDTO> statusResponse = userService.getUserLastActiveStatus(userId);
        logger.info("Last active status fetched for {} user(s)", statusResponse.getData().size());
        return statusResponse;
    }
}
