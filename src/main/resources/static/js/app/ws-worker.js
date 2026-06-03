let ws = null;
const connectedPorts = new Set();

class chatWebSocketManager {

    static wsStatus = {
        CONNECTED: "CONNECTED",
        CHAT: "CHAT",
        TYPING_START: "TYPING_START",
        TYPING_STOP: "TYPING_STOP",
        DISCONNECTED: "DISCONNECTED",
        HEARTBEAT: "HEARTBEAT",
        PRESENCE_UPDATE: "PRESENCE_UPDATE"
    };

    constructor(fromUserId) {
        this.fromUserId = fromUserId;
        this.heartbeatInterval = null;
        this.socket = null;
    }

    connect() {
        //and jwt goes with cookie, so no need to send it explicitly in the WebSocket connection URL or headers. The server can extract the JWT from the cookie during the WebSocket handshake and use it for authentication and authorization.
        const wsUrl = `ws://localhost:8080/synk/ws/chat`;
        // Check if socket exists and is still open or connecting
        if (this.socket && (this.socket.readyState === WebSocket.OPEN || this.socket.readyState === WebSocket.CONNECTING)) {
            console.log("WebSocket is already connected or connecting");
            return;
        }

        this.socket = new WebSocket(wsUrl);
        ws = this.socket; // Update the global ws reference for the worker's lifecycle management
        //websocket lifecycle events
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
            ws = null; // Clear global reference
        }
    }

    // ----------------- WebSocket Events -----------------
    onOpen() {
        console.log(`OPEN:: WebSocket connected for user: ${this.fromUserId}`);
        // Clear any old interval before starting a new one
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
        }

        // Start heartbeat after connection opens
        this.heartbeatInterval = setInterval(() => {
            if (ws?.readyState === WebSocket.OPEN) {
                this.sendMessageViaSocket({
                    wsStatus: chatWebSocketManager.wsStatus.HEARTBEAT,
                    fromUserId: this.fromUserId
                });
                //console.log("Heartbeat sent");
            }
        }, 3000); // every 3s
    }

    onClose() {
        this.socket = null;
        ws = null;
        console.log("ONCLOSE:: WebSocket disconnected");
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
            this.heartbeatInterval = null;
        }
    }
    //receiving msg from server via websocket and broadcasting to all connected JSP pages/tabs
    onMessage(event) {
        try {

            const payload = JSON.parse(event.data);
            console.log("[Worker] Received message from WebSocket onMessage event::" + event.data);
            // Broadcast the incoming message payload to ALL active JSP pages/tabs
            connectedPorts.forEach(port => {
                port.postMessage({ type: 'CHAT_MESSAGE', data: payload });
            });

        } catch (e) {
            console.error("[Worker] Failed to parse JSON message", e);
        }
    }

    onError(err) {
        //console.error("ONERROR:: WebSocket error for user2:", err);
    }

    sendMessageViaSocket(payload) {
        if (ws?.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify(payload));
        }
    }
}

// Global lifecycle event handler when a JSP page initializes a connection to this worker
self.onconnect = (event) => {
    const port = event.ports[0];
    connectedPorts.add(port);
    console.group("self.onconnect event triggered");
    console.log("New port connected. Total connected ports:", connectedPorts.size);

    // Handle incoming commands sent from a specific JSP page to the worker
    port.onmessage = (e) => {
        const message = e.data;
        if (message.type === 'DISCONNECT') {
            connectedPorts.delete(port);
        } else if (message.type === 'CHAT_MESSAGE') {
            // If a user types and sends a message from the chat screen, forward it to the server
            // calling globalWorkerPort.postMessage from chat.js which is sending message typed by user in
            // chat screen to this worker, and then this worker will forward that message to server
            // via websocket.
            if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify(message.data));//sending msg via websocket from here
                console.log("[Worker] Forwarded CHAT_MESSAGE to server via WebSocket:", JSON.stringify(message));
            } else {
                console.error("[Worker] Cannot send message, WebSocket is not open.");
            }
        } else if (message.type == 'WS_CONNECT') {
            //calling this block from header.jsp to initialize the websocket connection when user opens any page of the application for the first time, and then the same connection will be utilized for all other pages/tabs of the same user.
            if (ws === null) {
                //new chatWebSocketManager(userId).connect();
                console.log("[Worker] Received WS_CONNECT command. Initializing WebSocket connection...");
                const chatManager = new chatWebSocketManager(message.data.fromUserId);
                chatManager.connect();
            }
        }
    };

    port.start();
};

//what is self?
//In standard browser JavaScript, the global execution context is window. However, Workers do not have access to the webpage DOM or the window object.
//What is self.onconnect?
//Think of self.onconnect as a listener waiting for a webpage to plug into the worker.
//A port is a two-way radio communication channel between a specific JSP page and the Shared Worker.
// Page to Worker: When the page calls globalWorkerPort.postMessage(),
// the data travels through this port into the worker's port.onmessage listener.
// Worker to Page: When the worker calls port.postMessage(),
// the data travels backward through the pipe into the webpage's myWorker.port.onmessage listener.