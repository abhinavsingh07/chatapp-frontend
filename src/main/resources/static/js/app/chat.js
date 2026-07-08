
class ChatWebSocket {
    static wsStatus = {
        CONNECTED: "CONNECTED",
        CHAT: "CHAT",
        TYPING_START: "TYPING_START",
        TYPING_STOP: "TYPING_STOP",
        DISCONNECTED: "DISCONNECTED",
        HEARTBEAT: "HEARTBEAT",
        PRESENCE_UPDATE: "PRESENCE_UPDATE"
    };



    constructor(chatId, fromUserId, toUserId) {
        this.chatId = chatId;
        this.fromUserId = fromUserId;
        this.toUserId = toUserId;
        this.fromUserName = `${username}`; // Initialize fromUserName

        this.socket = null;
        this.typingTimeout = null;

        // DOM Elements
        this.messagesContainer = document.getElementById("messagesContainer");
        this.messageInput = document.getElementById("messageInput");
        this.typingIndicator = document.getElementById("typingIndicator");
        this.messageForm = document.getElementById("messageForm");
        this.heartbeatInterval = null;

        // Media upload state
        this.selectedMediaFiles = []; // Array of files
        this.selectedMediaIds = []; // Array of mediaIds
        this.isUploadingMedia = false;
    }

    // not calling WebSocket Lifecycle from chatroom directly, instead calling from shared worker 
    // to utilize the active websocket connection and avoid multiple 
    // connections issue when multiple tabs are open for same user.    
    // ----------------- WebSocket Lifecycle -----------------

    connect() {
        //and jwt goes with cookie, so no need to send it explicitly in the WebSocket connection URL or headers. The server can extract the JWT from the cookie during the WebSocket handshake and use it for authentication and authorization.
        // const wsUrl = `ws://localhost:8080/synk/ws/chat`;
        const wsUrl = `ws://localhost/synk/ws/chat`;
        // Check if socket exists and is still open or connecting
        if (this.socket && (this.socket.readyState === WebSocket.OPEN || this.socket.readyState === WebSocket.CONNECTING)) {
            //console.log("WebSocket is already connected or connecting");
            return;
        }
        this.socket = new WebSocket(wsUrl);
        this.socket.onopen = () => this.onOpen();
        this.socket.onmessage = (event) => this.onMessage(event);
        this.socket.onclose = () => this.onClose();
        this.socket.onerror = (err) => this.onError(err);
    }

    disconnect() {
        // Allow closing during CONNECTING or OPEN states
        if (this.socket && (this.socket.readyState === WebSocket.OPEN || this.socket.readyState === WebSocket.CONNECTING)) {
            console.log("Disconnecting WebSocket...");
            this.socket.close(1000, "User left chat");
            this.socket = null; // Clear immediately
        }
    }

    // ----------------- WebSocket Events -----------------
    onOpen() {
        //console.log(`OPEN:: WebSocket connected for user: ${this.fromUserId}`);

        // Clear any old interval before starting a new one
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
        }

        // Start heartbeat after connection opens
        this.heartbeatInterval = setInterval(() => {
            if (this.socket?.readyState === WebSocket.OPEN) {
                this.sendMessageViaSocket({
                    wsStatus: ChatWebSocket.wsStatus.HEARTBEAT,
                    fromUserId: this.fromUserId
                });
                //console.log("Heartbeat sent");
            }
        }, 3000); // every 3s
    }

    onClose() {
        this.socket = null;
        //console.log("ONCLOSE:: WebSocket disconnected");
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
            this.heartbeatInterval = null;
        }
    }

    onMessage(event) {
        const data = JSON.parse(event.data);
        //console.log("ONMESSAGE:: Received:", JSON.stringify(data));
        this.handleIncomingMessage(data);
    }

    onError(err) {
        //console.error("ONERROR:: WebSocket error for user2:", err);
    }

    // ----------------- Sending Messages -----------------
    sendMessageViaSocket(payload) {
        // Now sending via worker to utilize the
        // active websocket connection and avoid multiple connections issue
        // when multiple tabs are open for same user.
        // if (this.socket?.readyState === WebSocket.OPEN) {
        //     this.socket.send(JSON.stringify(payload));
        // }
        // using globalWorkerPort to send message to shared worker thread which will blast it over the active websocket connection to server and also to all connected tabs of same user.

        if (globalWorkerPort) {
            // Pass payload up to the Shared Worker thread to blast over the active WebSocket socket
            globalWorkerPort.postMessage({
                type: 'CHAT_MESSAGE',
                data: payload,
            });
        }
    }

    sendChatMessage(content) {
        const trimmed = content.trim();
        if (!trimmed) return;

        const msg = {
            wsStatus: ChatWebSocket.wsStatus.CHAT,
            conversationId: this.chatId,
            fromUserId: this.fromUserId,
            toUserId: this.toUserId,
            body: trimmed,
            fromUserName: this.fromUserName // Include sender's name in the message payload 
        }

        this.sendMessageViaSocket(msg);
        this.addMessageToUI(msg);//for current user msg addition to UI
        this.messageInput.value = "";
        this.hideTypingIndicator();
    }

    // ----------------- Incoming Message Handling -----------------
    handleIncomingMessage(data) {
        switch (data.wsStatus) {
            case ChatWebSocket.wsStatus.CHAT:
                this.addMessageToUI(data);
                break;
            case ChatWebSocket.wsStatus.TYPING_START:
                this.showTypingIndicator();
                break;
            case ChatWebSocket.wsStatus.TYPING_STOP:
                this.hideTypingIndicator();
                break;
            case ChatWebSocket.wsStatus.CONNECTED:
                //console.log(`${data.fromUserId} joined the chat`);
                break;
            case ChatWebSocket.wsStatus.DISCONNECTED:
                //console.log(`${data.fromUserId} left the chat`);
                break;
            default:
            //console.warn("Unknown message type:", data);
        }
    }

    // ----------------- UI Updates -----------------
    addMessageToUI(message, filesUploaded) {
        console.log("[chat.js] Adding message to UI:", message, filesUploaded);
        //hide typing indicator first.
        this.hideTypingIndicator();
        const isMe = message.fromUserId === this.fromUserId;

        const wrapper = document.createElement("div");
        wrapper.className = `message-wrapper mb-2 d-flex ${isMe ? "justify-content-end" : "justify-content-start"}`;

        const bubble = document.createElement("div");
        bubble.className = `d-inline-block message-bubble ${isMe ? "cr-bubble-sent" : "cr-bubble-received"}`;
        bubble.style.maxWidth = "70%";
        bubble.style.wordWrap = "break-word";

        // Sender name
        // if (message.senderName && !isMe) {
        //     const senderDiv = document.createElement("div");
        //     senderDiv.className = "message-sender small fw-bold mb-1 text-primary";
        //     senderDiv.textContent = message.senderName;
        //     bubble.appendChild(senderDiv);
        // }

        // Message content
        const contentDiv = document.createElement("div");
        contentDiv.className = "message-content";
        contentDiv.textContent = message.body;
        bubble.appendChild(contentDiv);


        // Media Grid: Lazy-load images and videos from mediaList
        if (filesUploaded && filesUploaded.length > 0) {
            const mediaGrid = document.createElement("div");
            mediaGrid.className = "message-media-grid";

            filesUploaded.forEach((media) => {
                const placeholder = document.createElement("div");
                placeholder.className = "media-lazy-placeholder";
                placeholder.dataset.mediaId = media.mediaId;
                placeholder.dataset.mediaType = media.filetype;
                placeholder.dataset.fileName = media.filename;

                mediaGrid.appendChild(placeholder);
            });

            bubble.appendChild(mediaGrid);
        }

        // Time
        const timeDiv = document.createElement("div");
        timeDiv.className = `message-time small mt-1 ${isMe ? "text-white-50" : "text-muted"}`;
        timeDiv.textContent = isMe ? this.formatDateToCurrentTimeZone() : this.formatSentAtToCurrentTimeZone(`${message.sentAt}`);
        bubble.appendChild(timeDiv);

        wrapper.appendChild(bubble);
        //this.messagesContainer.appendChild(wrapper);
        this.messagesContainer.insertBefore(wrapper, this.typingIndicator); // Insert before typing indicator

        // Auto scroll
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
        //hide no messages placeholder if visible
        if (document.querySelectorAll('.message-wrapper').length > 0 && document.getElementById("noMessagesPlaceholder")) {
            document.getElementById("noMessagesPlaceholder").classList.add("d-none");
        }

        // Reinitialize media lazy loader for newly added media
        if (filesUploaded.length > 0) {
            MediaLoader.observeNewMedia();
        }
    }

    sendTypingEvent(typingType) {
        var msg = {
            conversationId: this.chatId,
            toUserId: this.toUserId
        }
        if (typingType == ChatWebSocket.wsStatus.TYPING_START) {
            msg.wsStatus = ChatWebSocket.wsStatus.TYPING_START;
        } else if (typingType == ChatWebSocket.wsStatus.TYPING_STOP) {
            msg.wsStatus = ChatWebSocket.wsStatus.TYPING_STOP;

        }
        this.sendMessageViaSocket(msg);
    }

    showTypingIndicator() {
        this.typingIndicator.classList.remove("d-none");
        // Auto scroll
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }

    hideTypingIndicator() {
        this.typingIndicator.classList.add("d-none");
    }

    // ----------------- Event Bindings -----------------
    bindInputEvents() {
        let isTyping = false;
        this.messageInput.addEventListener("input", () => {
            if (!isTyping) {
                this.sendTypingEvent(ChatWebSocket.wsStatus.TYPING_START);
                isTyping = true;
            }

            // Clear the previous timeout
            clearTimeout(this.typingTimeout);

            // Set a timeout to send TYPING_STOP after 1.5 seconds of inactivity
            this.typingTimeout = setTimeout(() => {
                this.sendTypingEvent(ChatWebSocket.wsStatus.TYPING_STOP);
                isTyping = false;
            }, 2000);
        });

    }

    bindFormEvents() {
        const form = this.messageForm;
        form.addEventListener("submit", (e) => {
            e.preventDefault();

            // Check if media files are selected
            if (this.selectedMediaFiles && this.selectedMediaFiles.length > 0) {
                // Upload media first, then send message
                this.handleMediaUploadAndSend();
            } else {
                // Send text-only message
                this.sendChatMessage(this.messageInput.value);
                this.messageInput.value = "";
            }
        });
        this.messageInput.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault(); // prevent newline
                form.requestSubmit();   // trigger submit
            }
        });
    }

    // ─────── Media Upload Handlers ───────
    /**
     * Handle file selection for chat media attachment
     */
    bindMediaEvents() {
        const attachBtn = document.getElementById('attachMediaBtn');
        const chatMediaInput = document.getElementById('chatMediaInput');

        if (attachBtn) {
            attachBtn.addEventListener('click', (e) => {
                e.preventDefault();
                chatMediaInput?.click();
            });
        }

        if (chatMediaInput) {
            chatMediaInput.addEventListener('change', (e) => {
                const files = e.target.files; // Changed to handle multiple files
                if (!files || files.length === 0) return;

                // Get max file limit from data attribute (default: 5)
                const maxFiles = parseInt(chatMediaInput.dataset.maxFiles) || 5;
                
                // Check if file count exceeds limit
                if (files.length > maxFiles) {
                    showUploadError(`You can upload a maximum of ${maxFiles} files at a time. You selected ${files.length} files.`, 'chat');
                    chatMediaInput.value = '';
                    return;
                }

                // Clear previous selection
                this.selectedMediaFiles = [];

                // Validate and add all files
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];

                    // Validate file - only IMAGE and DOCUMENT types allowed
                    const validation = validateSelectedFile(file, 'CHAT_ATTACHMENT');
                    if (!validation.valid) {
                        showUploadError(validation.error, 'chat');
                        chatMediaInput.value = ''; // Reset input
                        this.selectedMediaFiles = []; // Clear all selected files
                        return;
                    }

                    // Only allow IMAGE, DOCUMENT, and VIDEO
                    if (validation.mediaType !== 'IMAGE' && validation.mediaType !== 'DOCUMENT' && validation.mediaType !== 'VIDEO') {
                        showUploadError('Only IMAGE and DOCUMENT files are supported for multiple upload', 'chat');
                        chatMediaInput.value = '';
                        this.selectedMediaFiles = [];
                        return;
                    }

                    // Add file to collection
                    this.selectedMediaFiles.push(file);
                }

                if (this.selectedMediaFiles.length === 0) {
                    chatMediaInput.value = '';
                    return;
                }

                // Show previews for all files
                this.displayMediaPreviews(this.selectedMediaFiles);
            });
        }
    }

    /**
     * Display previews of all selected media files with individual remove buttons
     */
    displayMediaPreviews(files) {
        const previewContainer = document.getElementById('mediaPreviewContainer');
        const mediaItemsList = document.getElementById('mediaItemsList');
        const previewImageArea = document.getElementById('mediaPreviewImageArea');

        if (!previewContainer || !mediaItemsList) return;

        // Clear previous items
        mediaItemsList.innerHTML = '';

        // Create individual preview items for each file
        files.forEach((file, index) => {
            const totalSizeKB = file.size / 1024;
            const fileSizeMB = totalSizeKB > 1024 ? (totalSizeKB / 1024).toFixed(2) + ' MB' : totalSizeKB.toFixed(2) + ' KB';

            // Create individual alert box for this file
            const itemAlert = document.createElement('div');
            itemAlert.className = 'alert alert-info small py-2 px-3 mb-0 d-flex justify-content-between align-items-center';
            itemAlert.style.gap = '10px';

            // File info span
            const fileInfoSpan = document.createElement('span');
            fileInfoSpan.className = 'text-truncate';
            fileInfoSpan.textContent = `${file.name} (${fileSizeMB})`;
            fileInfoSpan.title = file.name;

            // Individual remove button
            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'btn-close btn-sm flex-shrink-0';
            removeBtn.title = 'Remove this file';
            removeBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.removeMediaFile(index);
            });

            itemAlert.appendChild(fileInfoSpan);
            itemAlert.appendChild(removeBtn);
            mediaItemsList.appendChild(itemAlert);
        });

        // Show image previews only for image files
        if (previewImageArea) {
            previewImageArea.innerHTML = ''; // Clear previous previews

            let imageCount = 0;
            for (let i = 0; i < files.length && imageCount < 3; i++) {
                const file = files[i];
                if (file.type.startsWith('image/')) {
                    const reader = new FileReader();
                    reader.onload = (e) => {
                        const imgContainer = document.createElement('div');
                        imgContainer.style.display = 'inline-block';
                        imgContainer.style.marginRight = '8px';
                        imgContainer.innerHTML = `<img src="${e.target.result}" style="max-width: 80px; max-height: 80px; border-radius: 4px;">`;
                        previewImageArea.appendChild(imgContainer);
                    };
                    reader.readAsDataURL(file);
                    imageCount++;
                }
            }
        }

        // Show preview container
        previewContainer.classList.remove('d-none');
    }

    /**
     * Remove individual media file from selection
     * @param {number} fileIndex - Index of the file to remove
     */
    removeMediaFile(fileIndex) {
        if (fileIndex < 0 || fileIndex >= this.selectedMediaFiles.length) return;

        // Remove the file from array
        this.selectedMediaFiles.splice(fileIndex, 1);

        // If no files left, clear everything
        if (this.selectedMediaFiles.length === 0) {
            this.clearMediaSelection();
            return;
        }

        // Re-display previews with remaining files
        this.displayMediaPreviews(this.selectedMediaFiles);
    }

    /**
     * Clear selected media and hide preview
     */
    clearMediaSelection() {
        this.selectedMediaFiles = [];
        this.selectedMediaIds = [];

        const chatMediaInput = document.getElementById('chatMediaInput');
        if (chatMediaInput) {
            chatMediaInput.value = '';
        }

        const mediaItemsList = document.getElementById('mediaItemsList');
        if (mediaItemsList) {
            mediaItemsList.innerHTML = '';
        }

        const previewContainer = document.getElementById('mediaPreviewContainer');
        if (previewContainer) {
            previewContainer.classList.add('d-none');
        }

        resetUploadState('chat');
    }

    /**
     * Build metadata for uploaded files to be attached to message
     * @param {Array} initResults - Array of upload initialization results
     * @returns {Array} Array of file metadata objects with filename, filetype, and mediaId
     */
    buildUploadedFilesMetadata(initResults) {
        return initResults.map(uploadResult => {
            const validation = validateSelectedFile(uploadResult.file, 'CHAT_ATTACHMENT');

            return {
                filename: uploadResult.file.name,
                filetype: validation.mediaType,
                mediaId: uploadResult.mediaId
            };
        });
    }

    /**
     * Handle media upload followed by message send
     * Supports multiple files (IMAGE and DOCUMENT only) with parallel uploads
     */
    async handleMediaUploadAndSend() {
        // Validate files
        if (!this.selectedMediaFiles || this.selectedMediaFiles.length === 0) {
            this.sendChatMessage(this.messageInput.value);
            return;
        }

        this.isUploadingMedia = true;
        setUploadLoadingState('preparing', 'chat');
        const sendBtn = document.getElementById('sendButton');
        if (sendBtn) sendBtn.disabled = true;

        try {
            // Reset media IDs collection
            this.selectedMediaIds = [];

            // Step 1: Prepare all uploads (initMediaUpload in parallel)
            setUploadLoadingState('preparing', 'chat');
            showUploadError('', 'chat');

            const initPromises = this.selectedMediaFiles.map((file, index) => {
                const clientUploadId = generateClientUploadId();
                return initMediaUpload('CHAT_ATTACHMENT', clientUploadId, {
                    file: file,
                    conversationId: this.chatId
                }).then(initResponse => {
                    return {
                        fileIndex: index,
                        file: file,
                        mediaId: initResponse.mediaId,
                        uploadUrl: initResponse.uploadUrl,
                        clientUploadId: clientUploadId
                    };
                });
            });

            // Wait for all init calls to complete
            const initResults = await Promise.all(initPromises);
            //console.log('[chat.js] All media upload initializations completed:', initResults);
            // Step 2: Upload all files to S3 in parallel
            setUploadLoadingState('uploading', 'chat');
            const uploadPromisesArray = initResults.map(result => {
                return uploadFileToS3(result.uploadUrl, result.file, (progress) => {
                    setUploadLoadingState('uploading', 'chat');
                }).then(() => result); // Return result after upload completes
            });

            // Wait for all S3 uploads to complete
            const uploadResults = await Promise.all(uploadPromisesArray);

            // Step 3: Complete all uploads in parallel
            setUploadLoadingState('verifying', 'chat');
            const completePromises = initResults.map(result => {
                return completeMediaUpload(result.mediaId, result.clientUploadId);
            });

            // Wait for all completion calls
            const completeResults = await Promise.all(completePromises);
            //console.log('[chat.js] All media upload completeResults completed:', completeResults);

            // Step 4: Collect all media IDs
            let allMediasActive = true;
            const mediaIds = [];

            for (let i = 0; i < completeResults.length; i++) {
                if (completeResults[i].status === 'ACTIVE') {
                    mediaIds.push(initResults[i].mediaId);
                } else {
                    allMediasActive = false;
                    break;
                }
            }

            // Build uploaded file metadata for message
            const filesUploaded = this.buildUploadedFilesMetadata(initResults);

            if (allMediasActive && mediaIds.length > 0) {
                // Upload successful for all files
                showUploadSuccess(`${mediaIds.length} media files uploaded successfully!`, 'chat');

                // Convert mediaIds array to semicolon-separated string
                this.selectedMediaIds = mediaIds;
                const mediaIdString = mediaIds.join(';');
                
                //console.log('[chat.js] All media uploads completed successfully. Media IDs:', mediaIds);
               // console.log('[chat.js] Sending chat message with media IDs:', mediaIdString);
                
                // Send message with all mediaIds and uploaded file metadata
                this.sendChatMessageWithMedia(this.messageInput.value, mediaIdString, filesUploaded);

                // Clear UI
                setTimeout(() => {
                    this.clearMediaSelection();
                    this.messageInput.value = '';
                }, 500);
            } else {
                showUploadError('Some media uploads failed. Please try again.', 'chat');
            }
        } catch (error) {
            showUploadError(error || 'Upload failed. Please try again.', 'chat');

            // Allow retry
            if (this.selectedMediaIds.length > 0) {
                this.showMediaRetry(this.selectedMediaIds, null);
            }
        } finally {
            this.isUploadingMedia = false;
            if (sendBtn) sendBtn.disabled = false;
            setUploadLoadingState('completed', 'chat');
        }
    }

    /**
     * Send chat message with media attachment(s)
     * @param {string} content - Message text content
     * @param {string|number} mediaIds - Single mediaId or semicolon-separated mediaIds string
     * @param {Array} filesUploaded - Array of uploaded file details
     */
    sendChatMessageWithMedia(content, mediaIds, filesUploaded) {
        const trimmed = content.trim();

        const msg = {
            wsStatus: ChatWebSocket.wsStatus.CHAT,
            conversationId: this.chatId,
            fromUserId: this.fromUserId,
            toUserId: this.toUserId,
            body: trimmed || 'Media attachment(s)', // Fallback text if no message content
            mediaIds: mediaIds, // Can be single ID or semicolon-separated string
            fromUserName: this.fromUserName
        };

        this.sendMessageViaSocket(msg);
        this.addMessageToUI(msg, filesUploaded);
        this.hideTypingIndicator();
    }

    /**
     * Show retry option for failed verification
     */
    showMediaRetry(mediaIds, clientUploadId) {
        // Could implement a retry button in UI here
        // mediaIds can be an array or string
        // For now, user can click send again to retry
    }

    formatSentAtToCurrentTimeZone(sentAt) {
        if (!sentAt) return "";
        //convert UTC date to local timezone.
        return new Date(sentAt).toLocaleString(undefined, {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            hour12: true
        });
    }

    formatDateToCurrentTimeZone() {
        //convert UTC date to local timezone.
        return new Date().toLocaleString(undefined, {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            hour12: true
        });
    }
}

// ----------------- Usage -----------------
// document.addEventListener("DOMContentLoaded", () => {
//     //console.log("DOM fully loaded and parsed");

//     const chatId = "ccc62744-ed5c-40f3-87ef-0d2306cf64db_CONV";
//     const fromUserId = "64e56c5e-0b32-40db-a5b5-44fc0890f760_USER";
//     const toUserId = "112b486a-ac7b-4cab-8058-fcfb0a82a774_USER";
//     const token =
//         "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWQiOiI2NGU1NmM1ZS0wYjMyLTQwZGItYTViNS00NGZjMDg5MGY3NjBfVVNFUiIsImVtYWlsIjoiYWJoaW5hdi5zaW5naDcxOTkzQGdtYWlsLmNvbSIsInN1YiI6Ijk5NTM4Nzc0MTIiLCJpYXQiOjE3NTU2ODg0MjcsImV4cCI6MTc1NTY5MjAyN30.GQ7U15b0qwQY197mSo9c2_F2UcZ-uVyEJvpAaQl1C9M";

//     const chatWs = new ChatWebSocket(chatId, fromUserId, toUserId, token);
//     chatWs.connect();
//     chatWs.bindInputEvents();
// });

//info***
// Your WebSocket disconnects because web browsers automatically destroy
// the JavaScript runtime environment of a page when you navigate away