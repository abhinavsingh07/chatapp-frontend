<%@ include file="/WEB-INF/views/common.jsp" %>

<%-- Mobile header — hidden on md+. Protected: .js-search-button .js-contacts-button used by JS --%>
<div class="ch-mobile-header d-flex d-md-none align-items-center">
   <span class="fw-semibold">
      <i class="fas fa-comments me-2 opacity-75"></i>Chats
   </span>
   <div class="ms-auto d-flex gap-1">
      <button class="btn btn-sm ch-mobile-btn js-search-button" type="button">
         <i class="fas fa-search"></i>
      </button>
      <button class="btn btn-sm ch-mobile-btn js-contacts-button" type="button">
         <i class="fas fa-plus"></i>
      </button>
   </div>
</div>

<div class="ch-layout">

   <%-- ══ Left: Conversation sidebar ══ --%>
   <div class="ch-sidebar">

      <%-- Sidebar header — desktop only, mobile uses ch-mobile-header above --%>
      <div class="ch-sidebar-header d-none d-md-flex align-items-center justify-content-between">
         <div class="d-flex align-items-center gap-2">
            <div class="ch-header-avatar">
               <i class="fas fa-comments text-white" style="font-size:0.85rem;"></i>
            </div>
            <span class="fw-bold fs-6">Chats</span>
         </div>
         <%-- Protected: href URL mappings --%>
         <div class="dropdown">
            <button class="ch-icon-btn btn" type="button" data-bs-toggle="dropdown" aria-expanded="false">
               <i class="fas fa-plus text-secondary" style="font-size:0.85rem;"></i>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 py-1">
               <li>
                  <a class="dropdown-item rounded-2 py-2"
                     href="<c:out value='${pageContext.request.contextPath}'/>/contacts">
                     <i class="fas fa-user-plus me-2 text-primary"></i>New Chat
                  </a>
               </li>
               <li><hr class="dropdown-divider my-1"></li>
               <li>
                  <a class="dropdown-item rounded-2 py-2"
                     href="<c:out value='${pageContext.request.contextPath}'/>/contacts">
                     <i class="fas fa-address-book me-2 text-secondary"></i>Manage Contacts
                  </a>
               </li>
            </ul>
         </div>
      </div>

      <%-- Search bar. Protected: id="chatSearch" used by JS input listener --%>
      <div class="ch-search-wrap">
         <div class="input-group">
            <span class="input-group-text ch-search-icon">
               <i class="fas fa-search text-muted" style="font-size:0.78rem;"></i>
            </span>
            <input type="text" class="form-control ch-search-input"
               placeholder="Search chats..." id="chatSearch">
         </div>
      </div>

      <%-- Chat list. Protected: .chat-list used in scrollbar CSS --%>
      <div class="chat-list ch-list">

         <c:if test="${not empty chatData}">
            <c:forEach var="data" items="${chatData}">
               <%-- Protected: .chat-item (JS querySelectorAll), data-touserid, data-conversationid --%>
               <div class="chat-item ch-item"
                  data-touserid='<c:out value="${data.userId}"/>'
                  data-conversationid='<c:out value="${data.conversationId}"/>'>

                  <%-- Avatar --%>
                  <div class="ch-avatar-wrap">
                     <c:choose>
                        <c:when test="${data.conversationType == 'GROUP'}">
                           <div class="ch-avatar ch-avatar-group">
                              <i class="fas fa-users"></i>
                           </div>
                        </c:when>
                        <c:otherwise>
                           <c:choose>
                              <c:when test="${not empty data.mediaId}">
                                 <div data-user-media-id="${data.mediaId}" data-user-id="${data.userId}" data-profile-picture="true"></div>
                              </c:when>
                              <c:otherwise>
                                 <div class="ch-avatar ch-avatar-default">
                                    <i class="fas fa-user"></i>
                                 </div>
                              </c:otherwise>
                           </c:choose>
                        </c:otherwise>
                     </c:choose>
                  </div>

                  <%-- Item body. Protected: h6 and p inside .chat-item used by JS querySelector --%>
                  <div class="ch-item-body">
                     <div class="ch-item-top">
                        <h6 class="ch-item-name">
                           <c:choose>
                              <c:when test="${data.conversationType == 'GROUP'}">
                                 <c:out value="${data.conversationType != null ? data.conversationType : 'Group Chat'}" />
                              </c:when>
                              <c:otherwise>
                                 <c:choose>
                                    <c:when test="${not empty data.userName}">
                                       <c:out value="${data.userName}" />
                                    </c:when>
                                    <c:otherwise>Unknown User</c:otherwise>
                                 </c:choose>
                              </c:otherwise>
                           </c:choose>
                        </h6>
                        <%-- Protected: .sentAt class + data-date attribute used by JS --%>
                        <c:if test="${not empty data.content}">
                           <small class="ch-item-time sentAt" data-date='<c:out value="${data.sentAt}"/>'></small>
                        </c:if>
                     </div>
                     <%-- Protected: p inside .chat-item used by JS querySelector('p') --%>
                     <c:choose>
                        <c:when test="${not empty data.content}">
                           <p class="ch-item-preview">
                              <c:choose>
                                 <c:when test="${data.senderId == userid}">
                                    <i class="fas fa-check text-primary me-1" style="font-size:0.68rem;"></i>You:
                                 </c:when>
                                 <c:otherwise>
                                    <i class="fas fa-check text-primary me-1" style="font-size:0.68rem;"></i>
                                    <c:out value="${data.userName}" />:
                                 </c:otherwise>
                              </c:choose>
                              <c:out value="${fn:substring(data.content,0,30)}" /><c:if test="${fn:length(data.content) > 30}">&#8230;</c:if>
                           </p>
                        </c:when>
                        <c:otherwise>
                           <p class="ch-item-preview ch-item-preview--empty">No messages yet</p>
                        </c:otherwise>
                     </c:choose>
                  </div>

               </div><%-- /.ch-item --%>
            </c:forEach>
         </c:if>

         <c:if test="${empty chatData}">
            <div class="ch-empty-state">
               <div class="ch-empty-icon">
                  <i class="fas fa-comment-dots"></i>
               </div>
               <h6 class="ch-empty-title">No conversations yet</h6>
               <p class="ch-empty-text">Start a new chat with your contacts</p>
               <a href="<c:out value='${pageContext.request.contextPath}'/>/contacts"
                  class="btn btn-primary btn-sm px-4">
                  <i class="fas fa-plus me-2"></i>New Chat
               </a>
            </div>
         </c:if>

      </div><%-- /.ch-list --%>
   </div><%-- /.ch-sidebar --%>

   <%-- Right: Welcome panel — desktop only --%>
   <div class="ch-welcome d-none d-md-flex">
      <div class="ch-welcome-inner text-center">
         <div class="ch-welcome-icon mx-auto mb-4">
            <i class="fas fa-comments text-primary fs-2"></i>
         </div>
         <h4 class="fw-bold mb-2">Welcome to ChatSphere</h4>
         <p class="text-muted mb-4">Select a conversation to start messaging</p>
         <a href="<c:out value='${pageContext.request.contextPath}'/>/contacts"
            class="btn btn-primary px-4 py-2">
            <i class="fas fa-user-plus me-2"></i>Add Contacts
         </a>
      </div>
   </div>

</div><%-- /.ch-layout --%>
   <!-- JavaScript for interactivity -->
   <script nonce="${cspNonce}">
      document.addEventListener('DOMContentLoaded', function () {
         // Chat search functionality
         const chatSearch = document.getElementById('chatSearch');
         if (chatSearch) {
            chatSearch.addEventListener('input', function () {
               const query = this.value.toLowerCase();
               const chatItems = document.querySelectorAll('.chat-item');

               chatItems.forEach(item => {
                  const chatName = item.querySelector('h6').textContent.toLowerCase();
                  const lastMessage = item.querySelector('p').textContent.toLowerCase();

                  if (chatName.includes(query) || lastMessage.includes(query)) {
                     item.style.display = 'block';
                  } else {
                     item.style.display = 'none';
                  }
               });
            });
         }

         // Add hover effects
         const chatItems = document.querySelectorAll('.chat-item');
         chatItems.forEach(item => {
            item.addEventListener('click', startChat);

            item.addEventListener('mouseenter', function () {
               this.classList.add('bg-primary', 'bg-opacity-10');
            });

            item.addEventListener('mouseleave', function () {
               this.classList.remove('bg-primary', 'bg-opacity-10');
            });
         });

         const searchButton = document.querySelector('.js-search-button');
         if (searchButton) {
            searchButton.addEventListener('click', function () {
               window.location.href = '<c:out value="${pageContext.request.contextPath}"/>/search';
            });
         }

         const contactsButton = document.querySelector('.js-contacts-button');
         if (contactsButton) {
            contactsButton.addEventListener('click', function () {
               window.location.href = '<c:out value="${pageContext.request.contextPath}"/>/contacts';
            });
         }

         // Simulate unread message counts (would come from backend)
         setTimeout(() => {
            const unreadBadges = document.querySelectorAll('[id^="unread-"]');
            unreadBadges.forEach((badge, index) => {
               if (Math.random() > 0.7) { // 30% chance of having unread messages
                  const count = Math.floor(Math.random() * 5) + 1;
                  badge.textContent = count;
                  badge.style.display = 'inline';
               }
            });
         }, 1000);

         convertSentAtUTCtoUserTimeZone()
      });

      function createGroupChat() {
         // Placeholder for group chat creation
         alert('Group chat creation will be integrated with backend service');
      }

      // Auto-update chat list (placeholder for real-time updates)
      function updateChatList() {
         // This would fetch new messages and update the UI
         console.log('Checking for new messages...');
      }

      function convertSentAtUTCtoUserTimeZone() {
         const dates = document.querySelectorAll(".sentAt");
         dates.forEach(function (el) {
            var date1 = el.dataset.date;
            const date = new Date(date1); // parse UTC
            const df = new DateFormatter();
            const formattedUTCDateTime = df.formatUTCToLocalTimeZone(date);
            el.textContent = formattedUTCDateTime;
         })
      }

      function startChat(event) {
         event.preventDefault();
         if (event.target) {
            var toUserId = event.currentTarget.getAttribute("data-touserid");
            var conversationId = event.currentTarget.getAttribute("data-conversationid");
            var validator = new Validator();
            if (!validator.isSafe(conversationId)) return;
            if (!validator.isSafe(toUserId)) return;

            const url = `${ctx}/chat-room/`
               + encodeURIComponent(conversationId) + "/"
               + encodeURIComponent(toUserId);
            window.location.href = url;
         }
      }

      // Simulate real-time updates
      //setInterval(updateChatList, 30000); // Check every 30 seconds
   </script>
