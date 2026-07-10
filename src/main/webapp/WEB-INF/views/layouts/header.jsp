<%@ include file="/WEB-INF/views/common.jsp" %>
    <%-- Navigation. Protected: id="navbarNav" , data-bs-toggle/target, all href EL, username EL --%>
        <nav class="cs-navbar navbar navbar-expand-lg sticky-top">
            <div class="container-fluid px-3 px-lg-4">

                <%-- Brand --%>
                    <a class="cs-brand navbar-brand" href="${pageContext.request.contextPath}/home">
                        <div class="cs-brand-icon">
                            <i class="fas fa-comments"></i>
                        </div>
                        <span class="cs-brand-name">ChatSphere</span>
                    </a>

                    <%-- Mobile toggler — Protected: data-bs-toggle, data-bs-target="#navbarNav" --%>
                        <button class="cs-toggler navbar-toggler border-0 shadow-none" type="button"
                            data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav"
                            aria-expanded="false" aria-label="Toggle navigation">
                            <i class="fas fa-bars"></i>
                        </button>

                        <%-- Protected: id="navbarNav" --%>
                            <div class="collapse navbar-collapse" id="navbarNav">

                                <%-- Primary nav links --%>
                                    <ul class="navbar-nav me-auto gap-1">
                                        <li class="nav-item">
                                            <%-- Protected: href URL mapping --%>
                                                <a class="cs-nav-link nav-link"
                                                    href="${pageContext.request.contextPath}/home">
                                                    <i class="fas fa-home"></i>
                                                    <span>Home</span>
                                                </a>
                                        </li>
                                        <li class="nav-item">
                                            <%-- Protected: href URL mapping --%>
                                                <a class="cs-nav-link nav-link"
                                                    href="${pageContext.request.contextPath}/contacts">
                                                    <i class="fas fa-users"></i>
                                                    <span>Contacts</span>
                                                </a>
                                        </li>
                                    </ul>

                                    <%-- User dropdown. Protected: data-bs-toggle="dropdown" , username EL --%>
                                        <div class="dropdown ms-auto ms-lg-0">
                                            <button
                                                class="cs-user-btn btn dropdown-toggle d-flex align-items-center gap-2"
                                                type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                <div class="cs-user-avatar">
                                                    <c:if test="${not empty userMediaId}">
                                                        <div class="ch-avatar-wrap">
                                                            <div data-user-media-id="${userMediaId}"
                                                                data-user-id="${userId}" data-profile-picture="true">
                                                            </div>
                                                        </div>

                                                    </c:if>
                                                    <c:if test="${empty userMediaId}">
                                                        <c:choose>
                                                            <c:when test="${not empty username}">
                                                                <%-- Show first letter of username as avatar initial
                                                                    --%>
                                                                    <span
                                                                        class="cs-user-initial">${fn:substring(username,0,1)}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fas fa-user" style="font-size:0.75rem;"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </div>
                                                <c:if test="${not empty username}">
                                                    <span class="cs-user-name d-none d-lg-inline">
                                                        <c:out value='${username}' />
                                                    </span>
                                                </c:if>
                                            </button>
                                            <ul
                                                class="dropdown-menu dropdown-menu-end cs-dropdown shadow border-0 py-1 mt-2">
                                                <c:if test="${not empty username}">
                                                    <li class="cs-dropdown-header px-3 py-2">
                                                        <div class="d-flex align-items-center gap-2">
                                                            <div class="cs-user-avatar cs-user-avatar--lg">
                                                                <span
                                                                    class="cs-user-initial">${fn:substring(username,0,1)}</span>
                                                            </div>
                                                            <div>
                                                                <div class="fw-semibold small">
                                                                    <c:out value='${username}' />
                                                                </div>
                                                                <div class="text-muted" style="font-size:0.7rem;">Online
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                    <li>
                                                        <hr class="dropdown-divider my-1">
                                                    </li>
                                                </c:if>
                                                <li>
                                                    <%-- Protected: href URL mapping --%>
                                                        <a class="dropdown-item cs-dropdown-item"
                                                            href="${pageContext.request.contextPath}/profile">
                                                            <i class="fas fa-user text-primary"></i>
                                                            <span>Profile</span>
                                                        </a>
                                                </li>
                                                <li>
                                                    <%-- Protected: href URL mapping --%>
                                                        <a class="dropdown-item cs-dropdown-item"
                                                            href="${pageContext.request.contextPath}/settings">
                                                            <i class="fas fa-cog text-secondary"></i>
                                                            <span>Settings</span>
                                                        </a>
                                                </li>
                                                <li>
                                                    <hr class="dropdown-divider my-1">
                                                </li>
                                                <li>
                                                    <%-- Protected: href URL mapping --%>
                                                        <a class="dropdown-item cs-dropdown-item cs-dropdown-item--danger"
                                                            href="${pageContext.request.contextPath}/logout">
                                                            <i class="fas fa-sign-out-alt"></i>
                                                            <span>Logout</span>
                                                        </a>
                                                </li>
                                            </ul>
                                        </div>

                            </div><%-- /#navbarNav --%>
            </div>
        </nav>
        <%-- Theme init: runs early to apply saved theme before page paint, preventing flash --%>
            <script
                nonce="${cspNonce}">(function () { var t = localStorage.getItem('cs-theme'); if (t === 'dark') document.body.classList.add('theme-dark'); }());</script>
            <script nonce="${cspNonce}">
                //these values available for all pages as header is common in all pages.
                const ctx = "<c:out value='${ctx}'/>";//getting from commons.jsp
                const userId = "<c:out value='${userid}'/>"; //getting from commons.jsp
                const username = "<c:out value='${username}'/>"; //getting from request setting.
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
                    const myWorker = new SharedWorker(workerPath, "app-websocket-worker");

                    globalWorkerPort = myWorker.port;
                    globalWorkerPort.start();

                    // Listen for incoming global WebSocket broadcasts from the worker
                    // when  port.postMessage calls in worker with type CHAT_MESSAGE, this onmessage will be triggered in all tabs and then
                    // we can decide what to do based on current page context
                    globalWorkerPort.onmessage = function (event) {
                        const messageType = event.data.type;
                        const payload = event.data.data;
                        const { wsStatus, fromUserName, conversationId, toUserId, fromUserId, body } = payload;

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
                                    const redirecturl = `${ctx}/chat-room/` + conversationId + `/` + fromUserId;
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
                    // Media attachments (if mediaIds present as comma-separated string)
                    if (message.mediaIds && message.mediaIds.trim() !== '') {
                        const mediaGrid = document.createElement("div");
                        mediaGrid.className = "message-media-grid";
                        bubble.appendChild(mediaGrid);

                        const mediaIdList = message.mediaIds.split(";").map(function (id) { return id.trim(); }).filter(function (id) { return id; });
                        const convId = message.conversationId;

                        mediaIdList.forEach(function (mediaId) {
                            // Create placeholder immediately (loading state)
                            const placeholder = document.createElement("div");
                            placeholder.className = "media-lazy-placeholder";
                            placeholder.dataset.mediaId = mediaId;
                            placeholder.dataset.loading = "true";
                            placeholder.title = "Loading media...";
                            placeholder.innerHTML = '<div class="media-placeholder-spinner" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;min-height:60px;"><i class="fas fa-spinner fa-pulse" style="color:#6c757d;"></i></div>';
                            mediaGrid.appendChild(placeholder);

                            // Fetch media details from API
                            fetch(ctx + "/api/media/conversation/" + convId + "/media/" + mediaId, {
                                method: 'GET',
                                credentials: 'include'
                            })
                                .then(function (response) {
                                    if (!response.ok) {
                                        throw new Error('Failed to fetch media: ' + response.statusText);
                                    }
                                    return response.json();
                                })
                                .then(function (data) {
                                    if (data.responseCode === 'OK' && data.data && data.data.length > 0) {
                                        var mediaInfo = data.data[0];
                                        placeholder.dataset.mediaType = mediaInfo.mediaType || '';
                                        placeholder.dataset.fileName = mediaInfo.mediaName || mediaInfo.fileName || '';
                                        placeholder.dataset.presignedUrl = mediaInfo.presignedDownloadUrl || '';
                                        placeholder.dataset.loading = "false";
                                        placeholder.title = mediaInfo.mediaName || mediaInfo.fileName || 'Media';
                                        // Render preview based on media type
                                        renderMediaPlaceholder(placeholder, mediaInfo);
                                    } else {
                                        throw new Error('Invalid response data');
                                    }
                                })
                                .catch(function (err) {
                                    console.error("Failed to fetch media info for mediaId:", mediaId, err);
                                    placeholder.dataset.loading = "error";
                                    placeholder.title = "Failed to load media";
                                    placeholder.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;min-height:60px;color:#dc3545;font-size:0.75rem;"><i class="fas fa-exclamation-circle"></i>&nbsp;Load failed</div>';
                                });
                        });
                    }

                    // Time
                    const timeDiv = document.createElement("div");
                    timeDiv.className = `message-time small mt-1 ${isMe ? "text-white-50" : "text-muted"}`;
                    timeDiv.textContent = isMe ? formatDateToCurrentTimeZone() : formatSentAtToCurrentTimeZone(message.sentAt);
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

                /**
                 * Render media placeholder based on media type (IMAGE, VIDEO, DOCUMENT, etc.)
                 * @param {HTMLElement} placeholder - The placeholder DOM element
                 * @param {Object} mediaInfo - Media metadata from API response
                 */
                function renderMediaPlaceholder(placeholder, mediaInfo) {
                    placeholder.innerHTML = '';
                    if (MediaLoader && typeof MediaLoader.renderMedia === 'function') {
                        // Use MediaLoader utility to render media preview
                        MediaLoader.loadMediaForElement(placeholder);
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
                    console.log("formatSentAtToCurrentTimeZone header.jsp called with sentAt:*****", sentAt);
                    if (!sentAt) return "";
                    console.log("formatSentAtToCurrentTimeZone header.jsp called with sentAt:", sentAt);
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