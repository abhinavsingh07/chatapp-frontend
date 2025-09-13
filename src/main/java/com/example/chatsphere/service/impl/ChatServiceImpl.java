package com.example.chatsphere.service.impl;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.apiservice.client.ApiDispatcherService;
import com.apiservice.client.ApiRequest;
import com.example.chatsphere.dto.ConversationLastMsgDTO;
import com.example.chatsphere.dto.MessageDTO;
import com.example.chatsphere.service.ChatService;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import com.example.chatsphere.util.SuccessResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ChatServiceImpl implements ChatService {

    private static final Logger logger = LoggerFactory.getLogger(ChatServiceImpl.class);
    private final ApiDispatcherService apiDispatcherService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public ChatServiceImpl(ApiDispatcherService apiDispatcherService, ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.apiDispatcherService = apiDispatcherService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    @Override
    public String getOrCreateConversationId(String fromUserId, String toUserId) {
        logger.info("Fetching or creating conversation ID for users: {} and {}", fromUserId, toUserId);
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("fromUserId", fromUserId);
        pathParams.put("toUserId", toUserId);
        // Build API request
        ApiRequest apiRequest = apiRequestBuilderUtil.build("conv.getOrCreateConv", pathParams, Collections.emptyMap());
        // Dispatch API call
        SuccessResponse<String> response = apiDispatcherService.call(apiRequest, new ParameterizedTypeReference<SuccessResponse<String>>() {
        });
        // Validate response
        List<String> conversationIds = response.getData();
        if (conversationIds == null || conversationIds.isEmpty()) {
            logger.error("No conversation ID returned for users: {} and {}", fromUserId, toUserId);
            return null;
        }

        String conversationId = conversationIds.get(0);
        logger.info("Fetched/Created conversation ID: {} for users: {} and {}", conversationId, fromUserId, toUserId);

        return conversationId;
    }

    @Override
    public List<MessageDTO> getMessagesByConversationId(String conversationId) {
        logger.info("Fetching messages for conversation ID: {}", conversationId);
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("conversationId", conversationId);
        // Build API request
        ApiRequest apiRequest = apiRequestBuilderUtil.build("message.getByConvId", pathParams, Collections.emptyMap());
        // Dispatch API call
        SuccessResponse<MessageDTO> response = apiDispatcherService.call(apiRequest, new ParameterizedTypeReference<SuccessResponse<MessageDTO>>() {
        });

        // Validate response
        List<MessageDTO> messages = response.getData();
        if (messages == null || messages.isEmpty()) {
            logger.warn("No messages found for conversation ID: {}", conversationId);
            return Collections.emptyList();
        }

        logger.info("Fetched {} messages for conversation ID: {}", messages.size(), conversationId);
        return messages;
    }

    @Override
    public List<ConversationLastMsgDTO> getLastMessageByLoggedInUserId(String userId) {
        logger.info("Fetching last messages for logged-in user ID: {}", userId);
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("userId", userId);
        // Build API request - assuming the API key for this is "conversation.getLastMessagesByUser"
        ApiRequest apiRequest = apiRequestBuilderUtil.build("conv.getLastConversationByLoggedInUser", pathParams, Collections.emptyMap());
        // Dispatch API call
        SuccessResponse<ConversationLastMsgDTO> response = apiDispatcherService.call(apiRequest, new ParameterizedTypeReference<SuccessResponse<ConversationLastMsgDTO>>() {
        });

        // Validate response
        List<ConversationLastMsgDTO> lastMessages = response.getData();
        if (lastMessages == null || lastMessages.isEmpty()) {
            logger.warn("No last messages found for logged-in user ID: {}", userId);
            return Collections.emptyList();
        }

        logger.info("Fetched {} last messages for logged-in user ID: {}", lastMessages.size(), userId);
        return lastMessages;
    }

}
