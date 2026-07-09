package com.example.chatsphere.service;

import com.example.chatsphere.dto.MediaDTO;
import com.example.chatsphere.dto.MediaPreSignedUrlResponse;
import com.example.chatsphere.dto.MediaUploadCompleteResponse;
import com.example.chatsphere.dto.MediaUploadInitRequest;
import com.example.chatsphere.dto.MediaUploadInitResponse;
import com.example.chatsphere.util.SuccessResponse;

/**
 * Service interface for media upload operations
 * Handles initialization, completion, and pre-signed URL generation for media uploads
 */
public interface MediaService {

    /**
     * Initialize a media upload session
     * Calls backend /api/media/upload-init to get pre-signed S3 upload URL
     *
     * @param request MediaUploadInitRequest containing media metadata
     * @return SuccessResponse containing MediaUploadInitResponse with mediaId, uploadUrl, s3Key
     */
    SuccessResponse<MediaUploadInitResponse> uploadInit(MediaUploadInitRequest request);

    /**
     * Complete a media upload after file has been uploaded to S3
     * Calls backend /api/media/upload-complete/{mediaId} to mark media as ACTIVE
     *
     * @param mediaId The ID of the media record
     * @return SuccessResponse containing MediaUploadCompleteResponse with status confirmation
     */
    SuccessResponse<MediaUploadCompleteResponse> uploadComplete(Long mediaId);

    /**
     * Generate a pre-signed download URL for accessing media from S3
     * Calls backend /api/media/pre-signed-url/{mediaId}
     *
     * @param mediaId The ID of the media record
     * @return SuccessResponse containing MediaPreSignedUrlResponse with presigned download URL
     */
    SuccessResponse<MediaPreSignedUrlResponse> getPresignedDownloadUrl(Long userId, Long mediaId);

    /**
     * Get media metadata by conversation ID and media ID
     * Calls backend /api/media/conversation/{conversationId}/media/{mediaId}
     *
     * @param conversationId The ID of the conversation
     * @param mediaId        The ID of the media record
     * @return SuccessResponse containing MediaDTO with media metadata
     */
    SuccessResponse<MediaPreSignedUrlResponse> getConversationMedia(Long conversationId, Long mediaId);
}
