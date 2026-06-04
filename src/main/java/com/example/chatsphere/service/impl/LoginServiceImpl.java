package com.example.chatsphere.service.impl;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.dto.AuthDTO;
import com.example.chatsphere.dto.UserDTO;
import com.example.chatsphere.util.JwtResponse;
import com.example.chatsphere.service.LoginService;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import com.apiservice.client.ApiDispatcherService;

@Service
public class LoginServiceImpl implements LoginService {
    private static final Logger logger = LoggerFactory.getLogger(LoginServiceImpl.class);
    private final ApiDispatcherService apiDispatcherService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public LoginServiceImpl(ApiDispatcherService apiDispatcherService, ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.apiDispatcherService = apiDispatcherService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    @Override
    public JwtResponse validateCredentials(AuthDTO authDTO) {
        ApiRequest apiReq = apiRequestBuilderUtil.build("auth.login", authDTO);
        logger.info("Validating credentials for user: {}", apiReq.getPath());
        //api dispatcher service to make the API call if throws API exception we will to controller -> catch in globalexception handler.
        JwtResponse responseEntity = apiDispatcherService.call(apiReq, JwtResponse.class);
        logger.info("Received response for user authentication {}", apiReq.getPath());
        return responseEntity; // This object can be passed to JSP
    }

    @Override
    public UserDTO registerUser(UserDTO userDTO) {
        ApiRequest apiReq= apiRequestBuilderUtil.build("auth.register", userDTO);
        logger.info("Registering user with phone number or email: {}",  apiReq.getPath());
        UserDTO responseEntity = apiDispatcherService.call(apiReq, UserDTO.class);
        logger.info("User registration successful for: {}",  apiReq.getPath());
        return responseEntity;
    }
}
