package com.example.chatsphere.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.chatsphere.dto.MediaDTO;
import com.example.chatsphere.dto.MediaPreSignedUrlResponse;
import com.example.chatsphere.dto.MediaUploadCompleteResponse;
import com.example.chatsphere.dto.MediaUploadInitRequest;
import com.example.chatsphere.dto.MediaUploadInitResponse;
import com.example.chatsphere.service.MediaService;
import com.example.chatsphere.util.SuccessResponse;

/**
 * MediaController
 * Handles all media related endpoints
 * - Initialize media uploads
 * - Complete media uploads
 * - Generate pre-signed download URLs
 * - Get conversation media metadata
 */
@Controller
public class MediaController {

    private static final Logger logger = LoggerFactory.getLogger(MediaController.class);

    private final MediaService mediaService;

    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }

    /**
     * Initialize a media upload session
     * 
     * @param request MediaUploadInitRequest containing media metadata
     * @return SuccessResponse<MediaUploadInitResponse> with mediaId, uploadUrl, and s3Key
     */
    @PostMapping("/api/media/upload-init")
    @ResponseBody
    public SuccessResponse<MediaUploadInitResponse> uploadInit(@RequestBody MediaUploadInitRequest request) {
        logger.info("Initializing media upload for clientUploadId='{}', fileName='{}', usageType='{}'",
                request.getClientUploadId(), request.getFileName(), request.getUsageType());

        SuccessResponse<MediaUploadInitResponse> response = mediaService.uploadInit(request);

        if (response.getData() != null && !response.getData().isEmpty()) {
            MediaUploadInitResponse data = response.getData().get(0);
            logger.info("Media upload initialized successfully. mediaId={}, usageType='{}'", data.getMediaId(),
                    request.getUsageType());
        } else {
            logger.warn("Failed to initialize media upload for clientUploadId='{}'", request.getClientUploadId());
        }

        return response;
    }

    /**
     * Complete a media upload after file has been uploaded to S3
     * 
     * @param mediaId The ID of the media record
     * @return SuccessResponse<MediaUploadCompleteResponse> with status confirmation
     */
    @PostMapping("/api/media/upload-complete/{mediaId}")
    @ResponseBody
    public SuccessResponse<MediaUploadCompleteResponse> uploadComplete(@PathVariable("mediaId") Long mediaId) {
        logger.info("Completing media upload for mediaId={}", mediaId);

        SuccessResponse<MediaUploadCompleteResponse> response = mediaService.uploadComplete(mediaId);

        if (response.getData() != null && !response.getData().isEmpty()) {
            MediaUploadCompleteResponse data = response.getData().get(0);
            logger.info("Media upload completed successfully. mediaId={}, status='{}'", mediaId, data.getStatus());
        } else {
            logger.warn("Failed to complete media upload for mediaId={}", mediaId);
        }

        return response;
    }

    /**
     * Generate a pre-signed download URL for accessing media from S3
     * 
     * @param mediaId The ID of the media record
     * @return SuccessResponse<MediaPreSignedUrlResponse> with presigned download URL
     */
    @GetMapping("/api/media/pre-signed-url/{userId}/{mediaId}")
    @ResponseBody
    public SuccessResponse<MediaPreSignedUrlResponse> getPresignedDownloadUrl(
            @PathVariable("userId") Long userId,
            @PathVariable("mediaId") Long mediaId) {
        logger.debug("Generating pre-signed download URL for userId={}, mediaId={}", userId, mediaId);

        SuccessResponse<MediaPreSignedUrlResponse> response = mediaService.getPresignedDownloadUrl(userId, mediaId);

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Pre-signed download URL generated successfully for userId={}, mediaId={}", userId, mediaId);
        } else {
            logger.warn("Failed to generate pre-signed download URL for userId={}, mediaId={}", userId, mediaId);
        }

        return response;
    }

    /**
     * Get media metadata for a specific media in a conversation
     *
     * @param conversationId The ID of the conversation
     * @param mediaId        The ID of the media record
     * @return SuccessResponse<MediaDTO> with media metadata
     */
    @GetMapping("/api/media/conversation/{conversationId}/media/{mediaId}")
    @ResponseBody
    public SuccessResponse<MediaPreSignedUrlResponse> getConversationMedia(
            @PathVariable("conversationId") Long conversationId,
            @PathVariable("mediaId") Long mediaId) {
        logger.debug("Fetching media for conversationId={}, mediaId={}", conversationId, mediaId);

        SuccessResponse<MediaPreSignedUrlResponse> response = mediaService.getConversationMedia(conversationId, mediaId);

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Media fetched successfully for conversationId={}, mediaId={}", conversationId, mediaId);
        } else {
            logger.warn("No media found for conversationId={}, mediaId={}", conversationId, mediaId);
        }

        return response;
    }
}
