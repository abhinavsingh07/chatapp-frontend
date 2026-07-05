<%@ include file="/WEB-INF/views/common.jsp" %>
    <div class="cr-layout">
        <div class="cr-header chat-header">

            <%-- Back button (mobile / browser history) --%>
                <button class="cr-header-btn js-back-button d-md-none" type="button" title="Back">
                    <i class="fas fa-arrow-left"></i>
                </button>

                <%-- Avatar --%>
                    <c:choose>
                        <c:when test="${not empty toUserDetails.profilePictureUrl}">
                            <img src="<c:out value='${toUserDetails.profilePictureUrl}'/>" alt="Avatar"
                                class="cr-header-avatar">
                        </c:when>
                        <c:otherwise>
                            <div class="cr-header-avatar-placeholder">
                                <i class="fas fa-users fa-sm"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <%-- Name + presence --%>
                        <div class="flex-grow-1 min-width-0">
                            <div class="cr-header-name">
                                <c:choose>
                                    <c:when test="${chat.group}">
                                        ${not empty chat.name ? chat.name : 'Group Chat'}
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${not empty toUserDetails ? toUserDetails.name : 'User'}" />
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <%-- Protected: id="user-presence-status" queried by initUserPresencePoller() --%>
                                <div class="cr-header-status" id="user-presence-status"></div>
                        </div>

                        <%-- Chat info trigger --%>
                            <button class="cr-header-btn js-chat-info-button" type="button" title="Chat info">
                                <i class="fas fa-info-circle"></i>
                            </button>
        </div>


        <div class="cr-messages" id="messagesContainer">

            <c:choose>
                <c:when test="${not empty messages}">
                    <c:forEach var="message" items="${messages}">
                        <div
                            class="message-wrapper mb-2 d-flex ${fn:trim(message.senderId) == fn:trim(userid) ? 'justify-content-end' : 'justify-content-start'}">
                            <div
                                class="message-bubble ${fn:trim(message.senderId) == fn:trim(userid) ? 'cr-bubble-sent' : 'cr-bubble-received'}">
                                <div class="message-content">
                                    <c:out value="${message.content}" />
                                </div>
                                <%-- Protected: id="sentAt" + data-date — queried by convertSentAtUTCtoUserTimeZone()
                                    --%>
                                    <div id="sentAt" data-date="<c:out value='${message.sentAt}'/>"
                                        class="message-time cr-bubble-time ${message.senderId == userid ? 'text-white-50' : 'text-muted'}">
                                    </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <%-- Protected: id="noMessagesPlaceholder" --%>
                        <div class="cr-empty" id="noMessagesPlaceholder">
                            <div class="cr-empty-icon">
                                <i class="fas fa-comment-dots"></i>
                            </div>
                            <h6 class="fw-semibold text-secondary mb-1">No messages yet</h6>
                            <p class="text-muted small mb-0">Send the first message to start the conversation
                            </p>
                        </div>
                </c:otherwise>
            </c:choose>

            <%-- Protected: id="typingIndicator" class="d-none" — toggled by WebSocket handler in header.jsp --%>
                <div class="typing-indicator d-none mb-2 d-flex justify-content-start" id="typingIndicator">
                    <div class="cr-typing-bubble">
                        <div class="typing-dots">
                            <span></span><span></span><span></span>
                        </div>
                    </div>
                </div>
        </div>


        <%-- Media Preview Container (hidden by default) --%>
        <div id="mediaPreviewContainer" class="d-none px-3 pt-2 pb-2">
            <div class="alert alert-info small py-2 px-3 mb-0 d-flex justify-content-between align-items-center">
                <span id="mediaPreviewText">Image: example.jpg (2.5 MB)</span>
                <button type="button" class="btn-close btn-sm" id="removeMediaBtn" title="Remove"></button>
            </div>
            <div id="mediaPreviewImageArea" class="mt-2"></div>
        </div>

        <%-- Upload Status Text (hidden by default) --%>
        <div id="uploadStatusText" class="text-muted small mt-2 px-3 d-none"></div>

        <div class="cr-input-bar">
            <form id="messageForm" action="/submit" autocomplete="off">
                <input type="hidden" name="chat_id" value="<c:out value='${conversationId}'/>">
                <div class="cr-input-inner">
                    <%-- Attachment Button --%>
                    <button type="button" class="btn cr-attach-btn" id="attachMediaBtn" title="Attach file">
                        <i class="fas fa-paperclip"></i>
                    </button>
                    <textarea class="form-control cr-textarea" id="messageInput" name="content"
                        placeholder="Type a message" rows="1"></textarea>
                    <button type="submit" class="btn cr-send-btn" id="sendButton" title="Send">
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
            </form>
        </div>

        <%-- Hidden File Input for Chat Media --%>
        <input type="file" id="chatMediaInput" class="d-none" accept="image/*" />

        <div class="offcanvas offcanvas-end" tabindex="-1" id="chatInfoSidebar" style="max-width:320px;">
            <div class="offcanvas-header cr-offcanvas-header">
                <h5 class="offcanvas-title text-white fw-semibold" style="font-size:0.95rem;">
                    <i class="fas fa-info-circle me-2"></i>Chat Info
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas"
                    aria-label="Close"></button>
            </div>

            <div class="offcanvas-body p-0">
                <%-- User profile block --%>
                    <c:set var="other_user" value="${not empty toUserDetails ? toUserDetails : null}" />
                    <c:if test="${not empty other_user}">
                        <div class="p-4 text-center border-bottom">
                            <c:choose>
                                <c:when test="${not empty other_user.profilePictureUrl}">
                                    <img src="<c:out value='${other_user.profilePictureUrl}'/>" alt="Avatar"
                                        class="cr-offcanvas-profile-avatar mb-3">
                                </c:when>
                                <c:otherwise>
                                    <div class="cr-offcanvas-avatar-placeholder mx-auto mb-3">
                                        <i class="fas fa-user"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <h6 class="fw-semibold mb-0">
                                <c:out value="${other_user.name}" />
                            </h6>
                            <p class="text-muted small mb-0">@
                                <c:out value="${other_user.name}" />
                            </p>
                            <c:if test="${not empty other_user.about}">
                                <p class="text-muted small mt-2 mb-0" style="font-size:0.8rem;">
                                    <c:out value="${other_user.about}" />
                                </p>
                            </c:if>
                        </div>
                    </c:if>

                    <%-- Actions list --%>
                        <div class="list-group list-group-flush">
                            <button
                                class="list-group-item list-group-item-action d-flex align-items-center gap-3 py-3 js-search-chat-button"
                                type="button">
                                <span
                                    style="width:32px;height:32px;background:#dbeafe;border-radius:8px;display:inline-flex;align-items:center;justify-content:center;color:#2563EB;flex-shrink:0;">
                                    <i class="fas fa-search fa-sm"></i>
                                </span>
                                <span class="fw-medium" style="font-size:0.875rem;">Search in Chat</span>
                            </button>
                        </div>
            </div>
        </div>
    </div>
    <script nonce="${cspNonce}">
        //init in header.jsp
        // const ctx = "<c:out value='${ctx}'/>";//getting from commons.jsp
        // const userId = "<c:out value='${userid}'/>"; //getting from commons.jsp
        const conversationId = "<c:out value='${conversationId}'/>";
        const toUserId = "<c:out value='${toUserId}'/>";

        document.addEventListener('DOMContentLoaded', function () {
            initSocket();
            initUserPresencePoller()//for online status and last seen(update not needed poller now for this)
            convertSentAtUTCtoUserTimeZone();
            // Auto-scroll to bottom
            scrollToBottom();
            // Focus message input
            document.getElementById('messageInput').focus();

            const backButton = document.querySelector('.js-back-button');
            if (backButton) {
                backButton.addEventListener('click', function () {
                    window.history.back();
                });
            }

            document.querySelectorAll('.js-chat-info-button').forEach(function (button) {
                button.addEventListener('click', function (event) {
                    event.preventDefault();
                    toggleChatInfo();
                });
            });

            const searchChatButton = document.querySelector('.js-search-chat-button');
            if (searchChatButton) {
                searchChatButton.addEventListener('click', searchInChat);
            }
        });

        function scrollToBottom() {
            const container = document.getElementById('messagesContainer');
            container.scrollTop = container.scrollHeight;
        }

        function toggleChatInfo() {
            const sidebar = new bootstrap.Offcanvas(document.getElementById('chatInfoSidebar'));
            sidebar.show();
        }

        function searchInChat() {
            alert('Search in chat functionality will be integrated');
        }

        function convertSentAtUTCtoUserTimeZone() {
            const dates = document.querySelectorAll("#sentAt");
            dates.forEach(function (el) {
                const date = new Date(el.dataset.date); // parse UTC
                el.textContent = date.toLocaleString(undefined, {
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    hour12: true
                });
            })
        }

        function initSocket() {
            const chatWs = new ChatWebSocket(conversationId, userId, toUserId);
            //token goes with cookie
            // chatWs.connect();
            chatWs.bindInputEvents();
            chatWs.bindFormEvents();
            chatWs.bindMediaEvents(); // Initialize media upload handlers
        }

        function initUserPresencePoller() {
            const poller = new UserPresencePoller([toUserId]);

            poller.setUpdateCallback((response) => {
                const data = response?.data;
                if (!data || data.length === 0) {
                    console.warn("No presence data received");
                    return;
                }

                const { userId, online, lastActive } = data[0];
                const statusElem = document.querySelector(".chat-header #user-presence-status");
                if (!statusElem) return;

                const validator = new Validator();
                if (!validator.isSafe(userId)) return;

                if (online) {
                    statusElem.textContent = "Online";
                } else if (lastActive) {
                    const df = new DateFormatter();
                    const formattedLastActive = df.formatUTCToLocalTimeZone(lastActive);
                    statusElem.textContent = 'Last seen: ' + formattedLastActive;
                } else {
                    statusElem.textContent = "Offline";
                }
                //console.log("User presence status updated:", response);
            });
            poller.start();
        }

    </script>