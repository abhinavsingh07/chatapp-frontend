
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
    }

    // not calling WebSocket Lifecycle from chatroom directly, instead calling from shared worker 
    // to utilize the active websocket connection and avoid multiple 
    // connections issue when multiple tabs are open for same user.    
    // ----------------- WebSocket Lifecycle -----------------

    connect() {
        //and jwt goes with cookie, so no need to send it explicitly in the WebSocket connection URL or headers. The server can extract the JWT from the cookie during the WebSocket handshake and use it for authentication and authorization.
        const wsUrl = `ws://localhost:8080/synk/ws/chat`;
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
        wrapper.className = `message-wrapper mb-3 ${isMe ? "text-end" : ""}`;

        const bubble = document.createElement("div");
        bubble.className = `d-inline-block message-bubble ${isMe ? "bg-primary text-white" : "bg-white border"} rounded-3 p-3 shadow-sm`;
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
            toUserId: this.toUserId,
            fromUserName: this.fromUserName
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
            this.sendChatMessage(this.messageInput.value);
            this.messageInput.value = "";
        });
        this.messageInput.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault(); // prevent newline
                form.requestSubmit();   // trigger submit
            }
        });
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