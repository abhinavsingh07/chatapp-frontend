package com.example.chatsphere.dto;

/**
 * Response from GET /api/media/pre-signed-url/{mediaId}
 * Provides pre-signed download URL for accessing media from S3
 */
public class MediaPreSignedUrlResponse {

    private String presignedDownloadUrl; // Pre-signed GET URL for S3

    private Integer downloadUrlExpiresInMinutes; // Expiration time in minutes

    private String mediaType; // Media type (e.g., image/jpeg, video/mp4)
    private String mediaName; // Original name of the media file
    private String mediaId; // Unique identifier for the media record

    // Constructors
    public MediaPreSignedUrlResponse() {
    }

    public MediaPreSignedUrlResponse(String presignedDownloadUrl, Integer downloadUrlExpiresInMinutes) {
        this.presignedDownloadUrl = presignedDownloadUrl;
        this.downloadUrlExpiresInMinutes = downloadUrlExpiresInMinutes;
    }

    public MediaPreSignedUrlResponse(String presignedDownloadUrl, Integer downloadUrlExpiresInMinutes, String mediaType,
            String mediaName, String mediaId) {
        this.presignedDownloadUrl = presignedDownloadUrl;
        this.downloadUrlExpiresInMinutes = downloadUrlExpiresInMinutes;
        this.mediaType = mediaType;
        this.mediaName = mediaName;
        this.mediaId = mediaId;
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

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getMediaName() {
        return mediaName;
    }

    public void setMediaName(String mediaName) {
        this.mediaName = mediaName;
    }

    public String getMediaId() {
        return mediaId;
    }

    public void setMediaId(String mediaId) {
        this.mediaId = mediaId;
    }

}
