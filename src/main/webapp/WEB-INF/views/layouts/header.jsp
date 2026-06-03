<!-- Navigation -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
            <i class="fas fa-comments me-2"></i>ChatApp
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link {% if request.endpoint == 'chat_list' %}active{% endif %}"
                        href="${pageContext.request.contextPath}/home">
                        <i class="fas fa-home me-1"></i>Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {% if request.endpoint == 'contacts' %}active{% endif %}"
                        href="${pageContext.request.contextPath}/contacts">
                        <i class="fas fa-users me-1"></i>Contacts
                    </a>
                </li>
            </ul>

            <!-- Search Form -->
            <form class="d-flex me-3" action="${pageContext.request.contextPath}/search" method="GET">
                <div class="input-group">
                    <input class="form-control" type="search" name="q" placeholder="Search..." aria-label="Search">
                    <button class="btn btn-outline-light" type="submit">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </form>

            <!-- User Menu -->
            <div class="dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                    <i class="fas fa-user-circle me-1"></i>
                    <c:if test="${not empty username}">
                        <span>Hello! ${username}!</span>
                    </c:if>
                </a>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                            <i class="fas fa-user me-2"></i>Profile
                        </a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/settings">
                            <i class="fas fa-cog me-2"></i>Settings
                        </a></li>
                    <li>
                        <hr class="dropdown-divider">
                    </li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                        </a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>
<%@ include file="/WEB-INF/views/common.jsp" %>
    <script>
        //these values available for all pages as header is common in all pages.
        const ctx = "<c:out value='${ctx}'/>";//getting from commons.jsp
        const userId = "<c:out value='${userid}'/>"; //getting from commons.jsp
        const username = "<c:out value='${username}'/>"; //getting from request setting in jwt filter.
        // 1. In-App Notification comes
        function sendInAppNotification(title, messageBody, redirectUrl, showFullMsgInBody) {
            if (Notification.permission === "granted") {
                const options = {
                    body: showFullMsgInBody ? messageBody : "",
                    icon: `${ctx}/icons/message-notify.png`,
                    tag: "chat-alert" + new Date().getTime(), // unique tag to allow multiple notifications
                    renotify: true
                };

                const notification = new Notification(title, options);
                notification.onclick = () => {
                    window.focus();
                    window.location.href = redirectUrl;
                };
            }
        }

        /** Below whole code for shared worker integration and chat flow**/
        // 2. Shared Worker Integration Setup
        let globalWorkerPort = null;

        if (window.SharedWorker) {
            // Resolve absolute path using context path
            const workerPath = "${pageContext.request.contextPath}/js/app/ws-worker.js";
            const myWorker = new SharedWorker(workerPath,"app-websocket-worker");

            globalWorkerPort = myWorker.port;
            globalWorkerPort.start();

            // Listen for incoming global WebSocket broadcasts from the worker
            // when  port.postMessage calls in worker with type CHAT_MESSAGE, this onmessage will be triggered in all tabs and then
            // we can decide what to do based on current page context
            globalWorkerPort.onmessage = function (event) {
                const messageType = event.data.type;
                const payload = event.data.data;
                const { wsStatus, fromUserName, conversationId, toUserId, body } = payload;

                console.log("[Main Thread] Received message from worker globalWorkerPort.onmessage event.data::" + JSON.stringify(event.data));
                if (messageType === 'CHAT_MESSAGE') {
                    // Determine current page context
                    const isChatPage = window.location.pathname.includes("chat-room");
                    // If on chat screen, delegate to a local page function to render the message bubble
                    if (isChatPage) {
                        //show typing start or stop
                        if (wsStatus === "TYPING_START") {
                            showTypingIndicator();
                            console.log("[Main Thread] Showing typing indicator based on incoming message payload:" + JSON.stringify(payload));
                            return;
                        } else if (wsStatus === "TYPING_STOP") {
                            hideTypingIndicator();
                            console.log("[Main Thread] Hiding typing indicator based on incoming message payload:" + JSON.stringify(payload));
                            return;
                        } else if (wsStatus == "CHAT" && typeof handleIncomingChatMessageUI === "function") {
                            //if it's a chat message with wsStatus CHAT, then delegate to handleIncomingChatMessageUI function to render the message bubble in UI.
                            handleIncomingChatMessageUI(payload);
                            console.log("[Main Thread] Delegated incoming message to handleIncomingChatMessageUI function on chat page with payload:" + JSON.stringify(payload));
                        }

                    } else {

                        if (wsStatus == "CHAT") {
                            //for notification payload construction
                            const redirecturl = `${ctx}/chat-room/` + conversationId + `/` + toUserId;
                            const notificationTitle = "New message from " + fromUserName;
                            const notificationBody = body.length > 50 ? body.substring(0, 47) + "..." : body;
                            //not on chat screen trigger notification for new incoming message
                            // Get the message preview preference from localStorage (default to false)
                            const showFullMsg = localStorage.getItem('showFullMsgInBody') === 'true';
                            sendInAppNotification(notificationTitle, notificationBody, redirecturl, showFullMsg);
                            console.log("[Main Thread] Triggered in-app notification for incoming message on non-chat page with payload:" + JSON.stringify(payload));
                        }

                    }
                }
            };

            // Prompt worker to clean up active port allocation right before page reloads/navigates
            window.addEventListener('beforeunload', () => {
                globalWorkerPort.postMessage({ type: 'PORT_UNLOAD' });
            });

            // Request notification permissions gracefully via UI actions elsewhere
            if (Notification.permission === "default") {
                console.log("Call Notification.requestPermission() via a user action to enable alerts.");
            }
        } else {
            console.error("Shared Workers are not supported in this browser legacy engine.");
        }

        function handleIncomingChatMessageUI(message) {
            let messagesContainer = document.getElementById("messagesContainer");
            let typingIndicator = document.getElementById("typingIndicator");
            //hide typing indicator first.
            hideTypingIndicator();
            const isMe = message.fromUserId === userId;

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
            timeDiv.textContent = isMe ? formatDateToCurrentTimeZone() : formatSentAtToCurrentTimeZone(`${message.sentAt}`);
            bubble.appendChild(timeDiv);

            wrapper.appendChild(bubble);
            //this.messagesContainer.appendChild(wrapper);
            if (messagesContainer) {
                messagesContainer.insertBefore(wrapper, typingIndicator); // Insert before typing indicator
                // Auto scroll
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
                //hide no messages placeholder if visible
                if (document.querySelectorAll('.message-wrapper').length > 0 && document.getElementById("noMessagesPlaceholder")) {
                    document.getElementById("noMessagesPlaceholder").classList.add("d-none");
                }
            }
        }

        function formatDateToCurrentTimeZone() {
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

        function formatSentAtToCurrentTimeZone(sentAt) {
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

        function showTypingIndicator() {
            let typingIndicator = document.getElementById("typingIndicator");
            if (typingIndicator) {
                typingIndicator.classList.remove("d-none");
            }
            let messagesContainer = document.getElementById("messagesContainer");
            if (messagesContainer) {
                // Auto scroll
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
        }

        function hideTypingIndicator() {
            let typingIndicator = document.getElementById("typingIndicator");
            if (typingIndicator) {
                typingIndicator.classList.add("d-none");
            }
        }

        //init websocket for user.
        document.addEventListener("DOMContentLoaded", function () {
            if (globalWorkerPort) {
                // Pass payload up to the Shared Worker thread to blast over the active WebSocket socket
                globalWorkerPort.postMessage({
                    type: 'WS_CONNECT',
                    data: { fromUserId: userId }
                });
            }
        });
    </script>