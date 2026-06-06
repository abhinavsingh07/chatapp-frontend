package com.example.chatsphere.mappings;

import java.util.Collections;
import java.util.Map;

import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;

import com.example.chatsphere.util.ApiRequestBuilderUtil;

@Component("endpointRegistry")
public class EndpointRegistry {
    // Map your logical keys to API metadata , endpointRegistry is variable
    private final Map<String, ApiRequestBuilderUtil.ApiEndpoint> endpoints = Map.ofEntries(
            Map.entry("auth.login", new ApiRequestBuilderUtil.ApiEndpoint("/auth/authenticate", HttpMethod.POST)),
            Map.entry("auth.register", new ApiRequestBuilderUtil.ApiEndpoint("/auth/register", HttpMethod.POST)),
            Map.entry("auth.refresh", new ApiRequestBuilderUtil.ApiEndpoint("/auth/refresh", HttpMethod.POST)),
            Map.entry("user.getByUserId", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/{userId}", HttpMethod.GET)),
            Map.entry("user.getAllUsers", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/all", HttpMethod.GET)),
            Map.entry("user.getUserLastActiveStatus", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/lastActiveStatus", HttpMethod.GET)),
            Map.entry("user.getUserMe", new ApiRequestBuilderUtil.ApiEndpoint("/api/users/me", HttpMethod.GET)),
            Map.entry("message.getByConvId", new ApiRequestBuilderUtil.ApiEndpoint("/api/messages/conversation/{conversationId}", HttpMethod.GET)),
            Map.entry("conv.getOrCreateConv", new ApiRequestBuilderUtil.ApiEndpoint("/api/conversations/get-or-create/{fromUserId}/{toUserId}", HttpMethod.POST)),
            Map.entry("conv.getLastConversationByLoggedInUser", new ApiRequestBuilderUtil.ApiEndpoint("/api/conversations/{userId}/last-message", HttpMethod.GET)),
            Map.entry("contact.add", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts", HttpMethod.POST)),
            Map.entry("contact.remove", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts/{contactId}", HttpMethod.DELETE)),
            Map.entry("contacts.getByUserId", new ApiRequestBuilderUtil.ApiEndpoint("/api/contacts/search", HttpMethod.GET))
    );

    public ApiRequestBuilderUtil.ApiEndpoint get(String key) {
        return endpoints.get(key);
    }

    public Map<String, ApiRequestBuilderUtil.ApiEndpoint> getAll() {
        return Collections.unmodifiableMap(endpoints);
    }
}
