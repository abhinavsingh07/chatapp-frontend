package com.example.chatsphere.service.impl;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.dto.ContactDTO;
import com.example.chatsphere.dto.ContactUserDTO;
import com.example.chatsphere.service.AuthenticatedApiService;
import com.example.chatsphere.service.ContactService;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import com.example.chatsphere.util.SuccessResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
public class ContactServiceImpl implements ContactService {
    private static final Logger logger = LoggerFactory.getLogger(ContactServiceImpl.class);

    private final AuthenticatedApiService apiDispatcherService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public ContactServiceImpl(AuthenticatedApiService apiDispatcherService, ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.apiDispatcherService = apiDispatcherService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    @Override
    public SuccessResponse<ContactUserDTO> getContactsByUserId(String userId) {
        logger.info("Preparing to fetch contacts for userId: {}", userId);

        Map<String, String> queryParams = new HashMap<>();
        queryParams.put("userId", userId);

        ApiRequest apiReq = apiRequestBuilderUtil.build("contacts.getByUserId", Collections.emptyMap(), queryParams);
        logger.info("Fetching contacts for userId: {}", apiReq.getPath());

        SuccessResponse<ContactUserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<ContactUserDTO>>() {
        });

        logger.info("Retrieved {} contacts for userId: {}", response.getData().size(), userId);
        return response;
    }

    @Override
    public SuccessResponse<ContactUserDTO> addContact(ContactDTO contactDTO) {
        ApiRequest apiReq = apiRequestBuilderUtil.build("contact.add", contactDTO);

        logger.info("Adding contact for userId: {}, email: {}", contactDTO.getUserId(), contactDTO.getEmail());
        logger.debug("API path: {}", apiReq.getPath());

        SuccessResponse<ContactUserDTO> response = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<ContactUserDTO>>() {
        });

        if (response.getData() == null || response.getData().isEmpty()) {
            logger.warn("Failed to add contact for userId: {}", contactDTO.getUserId());
        } else {
            logger.info("Contact added successfully for userId: {}, email: {}", contactDTO.getUserId(), contactDTO.getEmail());
        }
        return response;
    }


    @Override
    public SuccessResponse<String> removeContact(String contactId) {
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("contactId", contactId);

        ApiRequest apiReq = apiRequestBuilderUtil.build("contact.remove", pathParams, Collections.emptyMap());
        logger.info("Removing contact: {}", apiReq.getPath());
        SuccessResponse<String> responseEntity = apiDispatcherService.call(apiReq, new ParameterizedTypeReference<SuccessResponse<String>>() {
        });
        logger.info("Contact removed successfully: {} for contactId: {}", apiReq.getPath(), contactId);
        return responseEntity;
    }

}