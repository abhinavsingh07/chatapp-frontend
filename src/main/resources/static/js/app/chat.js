
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
        this.selectedMediaFile = null;
        this.selectedMediaId = null;
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
    addMessageToUI(message) {
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

        // Media attachment (if mediaId present)
        if (message.mediaId) {
            const mediaDiv = document.createElement("div");
            mediaDiv.className = "message-media mt-2";
            
            // Display media placeholder/loading state
            // In production, you'd fetch presigned URL using getPresignedDownloadUrl(mediaId)
            const mediaPlaceholder = document.createElement("div");
            mediaPlaceholder.className = "alert alert-info small py-1 px-2 mb-0";
            mediaPlaceholder.innerHTML = '<i class="fas fa-image me-1"></i> Media attached (mediaId: ' + message.mediaId + ')';
            mediaDiv.appendChild(mediaPlaceholder);
            
            bubble.appendChild(mediaDiv);
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
            
            // Check if media file is selected
            if (this.selectedMediaFile) {
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
        const removeMediaBtn = document.getElementById('removeMediaBtn');

        if (attachBtn) {
            attachBtn.addEventListener('click', (e) => {
                e.preventDefault();
                chatMediaInput?.click();
            });
        }

        if (chatMediaInput) {
            chatMediaInput.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (!file) return;

                // Validate file
                const validation = validateSelectedFile(file, 'CHAT_MESSAGE');
                if (!validation.valid) {
                    showUploadError(validation.error, 'chat');
                    chatMediaInput.value = ''; // Reset input
                    return;
                }

                // Store selected file
                this.selectedMediaFile = file;

                // Show preview
                this.displayMediaPreview(file);
            });
        }

        if (removeMediaBtn) {
            removeMediaBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.clearMediaSelection();
            });
        }
    }

    /**
     * Display preview of selected media file
     */
    displayMediaPreview(file) {
        const previewContainer = document.getElementById('mediaPreviewContainer');
        const previewText = document.getElementById('mediaPreviewText');
        const previewImageArea = document.getElementById('mediaPreviewImageArea');

        if (!previewContainer) return;

        // Format file size
        const fileSizeKB = (file.size / 1024).toFixed(2);
        const fileSizeMB = fileSizeKB > 1024 ? (file.size / 1024 / 1024).toFixed(2) + ' MB' : fileSizeKB + ' KB';

        // Update preview text
        if (previewText) {
            previewText.textContent = file.name + ' (' + fileSizeMB + ')';
        }

        // Show image preview for image files
        if (file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = (e) => {
                if (previewImageArea) {
                    previewImageArea.innerHTML = `<img src="${e.target.result}" style="max-width: 100%; max-height: 180px; border-radius: 6px;">`;
                }
            };
            reader.readAsDataURL(file);
        }

        // Show preview container
        previewContainer.classList.remove('d-none');
    }

    /**
     * Clear selected media and hide preview
     */
    clearMediaSelection() {
        this.selectedMediaFile = null;
        this.selectedMediaId = null;

        const chatMediaInput = document.getElementById('chatMediaInput');
        if (chatMediaInput) {
            chatMediaInput.value = '';
        }

        resetUploadState('chat');
    }

    /**
     * Handle media upload followed by message send
     */
    async handleMediaUploadAndSend() {
        if (!this.selectedMediaFile) {
            this.sendChatMessage(this.messageInput.value);
            return;
        }

        this.isUploadingMedia = true;
        setUploadLoadingState('preparing', 'chat');
        const sendBtn = document.getElementById('sendButton');
        if (sendBtn) sendBtn.disabled = true;

        try {
            const clientUploadId = generateClientUploadId();

            // Step 1: Initialize upload
            setUploadLoadingState('preparing', 'chat');
            showUploadError('', 'chat'); // Clear any previous errors
            
            const initResponse = await initMediaUpload('CHAT_MESSAGE', clientUploadId, {
                file: this.selectedMediaFile,
                conversationId: this.chatId
            });

            this.selectedMediaId = initResponse.mediaId;

            // Step 2: Upload to S3
            setUploadLoadingState('uploading', 'chat');
            await uploadFileToS3(initResponse.uploadUrl, this.selectedMediaFile, (progress) => {
                // Progress callback
                setUploadLoadingState('uploading', 'chat');
            });

            // Step 3: Complete upload
            setUploadLoadingState('verifying', 'chat');
            const completeResponse = await completeMediaUpload(this.selectedMediaId, clientUploadId);

            if (completeResponse.status === 'ACTIVE') {
                // Upload successful, send message with mediaId
                showUploadSuccess('Media uploaded successfully!', 'chat');
                
                // Send message with mediaId
                this.sendChatMessageWithMedia(this.messageInput.value, this.selectedMediaId);
                
                // Clear UI
                setTimeout(() => {
                    this.clearMediaSelection();
                    this.messageInput.value = '';
                }, 500);
            } else {
                showUploadError('Media status is not ACTIVE. Please try again.', 'chat');
            }
        } catch (error) {
            showUploadError(error || 'Upload failed. Please try again.', 'chat');
            
            // Allow retry
            if (this.selectedMediaId) {
                this.showMediaRetry(this.selectedMediaId, clientUploadId);
            }
        } finally {
            this.isUploadingMedia = false;
            if (sendBtn) sendBtn.disabled = false;
            setUploadLoadingState('completed', 'chat');
        }
    }

    /**
     * Send chat message with media attachment
     */
    sendChatMessageWithMedia(content, mediaId) {
        const trimmed = content.trim();

        const msg = {
            wsStatus: ChatWebSocket.wsStatus.CHAT,
            conversationId: this.chatId,
            fromUserId: this.fromUserId,
            toUserId: this.toUserId,
            body: trimmed || '[Image/Media attachment]',
            mediaId: mediaId,
            fromUserName: this.fromUserName
        };

        this.sendMessageViaSocket(msg);
        this.addMessageToUI(msg);
        this.hideTypingIndicator();
    }

    /**
     * Show retry option for failed verification
     */
    showMediaRetry(mediaId, clientUploadId) {
        // Could implement a retry button in UI here
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