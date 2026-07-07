package com.example.chatsphere.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

/**
 * Request body for POST /api/media/upload-init
 * Contains media metadata before uploading to S3
 */
public class MediaUploadInitRequest {

    @NotBlank(message = "Media type is required")
    private String mediaType; // IMAGE, VIDEO, DOCUMENT

    @NotBlank(message = "Usage type is required")
    private String usageType; // CHAT_ATTACHMENT, PROFILE_PICTURE

    @NotBlank(message = "Content type is required")
    private String contentType; // image/jpeg, image/png, etc.

    @NotNull(message = "File size is required")
    @Positive(message = "File size must be greater than 0")
    private Long fileSize; // in bytes

    @NotBlank(message = "File name is required")
    private String fileName;

    private String conversationId; // Optional, for CHAT_ATTACHMENT

    @NotBlank(message = "Client upload ID is required")
    private String clientUploadId; // Unique client-generated ID for idempotency/retry

    // Constructors
    public MediaUploadInitRequest() {
    }

    public MediaUploadInitRequest(String mediaType, String usageType, String contentType,
            Long fileSize, String fileName, String conversationId, String clientUploadId) {
        this.mediaType = mediaType;
        this.usageType = usageType;
        this.contentType = contentType;
        this.fileSize = fileSize;
        this.fileName = fileName;
        this.conversationId = conversationId;
        this.clientUploadId = clientUploadId;
    }

    // Getters and Setters
    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getUsageType() {
        return usageType;
    }

    public void setUsageType(String usageType) {
        this.usageType = usageType;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getConversationId() {
        return conversationId;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public String getClientUploadId() {
        return clientUploadId;
    }

    public void setClientUploadId(String clientUploadId) {
        this.clientUploadId = clientUploadId;
    }
}
