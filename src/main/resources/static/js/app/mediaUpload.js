/**
 * Media Upload Module
 * Reusable functions for handling media uploads (chat attachments, profile pictures)
 * Handles S3 direct upload with pre-signed URLs and backend API integration
 * 
 * Public API:
 * - generateClientUploadId()
 * - validateSelectedFile(file, usageType)
 * - initMediaUpload(usageType, clientUploadId, payload)
 * - uploadFileToS3(uploadUrl, file, onProgress)
 * - completeMediaUpload(mediaId, clientUploadId)
 * - retryUploadComplete(mediaId, clientUploadId)
 * - showUploadError(message)
 * - showUploadSuccess(message)
 * - setUploadLoadingState(state)
 * - resetUploadState()
 */

// Configuration
const MEDIA_CONFIG = {
    MAX_IMAGE_SIZE: 10 * 1024 * 1024, // 10 MB
    MAX_VIDEO_SIZE: 50 * 1024 * 1024, // 50 MB
    MAX_DOCUMENT_SIZE: 20 * 1024 * 1024, // 20 MB
    ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/bmp'],
    ALLOWED_VIDEO_TYPES: ['video/mp4', 'video/mpeg', 'video/quicktime', 'video/webm', 'video/x-msvideo', 'video/x-matroska', 'video/3gpp'],
    ALLOWED_DOCUMENT_TYPES: ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'text/plain', 'application/vnd.oasis.opendocument.text', 'application/vnd.oasis.opendocument.spreadsheet', 'application/vnd.oasis.opendocument.presentation'],
    DEBUG: true // Set to true for development logging
};

// Global state tracking
const UPLOAD_STATE = {
    isUploading: false,
    currentMediaId: null,
    currentFile: null,
    targetContainer: null // 'chat' or 'profile'
};

/**
 * Generate a unique client upload ID for request tracking
 * @returns {string} Unique ID like "upload_1234567890_abcdef"
 */
function generateClientUploadId() {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    return `upload_${timestamp}_${random}`;
}

/**
 * Validate a selected file based on usage type
 * @param {File} file - File object from input
 * @param {string} usageType - 'CHAT_MESSAGE' or 'PROFILE_PICTURE'
 * @returns {Object} {valid: boolean, error: string|null, mediaType: string|null}
 */
function validateSelectedFile(file, usageType) {
    if (!file) {
        return { valid: false, error: 'No file selected' };
    }

    // Profile picture: image only
    if (usageType === 'PROFILE_PICTURE') {
        if (!MEDIA_CONFIG.ALLOWED_IMAGE_TYPES.includes(file.type)) {
            return { valid: false, error: 'Only JPEG, PNG, WebP, GIF, and BMP images are allowed for profile picture' };
        }
        if (file.size > MEDIA_CONFIG.MAX_IMAGE_SIZE) {
            const sizeMB = (MEDIA_CONFIG.MAX_IMAGE_SIZE / 1024 / 1024).toFixed(0);
            return { valid: false, error: `Image must be smaller than ${sizeMB} MB` };
        }
        return { valid: true, error: null, mediaType: 'IMAGE' };
    }

    // Chat message: images, videos, or documents
    if (usageType === 'CHAT_ATTACHMENT') {
        let mediaType = null;
        let maxSize = null;

        if (MEDIA_CONFIG.ALLOWED_IMAGE_TYPES.includes(file.type)) {
            mediaType = 'IMAGE';
            maxSize = MEDIA_CONFIG.MAX_IMAGE_SIZE;
        } else if (MEDIA_CONFIG.ALLOWED_VIDEO_TYPES.includes(file.type)) {
            mediaType = 'VIDEO';
            maxSize = MEDIA_CONFIG.MAX_VIDEO_SIZE;
        } else if (MEDIA_CONFIG.ALLOWED_DOCUMENT_TYPES.includes(file.type)) {
            mediaType = 'DOCUMENT';
            maxSize = MEDIA_CONFIG.MAX_DOCUMENT_SIZE;
        } else {
            return { valid: false, error: 'File type not supported. Allowed: images, videos, or documents' };
        }

        if (file.size > maxSize) {
            const sizeMB = (maxSize / 1024 / 1024).toFixed(0);
            return { valid: false, error: `${mediaType} must be smaller than ${sizeMB} MB` };
        }

        return { valid: true, error: null, mediaType };
    }

    return { valid: false, error: 'Invalid usage type' };
}

/**
 * Initialize media upload via backend API
 * @param {string} usageType - 'CHAT_MESSAGE' or 'PROFILE_PICTURE'
 * @param {string} clientUploadId - Unique client ID
 * @param {Object} payload - Additional data (file, conversationId, etc.)
 * @returns {Promise} Resolves with {mediaId, uploadUrl, s3Key} or rejects with error
 */
function initMediaUpload(usageType, clientUploadId, payload = {}) {
    return new Promise((resolve, reject) => {
        const file = payload.file;
        if (!file) {
            reject('File not provided');
            return;
        }

        // Determine media type
        let mediaType = 'UNKNOWN';
        if (MEDIA_CONFIG.ALLOWED_IMAGE_TYPES.includes(file.type)) {
            mediaType = 'IMAGE';
        } else if (MEDIA_CONFIG.ALLOWED_VIDEO_TYPES.includes(file.type)) {
            mediaType = 'VIDEO';
        } else if (MEDIA_CONFIG.ALLOWED_DOCUMENT_TYPES.includes(file.type)) {
            mediaType = 'DOCUMENT';
        }

        const requestBody = {
            mediaType: mediaType,
            usageType: usageType,
            contentType: file.type,
            fileSize: file.size,
            fileName: file.name,
            conversationId: payload.conversationId || null,
            clientUploadId: clientUploadId
        };

        // Construct URL - use endpointRegistry if available, otherwise fallback to hardcoded path
        let uploadInitUrl = `${ctx}/api/media/upload-init`;
        if (typeof window.endpointRegistry !== 'undefined' && window.endpointRegistry) {
            const endpoint = window.endpointRegistry.get('media.uploadInit');
            if (endpoint) {
                uploadInitUrl = endpoint.url;
            }
        }

        debugLog(`[initMediaUpload] Calling ${uploadInitUrl} with clientUploadId=${clientUploadId}`);

        ajaxRequest(uploadInitUrl, 'POST', requestBody,
            function (response) {
                debugLog('[initMediaUpload] Success response:', response);
                if (response && response.data && response.data.length > 0) {
                    const data = response.data[0];
                    debugLog('[initMediaUpload] Received mediaId:', data.mediaId);
                    resolve({
                        mediaId: data.mediaId,
                        uploadUrl: data.presignedUploadUrl,
                        uploadUrlExpiresIn: data.uploadUrlExpiresInMinutes
                    });
                } else {
                    reject('Invalid response format from upload-init');
                }
            },
            function (xhr, status, error) {
                debugLog('[initMediaUpload] Error:', status, error, xhr);
                let errorMsg = 'Failed to prepare upload. Please try again.';
                if (xhr.status === 401 || xhr.status === 403) {
                    errorMsg = 'Unauthorized. Please log in again.';
                } else if (xhr.status === 400) {
                    errorMsg = 'Invalid file. ' + (xhr.responseJSON?.message || '');
                } else if (xhr.status >= 500) {
                    errorMsg = 'Server error. Please try again later.';
                }
                reject(errorMsg);
            }
        );
    });
}

/**
 * Upload file directly to S3 using pre-signed PUT URL
 * @param {string} uploadUrl - Pre-signed S3 PUT URL
 * @param {File} file - File to upload
 * @param {Function} onProgress - Callback for progress updates {progress: 0-100, state: string}
 * @returns {Promise} Resolves when upload succeeds, rejects on failure
 */
function uploadFileToS3(uploadUrl, file, onProgress = null) {
    return new Promise((resolve, reject) => {
        debugLog('[uploadFileToS3] Starting upload to S3');

        if (!uploadUrl || !file) {
            reject('Upload URL or file missing');
            return;
        }

        // Call progress callback
        if (typeof onProgress === 'function') {
            onProgress({ progress: 0, state: 'Uploading media…' });
        }

        const xhr = new XMLHttpRequest();

        // Track upload progress
        xhr.upload.addEventListener('progress', (event) => {
            if (event.lengthComputable) {
                const percentComplete = Math.round((event.loaded / event.total) * 90); // 0-90%
                debugLog(`[uploadFileToS3] Progress: ${percentComplete}%`);
                if (typeof onProgress === 'function') {
                    onProgress({ progress: percentComplete, state: 'Uploading media…' });
                }
            }
        });

        xhr.addEventListener('load', () => {
            if (xhr.status === 200 || xhr.status === 204) {
                debugLog('[uploadFileToS3] Upload successful (status ' + xhr.status + ')');
                if (typeof onProgress === 'function') {
                    onProgress({ progress: 100, state: 'Upload complete' });
                }
                resolve();
            } else {
                debugLog('[uploadFileToS3] Upload failed (status ' + xhr.status + ')');
                let errorMsg = 'Upload failed. Please try again.';
                if (xhr.status === 403) {
                    errorMsg = 'Upload URL expired. Please start over.';
                } else if (xhr.status === 400) {
                    errorMsg = 'Invalid upload request.';
                }
                reject(errorMsg);
            }
        });

        xhr.addEventListener('error', (event) => {
            // console.error('XHR Error Event:', event);
            // console.error('readyState:', xhr.readyState);
            console.error('status:', xhr.status);
            // console.error('statusText:', xhr.statusText);
            console.error('responseText:', xhr.responseText);

            reject(`Network error. Status: ${xhr.status}`);
        });

        xhr.addEventListener('abort', () => {
            debugLog('[uploadFileToS3] Upload aborted');
            reject('Upload cancelled.');
        });

        // Set headers and send
        xhr.open('PUT', uploadUrl);
        xhr.setRequestHeader('Content-Type', file.type);
        xhr.send(file);
    });
}

/**
 * Complete media upload via backend API
 * Marks media as ACTIVE after S3 upload succeeds
 * @param {number|string} mediaId - Media ID from uploadInit
 * @param {string} clientUploadId - Unique client ID for tracking
 * @returns {Promise} Resolves with completion response, rejects on failure
 */
function completeMediaUpload(mediaId, clientUploadId) {
    return new Promise((resolve, reject) => {
        if (!mediaId) {
            reject('Media ID missing');
            return;
        }

        // Construct URL with path parameter
        let uploadCompleteUrl = `${ctx}/api/media/upload-complete/${mediaId}`;
        if (typeof window.endpointRegistry !== 'undefined' && window.endpointRegistry) {
            const endpoint = window.endpointRegistry.get('media.uploadComplete');
            if (endpoint) {
                uploadCompleteUrl = endpoint.url.replace('{mediaId}', mediaId);
            }
        }

        const requestBody = {
            clientUploadId: clientUploadId
        };

        debugLog(`[completeMediaUpload] Calling ${uploadCompleteUrl} for mediaId=${mediaId}`);

        ajaxRequest(uploadCompleteUrl, 'POST', requestBody,
            function (response) {
                debugLog('[completeMediaUpload] Success response:', response);
                if (response && response.data && response.data.length > 0) {
                    const data = response.data[0];
                    resolve({
                        mediaId: data.mediaId,
                        status: data.status,
                        message: data.message
                    });
                } else {
                    reject('Invalid response format from upload-complete');
                }
            },
            function (xhr, status, error) {
                debugLog('[completeMediaUpload] Error:', status, error, xhr);
                let errorMsg = 'Failed to verify upload. Retry verification or try again.';
                if (xhr.status === 401 || xhr.status === 403) {
                    errorMsg = 'Unauthorized. Please log in again.';
                } else if (xhr.status === 400) {
                    errorMsg = 'Verification failed: ' + (xhr.responseJSON?.message || 'Invalid media');
                } else if (xhr.status >= 500) {
                    errorMsg = 'Server error. Please try again later.';
                }
                reject(errorMsg);
            }
        );
    });
}

/**
 * Retry upload completion (no file re-upload, verification only)
 * @param {number|string} mediaId - Media ID
 * @param {string} clientUploadId - Unique client ID
 * @returns {Promise} Resolves with completion response
 */
function retryUploadComplete(mediaId, clientUploadId) {
    debugLog('[retryUploadComplete] Retrying completion for mediaId=' + mediaId);
    return completeMediaUpload(mediaId, clientUploadId);
}

/**
 * Display upload error message in alert area
 * Auto-dismisses after 5 seconds
 * @param {string} message - Error message
 * @param {string} container - 'chat' or 'profile' (defaults to 'chat')
 */
function showUploadError(message, container = 'chat') {
    debugLog('[showUploadError] ' + message);

    let targetElement = null;
    if (container === 'profile') {
        targetElement = document.getElementById('profileUploadStatus');
    } else {
        targetElement = document.getElementById('uploadStatusText');
    }

    if (!targetElement) {
        console.warn('[showUploadError] Target element not found for container=' + container);
        return;
    }

    // Add spinner icon and error styling
    const spinnerHtml = '<i class="fas fa-exclamation-circle me-2"></i>';
    targetElement.innerHTML = spinnerHtml + message;
    targetElement.className = container === 'profile'
        ? 'alert alert-danger small d-block mt-3 mb-2'
        : 'text-danger small mt-2';

    // Show element
    if (targetElement.classList.contains('d-none')) {
        targetElement.classList.remove('d-none');
    }

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        if (!targetElement.classList.contains('d-none')) {
            targetElement.classList.add('d-none');
        }
    }, 5000);
}

/**
 * Display upload success message
 * Auto-dismisses after 3 seconds
 * @param {string} message - Success message
 * @param {string} container - 'chat' or 'profile'
 */
function showUploadSuccess(message, container = 'chat') {
    debugLog('[showUploadSuccess] ' + message);

    let targetElement = null;
    if (container === 'profile') {
        targetElement = document.getElementById('profileUploadStatus');
    } else {
        targetElement = document.getElementById('uploadStatusText');
    }

    if (!targetElement) {
        console.warn('[showUploadSuccess] Target element not found for container=' + container);
        return;
    }

    const checkmarkHtml = '<i class="fas fa-check-circle me-2" style="color: #28a745;"></i>';
    targetElement.innerHTML = checkmarkHtml + '<span style="color: #28a745;">' + message + '</span>';
    targetElement.className = container === 'profile'
        ? 'alert alert-success small d-block mt-3 mb-2'
        : 'text-success small mt-2';

    if (targetElement.classList.contains('d-none')) {
        targetElement.classList.remove('d-none');
    }

    // Auto-dismiss after 3 seconds
    setTimeout(() => {
        if (!targetElement.classList.contains('d-none')) {
            targetElement.classList.add('d-none');
        }
    }, 3000);
}

/**
 * Set upload loading state and update UI accordingly
 * @param {string} state - 'preparing', 'uploading', 'verifying', 'completed', 'failed'
 * @param {string} container - 'chat' or 'profile'
 */
function setUploadLoadingState(state, container = 'chat') {
    debugLog('[setUploadLoadingState] ' + state + ' for container=' + container);
    UPLOAD_STATE.isUploading = state !== 'completed' && state !== 'failed';
    UPLOAD_STATE.targetContainer = container;

    // Get button reference
    const sendButton = container === 'chat' ? document.getElementById('sendButton') : document.getElementById('profileRetryUploadBtn');
    const attachButton = document.getElementById('attachMediaBtn');
    const statusElement = container === 'profile' ? document.getElementById('profileUploadStatus') : document.getElementById('uploadStatusText');

    if (!statusElement) return;

    // Update status text based on state
    let statusText = '';
    let statusClass = 'text-info';
    const spinnerIcon = '<i class="fas fa-spinner fa-spin me-2"></i>';

    switch (state) {
        case 'preparing':
            statusText = 'Preparing upload…';
            statusClass = 'text-info';
            break;
        case 'uploading':
            statusText = 'Uploading media…';
            statusClass = 'text-info';
            break;
        case 'verifying':
            statusText = 'Verifying upload…';
            statusClass = 'text-info';
            break;
        case 'completed':
            statusText = 'Upload complete!';
            statusClass = 'text-success';
            break;
        case 'failed':
            statusText = 'Upload failed. Please try again.';
            statusClass = 'text-danger';
            break;
        default:
            return;
    }

    // Update status display
    if (container === 'profile') {
        statusElement.innerHTML = spinnerIcon + statusText;
        statusElement.className = 'alert alert-info small d-block mt-3 mb-2';
        statusElement.classList.remove('d-none');
    } else {
        statusElement.innerHTML = spinnerIcon + statusText;
        statusElement.className = statusClass + ' small mt-2';
        statusElement.classList.remove('d-none');
    }

    // Disable/enable buttons
    if (sendButton) {
        sendButton.disabled = UPLOAD_STATE.isUploading;
    }
    if (attachButton && container === 'chat') {
        attachButton.disabled = UPLOAD_STATE.isUploading;
    }
}

/**
 * Reset upload state and UI to initial condition
 * Clears file input, hides previews, re-enables buttons
 * @param {string} container - 'chat' or 'profile'
 */
function resetUploadState(container = 'chat') {
    debugLog('[resetUploadState] Resetting for container=' + container);

    UPLOAD_STATE.isUploading = false;
    UPLOAD_STATE.currentMediaId = null;
    UPLOAD_STATE.currentFile = null;

    if (container === 'chat') {
        // Clear chat media input
        const chatMediaInput = document.getElementById('chatMediaInput');
        if (chatMediaInput) {
            chatMediaInput.value = '';
        }

        // Hide media preview
        const previewContainer = document.getElementById('mediaPreviewContainer');
        if (previewContainer && !previewContainer.classList.contains('d-none')) {
            previewContainer.classList.add('d-none');
        }

        // Clear preview content
        const previewImageArea = document.getElementById('mediaPreviewImageArea');
        if (previewImageArea) {
            previewImageArea.innerHTML = '';
        }

        // Hide upload status
        const statusText = document.getElementById('uploadStatusText');
        if (statusText && !statusText.classList.contains('d-none')) {
            statusText.classList.add('d-none');
        }

        // Re-enable send button
        const sendButton = document.getElementById('sendButton');
        if (sendButton) {
            sendButton.disabled = false;
        }

        // Re-enable attach button
        const attachButton = document.getElementById('attachMediaBtn');
        if (attachButton) {
            attachButton.disabled = false;
        }
    } else if (container === 'profile') {
        // Clear profile picture input
        const profileInput = document.getElementById('profilePictureInput');
        if (profileInput) {
            profileInput.value = '';
        }

        // Hide upload status
        const statusElement = document.getElementById('profileUploadStatus');
        if (statusElement && !statusElement.classList.contains('d-none')) {
            statusElement.classList.add('d-none');
        }

        // Hide retry button
        const retryButton = document.getElementById('profileRetryUploadBtn');
        if (retryButton && !retryButton.classList.contains('d-none')) {
            retryButton.classList.add('d-none');
        }
    }
}

/**
 * Internal debug logging function
 * Logs only if MEDIA_CONFIG.DEBUG is true
 * @param {any} args - Arguments to log
 */
function debugLog() {
    if (MEDIA_CONFIG.DEBUG && typeof console !== 'undefined' && console.log) {
        console.log.apply(console, arguments);
    }
}

window.MediaU
