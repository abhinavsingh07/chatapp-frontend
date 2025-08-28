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

    private final ApiDispatcherService apiDispatcherService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public UserServiceImpl(ApiDispatcherService apiDispatcherService, ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.apiDispatcherService = apiDispatcherService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    @Override
    public SuccessResponse<UserDTO> getAllUsers() {
        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getAllUsers", Collections.emptyMap(), Collections.emptyMap());
        logger.info("Fetching all users via API path: {}", apiReq.getPath());

        SuccessResponse<UserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserDTO>>() {
        });

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Retrieved {} users", response.getData().size());
        } else {
            logger.info("No users found");
        }
        return response;
    }

    @Override
    public SuccessResponse<UserDTO> getByUserId(String userId) {
        Map<String, String> pathParams = Map.of("userId", userId);

        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getByUserId", pathParams, Collections.emptyMap());
        logger.info("Fetching user details for userId: {} via API path: {}", userId, apiReq.getPath());

        SuccessResponse<UserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserDTO>>() {
        });

        if (response.getData() != null) {
            logger.info("User details retrieved for userId: {}", userId);
        } else {
            logger.info("No user found for userId: {}", userId);
        }
        return response;
    }

    @Override
    public SuccessResponse<UserStatusDTO> getUserLastActiveStatus(String userId) {
        Map<String, String> queryParams = Map.of("userId", userId);

        ApiRequest apiReq = apiRequestBuilderUtil.build("user.getUserLastActiveStatus", Collections.emptyMap(), queryParams);
        logger.info("Fetching last active status for userId: {} via API path: {}", userId, apiReq.getPath());

        SuccessResponse<UserStatusDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<UserStatusDTO>>() {
        });

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Retrieved last active status for {} users", response.getData().size());
        } else {
            logger.info("No status data found for userId: {}", userId);
        }
        return response;
    }
}

