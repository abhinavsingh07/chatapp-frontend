let ws = null;
const connectedPorts = new Set();
let chatManagerInstance = null;


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
        if (
            this.socket &&
            (
                this.socket.readyState === WebSocket.OPEN ||
                this.socket.readyState === WebSocket.CONNECTING
            )
        ) {
            console.log("WebSocket is already connected or connecting");
            return;
        }

        this.socket = new WebSocket(wsUrl);
        ws = this.socket; // Update the global ws reference for the worker's lifecycle management

        //websocket lifecycle events
        this.socket.onopen = () => this.onOpen();
        this.socket.onmessage = (event) => this.onMessage(event);
        this.socket.onclose = (event) => this.onClose(event);
        this.socket.onerror = (err) => this.onError(err);
    }

    disconnect() {
        // Allow closing during CONNECTING or OPEN states
        if (
            this.socket &&
            (
                this.socket.readyState === WebSocket.OPEN ||
                this.socket.readyState === WebSocket.CONNECTING
            )
        ) {
            console.log("Disconnecting WebSocket...");
            this.socket.close(1000, "User left chat");
        }

        this.clearSocketReferences();
    }

    clearSocketReferences() {
        this.socket = null;
        ws = null; // Clear global reference
    }

    clearHeartbeat() {
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
            this.heartbeatInterval = null;
        }
    }

    startHeartbeat() {
        this.clearHeartbeat();

        // Start heartbeat after connection opens
        this.heartbeatInterval = setInterval(() => {
            if (this.socket?.readyState === WebSocket.OPEN) {
                this.sendMessageViaSocket({
                    wsStatus: chatWebSocketManager.wsStatus.HEARTBEAT,
                    fromUserId: this.fromUserId
                });
                //console.log("Heartbeat sent");
            }
        }, 3000); // every 3s
    }

    // ----------------- WebSocket Events -----------------
    onOpen() {
        console.log(`OPEN:: WebSocket connected for user: ${this.fromUserId}`);

        // Clear any old interval before starting a new one
        this.clearHeartbeat();
        this.startHeartbeat();
    }

    onClose(event) {
        this.clearSocketReferences();
        console.log("ONCLOSE:: WebSocket disconnected", event);

        this.clearHeartbeat();
    }

    //receiving msg from server via websocket and broadcasting to all connected JSP pages/tabs
    onMessage(event) {
        try {
            const payload = JSON.parse(event.data);
            console.log("[Worker] Received message from WebSocket onMessage event::" + event.data + " broadcasting to jsp pages...");

            // Broadcast the incoming message payload to ALL active JSP pages/tabs
            connectedPorts.forEach((port) => {
                port.postMessage({ type: "CHAT_MESSAGE", data: payload });
            });
        } catch (e) {
            console.error("[Worker] Failed to parse JSON message", e);
        }
    }

    onError(err) {
        //console.error("ONERROR:: WebSocket error for user2:", err);
    }

    sendMessageViaSocket(payload) {
        if (this.socket?.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify(payload));
            return true;
        }

        return false;
    }

    isSocketActive() {
        return (
            this.socket &&
            (
                this.socket.readyState === WebSocket.OPEN ||
                this.socket.readyState === WebSocket.CONNECTING
            )
        );
    }
}


// Global lifecycle event handler when a JSP page initializes a connection to this worker
self.onconnect = (event) => {
    const port = event.ports[0];
    connectedPorts.add(port);

    console.group("self.onconnect event triggered");
    console.log("New port connected. Total connected ports:", connectedPorts.size);
    console.groupEnd();

    // Handle incoming commands sent from a specific JSP page to the worker
    port.onmessage = (e) => {
        const message = e.data;

        if (!message || !message.type) {
            console.warn("[Worker] Invalid message received from port:", message);
            return;
        }

        if (message.type === "PORT_UNLOAD") {
            connectedPorts.delete(port);
            chatManagerInstance.disconnect();
            chatManagerInstance = null;

            console.log("[Worker] PORT_UNLOAD received. Port removed. Remaining ports:", connectedPorts.size);
        } else if (message.type === "WS_CONNECT") {
            //calling this block from header.jsp to initialize the websocket connection when user opens any page of the application for the first time, and then the same connection will be utilized for all other pages/tabs of the same user.
            if (!chatManagerInstance) {
                console.log("[Worker] Received WS_CONNECT command. Initializing WebSocket connection...");
                chatManagerInstance = new chatWebSocketManager(message.data.fromUserId);
                chatManagerInstance.connect();
            } else if (!chatManagerInstance.isSocketActive()) {
                console.log("[Worker] WebSocket manager exists but socket is inactive. Reconnecting...");
                chatManagerInstance.connect();
            } else {
                console.log("[Worker] WebSocket is already connected or connecting.");
            }
        } else if (message.type === "CHAT_MESSAGE") {
            // If a user types and sends a message from the chat screen, forward it to the server
            // calling globalWorkerPort.postMessage from chat.js which is sending message typed by user in
            // chat screen to this worker, and then this worker will forward that message to server
            // via websocket.
            if (chatManagerInstance && chatManagerInstance.sendMessageViaSocket(message.data)) {
                console.log("[Worker] Forwarded CHAT_MESSAGE to server via WebSocket:", JSON.stringify(message));
            } else {
                console.error("[Worker] Cannot send message, WebSocket is not open.");
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