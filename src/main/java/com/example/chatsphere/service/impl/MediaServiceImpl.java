package com.example.chatsphere.service.impl;

import com.apiservice.client.ApiRequest;
import com.example.chatsphere.dto.MediaDTO;
import com.example.chatsphere.dto.MediaPreSignedUrlResponse;
import com.example.chatsphere.dto.MediaUploadCompleteResponse;
import com.example.chatsphere.dto.MediaUploadInitRequest;
import com.example.chatsphere.dto.MediaUploadInitResponse;
import com.example.chatsphere.service.AuthenticatedApiService;
import com.example.chatsphere.service.MediaService;
import com.example.chatsphere.util.ApiRequestBuilderUtil;
import com.example.chatsphere.util.SuccessResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
public class MediaServiceImpl implements MediaService {

    private static final Logger logger = LoggerFactory.getLogger(MediaServiceImpl.class);

    private final AuthenticatedApiService authenticatedApiService;
    private final ApiRequestBuilderUtil apiRequestBuilderUtil;

    public MediaServiceImpl(AuthenticatedApiService authenticatedApiService,
            ApiRequestBuilderUtil apiRequestBuilderUtil) {
        this.authenticatedApiService = authenticatedApiService;
        this.apiRequestBuilderUtil = apiRequestBuilderUtil;
    }

    @Override
    public SuccessResponse<MediaUploadInitResponse> uploadInit(MediaUploadInitRequest request) {
        ApiRequest apiReq = apiRequestBuilderUtil.build("media.uploadInit", Collections.emptyMap(),
                Collections.emptyMap(), request);

        logger.info("Initializing media upload: fileName='{}', mediaType='{}', usageType='{}', clientUploadId='{}'",
                request.getFileName(), request.getMediaType(), request.getUsageType(),
                request.getClientUploadId());

        SuccessResponse<MediaUploadInitResponse> response = authenticatedApiService.call(apiReq,
                new ParameterizedTypeReference<SuccessResponse<MediaUploadInitResponse>>() {
                });

        if (response.getData() != null && !response.getData().isEmpty()) {
            MediaUploadInitResponse data = response.getData().get(0);
            logger.info("Media upload initialized successfully. mediaId={}, s3Key='{}'", data.getMediaId());
        } else {
            logger.warn("No upload initialization response received for clientUploadId='{}'",
                    request.getClientUploadId());
        }

        return response;
    }

    @Override
    public SuccessResponse<MediaUploadCompleteResponse> uploadComplete(Long mediaId) {
        Map<String, String> pathParams = Map.of("mediaId", String.valueOf(mediaId));

        ApiRequest apiReq = apiRequestBuilderUtil.build("media.uploadComplete", pathParams,
                Collections.emptyMap());

        logger.info("Completing media upload for mediaId={}", mediaId);

        SuccessResponse<MediaUploadCompleteResponse> response = authenticatedApiService.call(apiReq,
                new ParameterizedTypeReference<SuccessResponse<MediaUploadCompleteResponse>>() {
                });

        if (response.getData() != null && !response.getData().isEmpty()) {
            MediaUploadCompleteResponse data = response.getData().get(0);
            logger.info("Media upload completed successfully. mediaId={}, status='{}'", data.getMediaId(),
                    data.getStatus());
        } else {
            logger.warn("No upload completion response received for mediaId={}", mediaId);
        }

        return response;
    }

    @Override
    public SuccessResponse<MediaPreSignedUrlResponse> getPresignedDownloadUrl(Long userId, Long mediaId) {
        Map<String, String> pathParams = Map.of("userId", String.valueOf(userId), "mediaId", String.valueOf(mediaId));

        ApiRequest apiReq = apiRequestBuilderUtil.build("media.getPresignedUrl", pathParams,
                Collections.emptyMap());

        logger.info("Generating pre-signed download URL for userId={}, mediaId={}", userId, mediaId);

        SuccessResponse<MediaPreSignedUrlResponse> response = authenticatedApiService.call(apiReq,
                new ParameterizedTypeReference<SuccessResponse<MediaPreSignedUrlResponse>>() {
                });

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Pre-signed URL generated successfully for userId={}, mediaId={}", userId, mediaId);
        } else {
            logger.warn("No pre-signed URL response received for userId={}, mediaId={}", userId, mediaId);
        }

        return response;
    }

    @Override
    public SuccessResponse<MediaPreSignedUrlResponse> getConversationMedia(Long conversationId, Long mediaId) {
        Map<String, String> pathParams = new HashMap<>();
        pathParams.put("conversationId", String.valueOf(conversationId));
        pathParams.put("mediaId", String.valueOf(mediaId));

        ApiRequest apiReq = apiRequestBuilderUtil.build("media.getConversationMedia", pathParams,
                Collections.emptyMap());

        logger.info("Fetching media for conversationId={}, mediaId={}", conversationId, mediaId);

        SuccessResponse<MediaPreSignedUrlResponse> response = authenticatedApiService.call(apiReq,
                new ParameterizedTypeReference<SuccessResponse<MediaPreSignedUrlResponse>>() {
                });

        if (response.getData() != null && !response.getData().isEmpty()) {
            logger.info("Media fetched successfully for conversationId={}, mediaId={}", conversationId, mediaId);
        } else {
            logger.warn("No media found for conversationId={}, mediaId={}", conversationId, mediaId);
        }

        return response;
    }
}
