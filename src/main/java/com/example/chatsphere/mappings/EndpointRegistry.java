package com.example.chatsphere.mappings;

import java.util.Collections;
import java.util.Map;

import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;

import com.example.chatsphere.util.ApiRequestBuilderUtil;

@Component("endpointRegistry")
public class EndpointRegistry {
    // Map your logical keys to API metadata , endpointRegistry is variable
    private final Map<String, ApiRequestBuilderUtil.ApiEndpoint> endpoints = Map.of(
            "auth.login", new ApiRequestBuilderUtil.ApiEndpoint("/auth/authenticate", HttpMethod.POST),
            "auth.register", new ApiRequestBuilderUtil.ApiEndpoint("/auth/register", HttpMethod.POST),
            "user.getByUserId", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/{userId}", HttpMethod.GET),
            "user.getAllUsers", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/all", HttpMethod.GET),
            "user.getUserLastActiveStatus", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/lastActiveStatus", HttpMethod.GET),
            "message.getByConvId", new ApiRequestBuilderUtil.ApiEndpoint("/api/messages/conversation/{conversationId}", HttpMethod.GET),
            "conv.getOrCreateConv", new ApiRequestBuilderUtil.ApiEndpoint("/api/conversations/get-or-create/{fromUserId}/{toUserId}", HttpMethod.POST),
            "contact.add", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts", HttpMethod.POST),
            "contact.remove", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts/{contactId}", HttpMethod.DELETE),
            "contacts.getByUserId", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts/search", HttpMethod.GET));

    public ApiRequestBuilderUtil.ApiEndpoint get(String key) {
        return endpoints.get(key);
    }

    public Map<String, ApiRequestBuilderUtil.ApiEndpoint> getAll() {
        return Collections.unmodifiableMap(endpoints);
    }
}
