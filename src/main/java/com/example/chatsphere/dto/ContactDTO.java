package com.example.chatsphere.dto;

/**
 * Data Transfer Object representing the contact creation request.
 */
public class ContactDTO {

    /**
     * Unique identifier of the user (including suffix "_USER").
     */
    private String userId;

    /**
     * Email address of the contact to be added.
     */
    private String email;

    /**
     * No-args constructor
     */
    public ContactDTO() {
    }

    /**
     * All-args constructor
     */
    public ContactDTO(String userId, String email) {
        this.userId = userId;
        this.email = email;
    }

    // Getters and Setters
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String toString() {
        return "ContactDTO [userId=" + userId + ", email=" + email + "]";
    }

    
}
