package com.example.chatsphere.dto;

/**
 * Response from POST /api/media/upload-init
 * Contains pre-signed S3 upload URL and media ID
 */
public class MediaUploadInitResponse {

    private String mediaId; // Media record ID in database

    private String presignedUploadUrl; // Pre-signed S3 PUT URL for direct upload

    private int uploadUrlExpiresIn; // expire time in minutes

    // Constructors
    public MediaUploadInitResponse() {
    }

    public MediaUploadInitResponse(String mediaId, String presignedUploadUrl, int uploadUrlExpiresIn) {
        this.mediaId = mediaId;
        this.presignedUploadUrl = presignedUploadUrl;
        this.uploadUrlExpiresIn = uploadUrlExpiresIn;
    }

    // Getters and Setters
    public String getMediaId() {
        return mediaId;
    }

    public void setMediaId(String mediaId) {
        this.mediaId = mediaId;
    }

    public String getPresignedUploadUrl() {
        return presignedUploadUrl;
    }

    public void setPresignedUploadUrl(String presignedUploadUrl) {
        this.presignedUploadUrl = presignedUploadUrl;
    }

    public int getUploadUrlExpiresIn() {
        return uploadUrlExpiresIn;
    }

    public void setUploadUrlExpiresIn(int uploadUrlExpiresIn) {
        this.uploadUrlExpiresIn = uploadUrlExpiresIn;
    }
    
}
