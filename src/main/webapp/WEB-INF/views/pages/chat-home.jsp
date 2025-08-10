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
                  <button class="btn btn-outline-primary btn-sm dropdown-toggle"
                     type="button" data-bs-toggle="dropdown">
                  <i class="fas fa-plus"></i>
                  </button>
                  <ul class="dropdown-menu">
                     <li><a class="dropdown-item" href="${pageContext.request.contextPath}/contact">
                        <i class="fas fa-user-plus me-2"></i>New Chat
                        </a>
                     </li>
                     <!--<li><a class="dropdown-item" href="#" onclick="createGroupChat()">
                        <i class="fas fa-users me-2"></i>New Group
                        </a></li>-->
                     <li>
                        <hr class="dropdown-divider">
                     </li>
                     <li><a class="dropdown-item" href="${pageContext.request.contextPath}/contact">
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
               <input type="text" class="form-control border-start-0"
                  placeholder="Search chats..." id="chatSearch">
            </div>
         </div>
         <!-- Chat List -->
         <div class="chat-list overflow-auto" style="height: calc(100vh - 200px);">
            <div class="chat-item p-3 border-bottom bg-white hover-bg-light cursor-pointer"
               onclick="window.location.href='{{ url_for('chat_room', chat_id=chat.id) }}'">
               <div class="d-flex">
                  <!-- Avatar -->
                  <div class="flex-shrink-0 me-3">
                     <div class="position-relative">
                        <!-- <div class="avatar-group bg-primary text-white rounded-circle d-flex align-items-center justify-content-center"
                           style="width: 50px; height: 50px;">
                           <i class="fas fa-users"></i>
                           </div>-->
                        <img src="" alt="Avatar"
                           class="rounded-circle" style="width: 50px; height: 50px; object-fit: cover;">
                        <div class="avatar bg-secondary text-white rounded-circle d-flex align-items-center justify-content-center"
                           style="width: 50px; height: 50px;">
                           <i class="fas fa-user"></i>
                        </div>
                        <!-- Online indicator -->
                        <span class="position-absolute translate-middle badge rounded-pill bg-success"
                           style="top: 75%; left: 85%;">
                        <span class="visually-hidden">online</span>
                        </span>
                     </div>
                     <!-- Chat Info -->
                     <div class="flex-grow-1 min-width-0">
                        <div class="d-flex justify-content-between align-items-start mb-1">
                           <h6 class="mb-0 text-truncate">
                           </h6>
                           <small class="text-muted">
                           </small>
                        </div>
                        <div class="d-flex justify-content-between align-items-end">
                           <p class="mb-0 text-muted text-truncate small">
                              <i class="fas fa-check text-primary me-1"></i>You:
                           </p>
                           <!-- Unread count placeholder -->
                           <span class="badge bg-primary rounded-pill ms-2" style="display: none;" id="unread-{{ chat.id }}">3</span>
                        </div>
                        <p class="mb-0 text-muted small">No messages yet</p>
                     </div>
                  </div>
               </div>
               <div class="text-center p-5">
                  <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                  <h6 class="text-muted">No conversations yet</h6>
                  <p class="text-muted small">Start a new chat to begin messaging</p>
                  <a href="{{ url_for('contacts') }}" class="btn btn-primary">
                  <i class="fas fa-plus me-2"></i>Start New Chat
                  </a>
               </div>
            </div>
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
            <a href="${pageContext.request.contextPath}/contact" class="btn btn-primary me-2">
            <i class="fas fa-user-plus me-2"></i>Add Contacts
            </a>
            <!--<button class="btn btn-outline-primary" onclick="createGroupChat()">
            <i class="fas fa-users me-2"></i>Create Group
            </button>
            -->
         </div>
      </div>
   </div>
</div>
<!-- Mobile view: Show only chat list -->
<div class="d-md-none">
   <!-- Mobile header -->
   <div class="bg-primary text-white p-3">
      <div class="d-flex justify-content-between align-items-center">
         <h5 class="mb-0">
            <i class="fas fa-comments me-2"></i>Chats
         </h5>
         <div class="btn-group">
            <button class="btn btn-sm btn-outline-light" onclick="window.location.href=''">
            <i class="fas fa-search"></i>
            </button>
            <button class="btn btn-sm btn-outline-light" onclick="window.location.href=''">
            <i class="fas fa-plus"></i>
            </button>
         </div>
      </div>
   </div>
</div>
<script>
   document.addEventListener('DOMContentLoaded', function() {
       // Chat search functionality
       const chatSearch = document.getElementById('chatSearch');
       if (chatSearch) {
           chatSearch.addEventListener('input', function() {
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
           item.addEventListener('mouseenter', function() {
               this.classList.add('bg-primary', 'bg-opacity-10');
           });

           item.addEventListener('mouseleave', function() {
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

   // Simulate real-time updates
   setInterval(updateChatList, 30000); // Check every 30 seconds
</script>