package com.example.chatsphere.dto;

/**
 * Response from POST /api/media/upload-complete/{mediaId}
 * Confirms media upload completion and current status
 */
public class MediaUploadCompleteResponse {

    private String mediaId;

    private String status; // ACTIVE, UPLOAD_PENDING, FAILED, REPLACED, DELETED

    private String message;

    // Constructors
    public MediaUploadCompleteResponse() {
    }

    public MediaUploadCompleteResponse(String mediaId, String status, String message) {
        this.mediaId = mediaId;
        this.status = status;
        this.message = message;
    }

    // Getters and Setters
    public String getMediaId() {
        return mediaId;
    }

    public void setMediaId(String mediaId) {
        this.mediaId = mediaId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "MediaUploadCompleteResponse{" +
                "mediaId=" + mediaId +
                ", status='" + status + '\'' +
                ", message='" + message + '\'' +
                '}';
    }
}
