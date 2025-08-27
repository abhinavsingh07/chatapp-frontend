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

    @Autowired
    private UserService userService;


    @GetMapping("/api/user/all")
    @ResponseBody
    public SuccessResponse<UserDTO> getAllUsers() {
        logger.info("Fetching all users");
        SuccessResponse<UserDTO> userResponse = userService.getAllUsers();
        logger.info("Total users fetched: {}", userResponse.getData().size());
        return userResponse;
    }

    @GetMapping("/api/user/{userId}")
    @ResponseBody
    public SuccessResponse<UserDTO> getByUserId(@PathVariable("userId") String userId) {
        logger.info("Fetching user details for userId: {}", userId);
        SuccessResponse<UserDTO> userResponse = userService.getByUserId(userId);
        logger.info("User fetch result for userId {}: {}", userId, userResponse.getData() != null ? "Found" : "Not Found");
        return userResponse;
    }
    
    @GetMapping("/api/user/lastActiveStatus")
    @ResponseBody
    public SuccessResponse<UserStatusDTO> getUserLastActiveStatus(@RequestParam("userId") String userId) {
        logger.info("Fetching last active status for userIds: {}", userId);
        SuccessResponse<UserStatusDTO> statusResponse = userService.getUserLastActiveStatus(userId);
        logger.info("Last active status fetched for {} users", statusResponse.getData().size());
        return statusResponse;
    }
}
