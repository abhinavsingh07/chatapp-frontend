package com.example.chatsphere.dto;

public class UserStatusDTO {
    private String userId;
    private boolean online;
    private long lastActive;

    public UserStatusDTO(String userId, boolean online, long lastActive) {
        this.userId = userId;
        this.online = online;
        this.lastActive = lastActive;
    }

    // Getters & Setters
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public boolean isOnline() {
        return online;
    }

    public void setOnline(boolean online) {
        this.online = online;
    }

    public long getLastActive() {
        return lastActive;
    }

    public void setLastActive(long lastActive) {
        this.lastActive = lastActive;
    }
}
