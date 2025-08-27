package com.example.chatsphere.service.impl;

import com.apiservice.client.ApiDispatcherService;
import com.apiservice.client.ApiRequest;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.dto.UserStatusDTO;
import com.example.chatsphere.service.UserService;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import com.example.chatsphere.util.SuccessResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);

    @Autowired
    private ApiDispatcherService apiDispatcherService;

    @Autowired
    private ApiRequestBuilderUtil apiRequestBuilderUtil;

    @Override
    public SuccessResponse<UserDTO> getAllUsers() {

        logger.info("Preparing to fetch all users");

        // Build API request
        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getAllUsers", Collections.emptyMap(), Collections.emptyMap());
        logger.info("Fetching all users via API path: {}", apiReq.getPath());

        // Call the API
        SuccessResponse<UserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserDTO>>() {
        });

        // Log the result
        if (response.getData() != null) {
            logger.info("Successfully retrieved {} users", response.getData().size());
        } else {
            logger.info("No users found");
        }

        return response;
    }

    @Override
    public SuccessResponse<UserDTO> getByUserId(String userId) {
        logger.info("Preparing to fetch user details for userId: {}", userId);

        // Prepare path parameters
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("userId", userId);

        // Build API request
        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getByUserId", pathParams, Collections.emptyMap());
        logger.info("Fetching user details for userId via API path: {}", apiReq.getPath());

        // Call the API
        SuccessResponse<UserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserDTO>>() {
        });

        // Log the result
        if (response.getData() != null) {
            logger.info("User details retrieved for userId: {}", userId);
        } else {
            logger.info("No user found for userId: {}", userId);
        }

        return response;
    }

    @Override
    public SuccessResponse<UserStatusDTO> getUserLastActiveStatus(String userId) {
        logger.info("Preparing to fetch last active status for userId: {}", userId);

        // Prepare query parameters
        Map<String, String> queryParams = new HashMap<>();
        queryParams.put("userId", userId);

        // Build API request
        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getUserLastActiveStatus", Collections.emptyMap(), queryParams);
        logger.info("Fetching last active status via API path: {}", apiReq.getPath());

        // Call the API
        SuccessResponse<UserStatusDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserStatusDTO>>() {
        });

        // Log the result
        if (response.getData() != null) {
            logger.info("Successfully retrieved last active status for {} users", response.getData().size());
        } else {
            logger.info("No status data found");
        }

        return response;
    }
}
