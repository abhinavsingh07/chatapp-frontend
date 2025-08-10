package com.example.chatsphere.dto;

/**
 * Data Transfer Object representing a contact user.
 */
public class ContactUserDTO {

    /**
     * Unique identifier of the contact (including suffix "_CONT").
     */
    private String contactId;

    /**
     * Status of the contact (e.g., ADDED, BLOCKED).
     */
    private String contactStatus;

    /**
     * Status of the contact's email (e.g., NOT_APPLICABLE, VERIFIED).
     */
    private String emailStatus;

    /**
     * Unique identifier of the contact user (including suffix "_USER").
     */
    private String contactUserId;

    /**
     * Full name of the contact.
     */
    private String name;

    /**
     * Contact's phone number.
     */
    private String phoneNumber;

    /**
     * Contact's email address.
     */
    private String email;

    /**
     * URL to the contact's profile picture.
     */
    private String profilePictureUrl;

    /**
     * Custom status message of the contact (if any).
     */
    private String status;

    private String contactEmail;

    /**
     * No-args constructor
     */
    public ContactUserDTO() {
    }

    /**
     * All-args constructor
     */
    public ContactUserDTO(String contactId, String contactStatus, String emailStatus, String contactUserId, String name, String phoneNumber, String email, String profilePictureUrl, String status) {
        this.contactId = contactId;
        this.contactStatus = contactStatus;
        this.emailStatus = emailStatus;
        this.contactUserId = contactUserId;
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.profilePictureUrl = profilePictureUrl;
        this.status = status;
    }

    // Getters and Setters
    public String getContactId() {
        return contactId;
    }

    public void setContactId(String contactId) {
        this.contactId = contactId;
    }

    public String getContactStatus() {
        return contactStatus;
    }

    public void setContactStatus(String contactStatus) {
        this.contactStatus = contactStatus;
    }

    public String getEmailStatus() {
        return emailStatus;
    }

    public void setEmailStatus(String emailStatus) {
        this.emailStatus = emailStatus;
    }

    public String getContactUserId() {
        return contactUserId;
    }

    public void setContactUserId(String contactUserId) {
        this.contactUserId = contactUserId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getProfilePictureUrl() {
        return profilePictureUrl;
    }

    public void setProfilePictureUrl(String profilePictureUrl) {
        this.profilePictureUrl = profilePictureUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }


}
