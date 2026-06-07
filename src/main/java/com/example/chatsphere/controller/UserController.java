package com.example.chatsphere.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.dto.UserStatusDTO;
import com.example.chatsphere.mappings.PageMappings;
import com.example.chatsphere.service.UserService;
import com.example.chatsphere.util.SuccessResponse;

import java.util.Collections;

@Controller
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/profile")
    public String profilePage(Model model) {
        logger.info("Loading profile page.");
        try {
            SuccessResponse<UserDTO> userResponse = userService.getUserMe();
            if (userResponse.getData() != null && !userResponse.getData().isEmpty()) {
                model.addAttribute("user", userResponse.getData().get(0));
                logger.info("Loaded logged-in user details for profile page");
            } else {
                logger.warn("No logged-in user details returned for profile page");
            }
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Unable to load profile details: " + e.getMessage());
            logger.error("Failed to load logged-in user details for profile page", e);
        }
        model.addAttribute(PageMappings.VIEW_PLACEHOLDER, PageMappings.PROFILE_VIEW);
        return PageMappings.INDEX_PAGE;
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

    @PostMapping("/api/update-profile")
    @ResponseBody
    public SuccessResponse<UserDTO> updateUser(@ModelAttribute UserDTO userDTO) {
        logger.debug("Updating user profile for userId: {}", userDTO.getId());

        try {
            SuccessResponse<UserDTO> response = userService.updateUserById(userDTO.getId(), userDTO);
            logger.info("User profile updated successfully for userId: {}", userDTO.getId());
            return new SuccessResponse<>("SUCCESS", "Profile updated successfully!", response.getData());
        } catch (Exception e) {
            logger.error("Error updating user profile for userId: {}", userDTO.getId(), e);
            return new SuccessResponse<>("ERROR", "Error updating profile: " + e.getMessage(), Collections.emptyList());
        }
    }
}
