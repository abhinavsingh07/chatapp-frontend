<%@ include file="/WEB-INF/views/common.jsp" %>
   <div class="container-fluid">
      <div class="row">
         <!-- Sidebar - Chat List -->
         <div class="col-lg-4 col-md-5 p-0 border-end bg-light">
            <div class="chat-sidebar h-100">
               <!-- Header -->
               <div class="p-3 border-bottom bg-white">
                  <div class="d-flex justify-content-between align-items-center">
                     <h5 class="mb-0">
                        <i class="fas fa-comments me-2 text-primary"></i>Chats
                     </h5>
                     <div class="dropdown">
                        <button class="btn btn-outline-primary btn-sm dropdown-toggle" type="button"
                           data-bs-toggle="dropdown">
                           <i class="fas fa-plus"></i>
                        </button>
                        <ul class="dropdown-menu">
                           <li><a class="dropdown-item"
                                 href="<c:out value='${pageContext.request.contextPath}'/>/contacts">
                                 <i class="fas fa-user-plus me-2"></i>New Chat
                              </a>
                           </li>
                           <li>
                              <hr class="dropdown-divider">
                           </li>
                           <li><a class="dropdown-item"
                                 href="<c:out value='${pageContext.request.contextPath}'/>/contacts">
                                 <i class="fas fa-address-book me-2"></i>Manage Contacts
                              </a>
                           </li>
                        </ul>
                     </div>
                  </div>
               </div>

               <!-- Search -->
               <div class="p-3 border-bottom">
                  <div class="input-group">
                     <span class="input-group-text bg-transparent border-end-0">
                        <i class="fas fa-search text-muted"></i>
                     </span>
                     <input type="text" class="form-control border-start-0" placeholder="Search chats..."
                        id="chatSearch">
                  </div>
               </div>

               <!-- Chat List -->
               <div class="chat-list overflow-auto" style="height: calc(100vh - 200px);">
                  <c:if test="${not empty chatData}">
                     <c:forEach var="data" items="${chatData}">
                        <div class="chat-item p-3 border-bottom bg-white hover-bg-light cursor-pointer"
                           data-touserid='<c:out value="${data.participantId}"/>'
                           data-conversationid='<c:out value="${data.conversationId}"/>' onclick="startChat(event);">
                           <div class="d-flex">
                              <!-- Avatar -->
                              <div class="flex-shrink-0 me-3">
                                 <c:choose>
                                    <c:when test="${data.conversationType == 'GROUP'}">
                                       <div
                                          class="avatar-group bg-primary text-white rounded-circle d-flex align-items-center justify-content-center"
                                          style="width: 50px; height: 50px;">
                                          <i class="fas fa-users"></i>
                                       </div>
                                    </c:when>
                                    <c:otherwise>
                                       <c:if test="${not empty data.participantProfilePic}">
                                          <img src="<c:out value='${data.participantProfilePic}'/>" alt="Avatar"
                                             class="rounded-circle"
                                             style="width: 50px; height: 50px; object-fit: cover;">
                                       </c:if>
                                       <c:if
                                          test="${data.participantProfilePic == null || empty data.participantProfilePic}">
                                          <div
                                             class="avatar bg-secondary text-white rounded-circle d-flex align-items-center justify-content-center"
                                             style="width: 50px; height: 50px;">
                                             <i class="fas fa-user"></i>
                                          </div>
                                       </c:if>
                                    </c:otherwise>
                                 </c:choose>
                              </div>

                              <!-- Chat Info -->
                              <div class="flex-grow-1 min-width-0">
                                 <div class="d-flex justify-content-between align-items-start mb-1">
                                    <h6 class="mb-0">
                                       <c:choose>
                                          <c:when test="${data.conversationType == 'GROUP'}">
                                             <c:out
                                                value="${data.conversationType != null ? data.conversationType : 'Group Chat'}" />
                                          </c:when>
                                          <c:otherwise>
                                             <c:choose>
                                                <c:when test="${not empty data.participantName}">
                                                   <c:out value="${data.participantName}" />
                                                </c:when>
                                                <c:otherwise>Unknown User</c:otherwise>
                                             </c:choose>
                                          </c:otherwise>
                                       </c:choose>
                                    </h6>
                                    <c:if test="${not empty data.content}">
                                       <small class="text-muted sentAt" data-date='<c:out value="${data.sentAt}"/>'>
                                       </small>
                                    </c:if>
                                 </div>

                                 <c:choose>
                                    <c:when test="${not empty data.content}">
                                       <div class="d-flex justify-content-between align-items-end">
                                          <p class="mb-0 text-muted text-truncate small">
                                             <c:choose>
                                                <c:when test="${data.senderId == userid}">
                                                   <i class="fas fa-check text-primary me-1"></i>You:
                                                </c:when>
                                                <c:otherwise>
                                                   <i class="fas fa-check text-primary me-1"></i>
                                                   <c:out value="${data.participantName}" />:
                                                </c:otherwise>
                                             </c:choose>
                                             <c:out value="${fn:substring(data.content,0,30)}" />
                                             <c:if test="${fn:length(data.content) > 30}">...</c:if>
                                          </p>
                                       </div>
                                    </c:when>
                                    <c:otherwise>
                                       <p class="mb-0 text-muted small">No messages yet</p>
                                    </c:otherwise>
                                 </c:choose>
                              </div>
                           </div>
                        </div>
                     </c:forEach>
                  </c:if>
                  <c:if test="${empty chatData}">
                     <div class="text-center p-5">
                        <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                        <h6 class="text-muted">No conversations yet</h6>
                        <p class="text-muted small">Start a new chat to begin messaging</p>
                        <a href="<c:out value='${pageContext.request.contextPath}'/>/contacts" class="btn btn-primary">
                           <i class="fas fa-plus me-2"></i>Start New Chat
                        </a>
                     </div>
                  </c:if>
               </div>
            </div>
         </div>

         <!-- Main Content Area -->
         <div class="col-lg-8 col-md-7 d-none d-md-flex align-items-center justify-content-center bg-light">
            <div class="text-center">
               <i class="fas fa-comments fa-4x text-muted mb-4"></i>
               <h4 class="text-muted mb-3">Welcome to ChatApp</h4>
               <p class="text-muted">Select a conversation to start messaging</p>
               <div class="mt-4">
                  <a href="<c:out value='${pageContext.request.contextPath}'/>/contacts" class="btn btn-primary me-2">
                     <i class="fas fa-user-plus me-2"></i>Add Contacts
                  </a>
               </div>
            </div>
         </div>
      </div>
   </div>

   <!-- Mobile view -->
   <div class="d-md-none">
      <div class="bg-primary text-white p-3">
         <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">
               <i class="fas fa-comments me-2"></i>Chats
            </h5>
            <div class="btn-group">
               <button class="btn btn-sm btn-outline-light"
                  onclick="window.location.href='<c:out value='${pageContext.request.contextPath}'/>/search'">
                  <i class="fas fa-search"></i>
               </button>
               <button class="btn btn-sm btn-outline-light"
                  onclick="window.location.href='<c:out value='${pageContext.request.contextPath}'/>/contacts'">
                  <i class="fas fa-plus"></i>
               </button>
            </div>
         </div>
      </div>
   </div>
   <!-- JavaScript for interactivity -->
   <script>
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
            item.addEventListener('mouseenter', function () {
               this.classList.add('bg-primary', 'bg-opacity-10');
            });

            item.addEventListener('mouseleave', function () {
               this.classList.remove('bg-primary', 'bg-opacity-10');
            });
         });

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
            var date1 = el.dataset.date + "Z";
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