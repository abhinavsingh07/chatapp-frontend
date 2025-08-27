<%@ include file="/WEB-INF/views/common.jsp" %>
    <div class="container-fluid h-100">
        <div class="row h-100">

            <!-- Mobile Back Button + Chat Header -->
            <div class="d-md-none col-12 p-0">
                <div class="bg-primary text-white p-3">
                    <div class="d-flex align-items-center">
                        <!-- Back Button -->
                        <button class="btn btn-sm btn-outline-light me-3" onclick="window.history.back()">
                            <i class="fas fa-arrow-left"></i>
                        </button>

                        <!-- Chat Name & Status -->
                        <div class="flex-grow-1">
                            <h6 class="mb-0">
                                <c:choose>
                                    <c:when test="${chat.group}">
                                        ${not empty chat.name ? chat.name : 'Group Chat'}
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value=" ${not empty toUserDetails ? toUserDetails.name : 'User'}" />
                                    </c:otherwise>
                                </c:choose>
                            </h6>
                            <small class="text-light opacity-75" id="user-presence-status">
                            </small>
                        </div>

                        <!-- Chat Info Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-sm btn-outline-light" data-bs-toggle="dropdown">
                                <i class="fas fa-ellipsis-v"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="#" onclick="toggleChatInfo()">
                                        <i class="fas fa-info-circle me-2"></i>Chat Info
                                    </a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Chat Area -->
            <div class="col-12 p-0 d-flex flex-column" style="height: calc(100vh - 120px);">

                <!-- Desktop Chat Header -->
                <div class="d-none d-md-block chat-header bg-white border-bottom p-3">
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center">
                            <!-- Avatar -->
                            <c:choose>
                                <c:when test="${not empty toUserDetails.profilePictureUrl}">
                                    <img src="<c:out value='${toUserDetails.profilePictureUrl}'/>"
                                        class="rounded-circle me-3" style="width:45px;height:45px;object-fit:cover;">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-group bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                                        style="width: 45px; height: 45px;"><i class="fas fa-users"></i></div>
                                </c:otherwise>
                            </c:choose>

                            <!-- Chat Name & Status -->
                            <div>
                                <h6 class="mb-0">
                                    <c:choose>
                                        <c:when test="${chat.group}">
                                            ${not empty chat.name ? chat.name : 'Group Chat'}
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value=" ${not empty toUserDetails ? toUserDetails.name :  'User'}" />
                                        </c:otherwise>
                                    </c:choose>
                                </h6>
                                <small class="text-muted" id="user-presence-status">
                                </small>
                            </div>
                        </div>

                        <!-- Chat Actions -->
                        <button class="btn btn-outline-secondary btn-sm" onclick="toggleChatInfo()" title="Chat Info">
                            <i class="fas fa-info-circle"></i>
                        </button>
                    </div>
                </div>

                <!-- Messages Area -->
                <div class="flex-grow-1 overflow-auto p-3 bg-light messages-container" id="messagesContainer">

                    <!-- Messages -->
                    <c:choose>
                        <c:when test="${not empty messages}">
                            <c:forEach var="message" items="${messages}">
                                <div class="message-wrapper mb-3 ${message.senderId == userid ? 'text-end' : ''}">
                                    <div class="d-inline-block message-bubble 
                                ${message.senderId ==  userid ? 'bg-primary text-white' : 'bg-white border'} 
                                rounded-3 p-3 shadow-sm" style="max-width: 70%; word-wrap: break-word;">
                                        <!-- Sender Name in Group -->
                                        <!-- <c:if test="${chat.group and message.senderId != userid}">
                                            <div class="message-sender small fw-bold mb-1 text-primary">
                                                ${message.sender.full_name != null ? message.sender.full_name :
                                                message.sender.username}
                                            </div>
                                        </c:if> -->

                                        <!-- Message Content -->
                                        <div class="message-content">
                                            <c:out value="${message.content}" />
                                        </div>
                                        <!-- Message Timestamp -->
                                        <div id="sentAt" data-date="<c:out value='${message.sentAt}'/>"
                                            class="message-time small mt-1 ${message.senderId == userid ? 'text-white-50' : 'text-muted'}">
                                            <!-- date comes from js  -->
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- No Messages -->
                            <div class="text-center mt-5" id="noMessagesPlaceholder">
                                <i class="fas fa-comment-dots fa-3x text-muted mb-3"></i>
                                <h6 class="text-muted">No messages yet</h6>
                                <p class="text-muted">Send the first message to start the conversation</p>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- Typing Indicator -->
                    <div class="typing-indicator d-none mb-3" id="typingIndicator">
                        <div class="d-inline-block bg-white border rounded-3 p-3 shadow-sm">
                            <div class="typing-dots">
                                <span></span><span></span><span></span>
                            </div>
                            <!-- <div class="small text-muted mt-1">
                                <span id="typingUsers">Someone</span> is typing...
                            </div> -->
                        </div>
                    </div>
                </div>

                <!-- Message Input -->
                <div class="message-input bg-white border-top p-3">
                    <form id="messageForm" action="/submit" class="d-flex align-items-end gap-2">
                        <input type="hidden" name="chat_id" value="<c:out value='${conversationId}'/>">

                        <!-- Attachment Button -->
                        <!-- <button type="button" class="btn btn-outline-secondary" onclick="showAttachmentOptions()">
                            <i class="fas fa-paperclip"></i>
                        </button> -->

                        <!-- Message Textarea -->
                        <div class="flex-grow-1">
                            <textarea class="form-control" id="messageInput" name="content"
                                placeholder="Type a message..." rows="1"
                                style="resize: none; max-height: 120px;"></textarea>
                        </div>

                        <!-- Emoji Button -->
                        <!-- <button type="button" class="btn btn-outline-secondary" onclick="showEmojiPicker()">
                            <i class="fas fa-smile"></i>
                        </button> -->

                        <!-- Send Button -->
                        <button type="submit" class="btn btn-primary" id="sendButton">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>

                <!-- Optional UI Elements You Can Add -->
                <!-- Quick Actions: Call, Video Call -->
                <!-- Reactions: Like, Heart for messages -->
                <!-- Message Options: Edit, Delete -->
                <!-- Scroll-to-bottom Button when new messages arrive -->

            </div>
        </div>
    </div>

    <script>
        const ctx = "<c:out value='${ctx}'/>";
        const userId = "<c:out value='${userid}'/>";
        const conversationId = "<c:out value='${conversationId}'/>";
        const toUserId = "<c:out value='${toUserId}'/>";

        document.addEventListener('DOMContentLoaded', function () {
            initSocket();
            initUserPresencePoller()
            convertSentAtUTCtoUserTimeZone();
            // Auto-scroll to bottom
            scrollToBottom();
            // Focus message input
            document.getElementById('messageInput').focus();
        });

        function scrollToBottom() {
            const container = document.getElementById('messagesContainer');
            container.scrollTop = container.scrollHeight;
        }

        function toggleChatInfo() {
            const sidebar = new bootstrap.Offcanvas(document.getElementById('chatInfoSidebar'));
            sidebar.show();
        }

        // function startVideoCall() {
        //     alert('Video call feature will be integrated with WebRTC service');
        // }

        // function startVoiceCall() {
        //     alert('Voice call feature will be integrated with WebRTC service');
        // }

        // function showAttachmentOptions() {
        //     // Create temporary file input
        //     const input = document.createElement('input');
        //     input.type = 'file';
        //     input.multiple = true;
        //     input.accept = 'image/*,video/*,audio/*,.pdf,.doc,.docx';

        //     input.onchange = function (e) {
        //         const files = Array.from(e.target.files);
        //         files.forEach(file => {
        //             // In a real app, this would upload the file
        //             console.log('Would upload file:', file.name);
        //             // alert(`File upload for "${file.name}" will be integrated with file service`);
        //         });
        //     };

        //     input.click();
        // }

        // function showEmojiPicker() {
        //     // Simple emoji picker (in production, use a proper emoji picker library)
        //     const emojis = ['😀', '😂', '😍', '🤔', '👍', '👎', '❤️', '🎉', '😢', '😡'];
        //     const messageInput = document.getElementById('messageInput');

        //     const emojiMenu = emojis.map(emoji =>
        //         `<button class="btn btn-sm btn-outline-secondary me-1 mb-1" onclick="addEmoji('${emoji}')">${emoji}</button>`
        //     ).join('');

        //     const modal = `
        // <div class="modal fade" id="emojiModal" tabindex="-1">
        //     <div class="modal-dialog modal-sm">
        //         <div class="modal-content">
        //             <div class="modal-header">
        //                 <h6 class="modal-title">Choose Emoji</h6>
        //                 <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        //             </div>
        //             <div class="modal-body">
        //                ${emojiMenu}
        //             </div>
        //         </div>
        //     </div>
        // </div>`;

        //     document.body.insertAdjacentHTML('beforeend', modal);
        //     const emojiModalEl = new bootstrap.Modal(document.getElementById('emojiModal'));
        //     emojiModalEl.show();

        //     // Clean up when modal is hidden
        //     document.getElementById('emojiModal').addEventListener('hidden.bs.modal', function () {
        //         this.remove();
        //     });
        // }

        // function addEmoji(emoji) {
        //     const messageInput = document.getElementById('messageInput');
        //     messageInput.value += emoji;
        //     messageInput.focus();

        //     // Close emoji modal
        //     const emojiModal = bootstrap.Modal.getInstance(document.getElementById('emojiModal'));
        //     if (emojiModal) {
        //         emojiModal.hide();
        //     }
        // }

        // function clearChat() {
        //     if (confirm('Are you sure you want to clear this chat? This action cannot be undone.')) {
        //         alert('Clear chat functionality will be integrated with backend service');
        //     }
        // }

        // function leaveGroup() {
        //     if (confirm('Are you sure you want to leave this group?')) {
        //         alert('Leave group functionality will be integrated with backend service');
        //     }
        // }

        // function searchInChat() {
        //     alert('Search in chat functionality will be integrated');
        // }

        // function viewSharedMedia() {
        //     alert('Shared media view will be integrated');
        // }

        // function blockUser() {
        //     if (confirm('Are you sure you want to block this user?')) {
        //         alert('Block user functionality will be integrated with backend service');
        //     }
        // }

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
            chatWs.connect();
            chatWs.bindInputEvents();
            chatWs.bindFormEvents();
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
                    statusElem.textContent = 'Last seen: '+formattedLastActive;
                } else {
                    statusElem.textContent = "Offline";
                }
                console.log("User presence status updated:", response);
            });
            poller.start();
        }

    </script>