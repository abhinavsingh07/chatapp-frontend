package com.example.chatsphere.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

public class MessageDTO {

    private String id;
    @NotBlank(message = "Conversation ID is required")
    private String conversationId;
    @NotBlank(message = "Sender ID is required")
    private String senderId;
    @NotBlank(message = "Receiver ID is required")
    private String receiverId;
    private String content;
    private String mediaId;
    private String messageStatus; // e.g., SENT, DELIVERED, READ
    private String sentAt;//from api utc date and time coming as string.On lcient side we use js code to convert to user timezone.

    public MessageDTO(String content, String conversationId, String id, String mediaId, String messageStatus, String receiverId, String senderId, String sentAt) {
        this.content = content;
        this.conversationId = conversationId;
        this.id = id;
        this.mediaId = mediaId;
        this.messageStatus = messageStatus;
        this.receiverId = receiverId;
        this.senderId = senderId;
        this.sentAt = sentAt;
    }

    // Getters & Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getConversationId() {
        return conversationId;
    }

    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    public String getSenderId() {
        return senderId;
    }

    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }

    public String getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(String receiverId) {
        this.receiverId = receiverId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getMediaId() {
        return mediaId;
    }

    public void setMediaId(String mediaId) {
        this.mediaId = mediaId;
    }

    public String getSentAt() {
        return sentAt;
    }

    public void setSentAt(String sentAt) {
        this.sentAt = sentAt;
    }
    public String getMessageStatus() {
        return messageStatus;
    }
    public void setMessageStatus(String messageStatus) {
        this.messageStatus = messageStatus;
    }

}
