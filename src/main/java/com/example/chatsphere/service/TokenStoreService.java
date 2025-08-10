package com.example.chatsphere.service;

import org.springframework.stereotype.Service;

import com.example.chatsphere.security.JwtResponse;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;


/**
 * This class act as a simple in-memory token store.A session-scoped token vault
 * This gives you access to the JWT associated with the current session—useful for:
 *  Adding it to outgoing API requests
 *  Verifying token validity on protected pages
 *  Custom logging, analytics, or role-based UI rendering
 *  In utils method we will use this to inject token to backend api call
 *
 *  Later we can centralize this to seprate redis or some other storage
 */
@Service
public class TokenStoreService {
    private final Map<String, JwtResponse> tokenMap = new ConcurrentHashMap<>();

    public void storeToken(String userId, JwtResponse jwtResponse) {
        tokenMap.put(userId, jwtResponse);
    }

    public JwtResponse getToken(String userId) {
        return tokenMap.get(userId);
    }

    public void removeToken(String userId) {
        tokenMap.remove(userId);
    }
}
