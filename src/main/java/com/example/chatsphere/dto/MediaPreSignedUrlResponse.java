package com.example.chatsphere.dto;

/**
 * Response from GET /api/media/pre-signed-url/{mediaId}
 * Provides pre-signed download URL for accessing media from S3
 */
public class MediaPreSignedUrlResponse {

    private String presignedDownloadUrl; // Pre-signed GET URL for S3

    private Integer downloadUrlExpiresInMinutes; // Expiration time in minutes

    // Constructors
    public MediaPreSignedUrlResponse() {
    }

    public MediaPreSignedUrlResponse(String presignedDownloadUrl, Integer downloadUrlExpiresInMinutes) {
        this.presignedDownloadUrl = presignedDownloadUrl;
        this.downloadUrlExpiresInMinutes = downloadUrlExpiresInMinutes;
    }

    // Getters and Setters
    public String getPresignedDownloadUrl() {
        return presignedDownloadUrl;
    }

    public void setPresignedDownloadUrl(String presignedDownloadUrl) {
        this.presignedDownloadUrl = presignedDownloadUrl;
    }

    public Integer getDownloadUrlExpiresInMinutes() {
        return downloadUrlExpiresInMinutes;
    }

    public void setDownloadUrlExpiresInMinutes(Integer downloadUrlExpiresInMinutes) {
        this.downloadUrlExpiresInMinutes = downloadUrlExpiresInMinutes;
    }

}
