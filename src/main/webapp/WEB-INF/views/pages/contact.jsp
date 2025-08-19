<%@ include file="/WEB-INF/views/common.jsp" %>
   <div class="container mt-4">
      <div class="row">
         <!-- Contacts List -->
         <div class="col-lg-8">
            <div class="card shadow-sm">
               <div class="card-header bg-primary text-white">
                  <div class="d-flex justify-content-between align-items-center">
                     <h5 class="mb-0">
                        <i class="fas fa-users me-2"></i>My Contacts
                     </h5>
                     <button class="btn btn-light btn-sm" data-bs-toggle="modal" data-bs-target="#addContactModal">
                        <i class="fas fa-user-plus me-2"></i>Add Contact
                     </button>
                  </div>
               </div>
               <div class="card-body p-0">
                  <!-- Search Contacts -->
                  <div class="p-3 border-bottom">
                     <div class="input-group">
                        <span class="input-group-text bg-transparent border-end-0">
                           <i class="fas fa-search text-muted"></i>
                        </span>
                        <input type="text" class="form-control border-start-0" placeholder="Search contacts..."
                           id="contactSearch">
                     </div>
                  </div>
                  <!-- Contacts List -->
                  <div class="contacts-list" style="max-height: 500px; overflow-y: auto;">
                     <!-- content adds dynamically fron js. -->
                  </div>
               </div>
            </div>
         </div>

         <div class="col-lg-4">
            <!-- Quick Actions -->
            <div class="card shadow-sm mb-4">
               <div class="card-header">
                  <h6 class="mb-0">
                     <i class="fas fa-bolt me-2"></i>Quick Actions
                  </h6>
               </div>
               <div class="card-body">
                  <div class="d-grid gap-2">
                     <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addContactModal">
                        <i class="fas fa-user-plus me-2"></i>Add Contact
                     </button>
                     <!-- <button class="btn btn-outline-primary" onclick="createGroup()">
                     <i class="fas fa-users me-2"></i>Create Group
                     </button>
                     <button class="btn btn-outline-secondary" onclick="importContacts()">
                     <i class="fas fa-download me-2"></i>Import Contacts
                     </button>
                     <button class="btn btn-outline-info" onclick="shareProfile()">
                     <i class="fas fa-share me-2"></i>Share My Profile
                     </button>
                     -->
                  </div>
               </div>
            </div>
            <!-- Statistics -->
            <div class="card shadow-sm">
               <div class="card-header">
                  <h6 class="mb-0">
                     <i class="fas fa-chart-bar me-2"></i>Statistics
                  </h6>
               </div>
               <div class="card-body">
                  <div class="row text-center">
                     <div class="col-6">
                        <div class="border-end">
                           <h4 class="text-primary mb-0" id="activeContactsCount"></h4>
                           <small class="text-muted">Active Contacts</small>
                        </div>
                     </div>
                     <div class="col-6">
                        <div class="border-end">
                           <h4 class="text-primary mb-0" id="invitedContactsCount"></h4>
                           <small class="text-muted">Invited Contacts</small>
                        </div>
                     </div>
                     <!--<div class="col-6">
                     <h4 class="text-success mb-0">
                     </h4>
                     <small class="text-muted">Online</small>
                  </div>-->
                  </div>
               </div>
            </div>
         </div>
      </div>
   </div>
   <!-- Add Contact Modal -->
   <div class="modal fade" id="addContactModal" tabindex="-1">
      <div class="modal-dialog">
         <div class="modal-content">
            <div class="modal-header">
               <h5 class="modal-title">
                  <i class="fas fa-user-plus me-2"></i>Add New Contact
               </h5>
               <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
               <button class="btn btn-outline-primary" onclick="addByEmail()">
                  <i class="fas fa-envelope me-2"></i>Email
               </button>
            </div>
         </div>
      </div>
   </div>
   <!-- Contact Profile Modal -->
   <div class="modal fade" id="contactProfileModal" tabindex="-1">
      <div class="modal-dialog">
         <div class="modal-content">
            <div class="modal-header">
               <h5 class="modal-title">Contact Profile</h5>
               <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="profileContent">
               <!-- Profile content will be loaded here -->
            </div>
         </div>
      </div>
   </div>
   <script>

      function sendContactRequest(userId) {
         // Simulate sending contact request
         alert(`Contact request sent! This will be integrated with backend service.`);

         // Update UI to show request sent
         const button = event.target;
         button.innerHTML = '<i class="fas fa-check"></i> Sent';
         button.classList.remove('btn-primary');
         button.classList.add('btn-success');
         button.disabled = true;
      }

      function startChat(contactId) {
         // Create or navigate to chat with contact
         var util = new Validator();
         if (!util.isSafe(contactId)) {
             console.error('Invalid contact ID.');
            return;
         }

         // Redirect to chat page with contact ID
         window.location.href = "${ctx}/chat-room/${userId}/${contactId}";
      }

      function viewProfile(userId) {
         var util = new Validator();
         if (!util.isSafe(userId)) {
            alert('Invalid user ID.');
            return;
         }

         // Show loading modal immediately
         const modal = new bootstrap.Modal(document.getElementById('contactProfileModal'));
         const profileContent = document.getElementById('profileContent');
         profileContent.innerHTML = '<div class="text-center p-3"><i class="fas fa-spinner fa-spin"></i> Loading profile...</div>';
         modal.show();

         // Call API to get user details
         ajaxRequest(
            "${ctx}/api/user/" + encodeURIComponent(userId),
            "GET",
            null,
            function (response) {
               console.log("User details loaded successfully:", response);

               if (response && response.data && response.data.length > 0) {
                  // Pass first user object to profile rendering
                  renderProfileHtml(response.data[0]);
               } else {
                  profileContent.innerHTML = `<div class="text-center text-muted p-3">User not found</div>`;
               }
            },
            function () {
               profileContent.innerHTML = `<div class="text-center text-danger p-3">Failed to load user details. Please try again.</div>`;
            }
         );
      }

      function renderProfileHtml(user) {
         var profileContent = document.getElementById('profileContent');

         // Determine avatar
         var avatarHTML = "";
         if (user.profilePictureUrl && user.profilePictureUrl.trim() !== "") {
            avatarHTML = '<img src="' + user.profilePictureUrl + '" class="rounded-circle mb-3" ' +
               'style="width: 80px; height: 80px; object-fit: cover;">';
         } else {
            avatarHTML = '<div class="avatar bg-secondary text-white rounded-circle d-inline-flex ' +
               'align-items-center justify-content-center mb-3" ' +
               'style="width: 80px; height: 80px;">' +
               '<i class="fas fa-user fa-2x"></i>' +
               '</div>';
         }

         // Determine name
         var displayName = "Unknown User";
         if (user.name && user.name.trim() !== "") {
            displayName = user.name;
         }

         // Determine phone number
         var displayPhone = "@unknown";
         if (user.phoneNumber && user.phoneNumber.trim() !== "") {
            displayPhone = "@" + user.phoneNumber;
         }

         // Determine about/bio
         var displayAbout = "No bio available";
         if (user.about && user.about.trim() !== "") {
            displayAbout = user.about;
         }

         // Build HTML
         var html = '';
         html += '<div class="text-center mb-4">';
         html += avatarHTML;
         html += '<h5>' + displayName + '</h5>';
         html += '<p class="text-muted">' + displayPhone + '</p>';
         html += '<p class="small">' + displayAbout + '</p>';
         html += '</div>';
         html += '<div class="d-grid gap-2">';
         html += '<button class="btn btn-primary" onclick="startChat(\'' + user.id + '\')">';
         html += '<i class="fas fa-comment me-2"></i>Start Chat';
         html += '</button>';
         html += '</div>';

         profileContent.innerHTML = html;
      }


      function addByEmail() {
         const email = prompt('Enter email address:');
         if (email) {
            addContact(email);
         }
      }

      function addContact(email) {
         var util = new Validator();
         if (!util.isEmail(email)) {
            alert('Please enter a valid email address.');
            return;
         }

         //request for add contact
         const addContactRequest = {
            userId: "${userid}",
            email: email,
         };

         ajaxRequest(
            "${ctx}/api/contact/add",
            "POST",
            addContactRequest,
            function (response) {
               //success callback
               alert('Contact added successfully!');
               $('#addContactModal').modal('hide'); // Hide the modal
               // Reload contacts to reflect the new addition
               loadContacts();
            },
            function () {
               //error callback
               alert('Failed to add contact. Please try again.');
            }
         );
      }



      function removeContact(contactId) {
         if (confirm('Are you sure you want to remove this contact?')) {
            var util = new Validator();
            if (!util.isSafe(contactId)) {
               alert('Invalid contact ID.');
               return;
            }

            ajaxRequest(
               "${ctx}/api/contact/" + contactId + "/remove",
               "DELETE",
               null,
               function (response) {
                  //success callback
                  alert('Contact removed successfully!');
                  loadContacts();
               },
               function () {
                  //error callback
                  alert('Failed to remove contact. Please try again.');
               }
            );
         }
      }


      function loadContacts() {
         console.log("Loading contacts for userId: " + "${userid}");
         ajaxRequest(
            "${ctx}/api/contact/${userid}", // Your backend endpoint
            "GET",
            null,
            function (response) {
               // Assuming response.data is the list of contacts
               renderContacts(response.data || []);
            },
            function () {
               $(".contacts-list").html(`<p class="text-danger">Failed to load contacts.</p>`);
            }
         );
      }

      function renderContacts(contacts) {
         var html = "";
         var activeContactsCount = 0;
         var invitedContactsCount = 0;

         if (contacts && contacts.length > 0) {
            contacts.forEach(function (contact) {
               html += '<div class="contact-item d-flex align-items-center p-3 border-bottom hover-bg-light">';

               // Avatar
               html += '<div class="flex-shrink-0 me-3" style="position: relative;">';
               if (contact.profilePictureUrl != null && contact.profilePictureUrl !== "") {
                  html += '<img src="' + contact.profilePictureUrl + '" alt="Avatar"'
                     + ' class="rounded-circle"'
                     + ' style="width: 50px; height: 50px; object-fit: cover;">';
               } else {
                  html += '<div class="avatar bg-secondary text-white rounded-circle d-flex align-items-center justify-content-center"'
                     + ' style="width: 50px; height: 50px;">'
                     + '<i class="fas fa-user"></i>'
                     + '</div>';
               }

               if (contact.status === 'ONLINE') {
                  html += '<span class="position-absolute translate-middle badge rounded-pill bg-success"'
                     + ' style="top: 75%; left: 85%;">'
                     + '<span class="visually-hidden">online</span>'
                     + '</span>';
               }
               html += '</div>'; // close avatar div

               // Contact Info
               html += '<div class="flex-grow-1">';
               html += '<h6 class="mb-1">Status: ' + contact.contactStatus + '</h6>';
               html += '<p class="mb-0 text-muted small">' + (contact.contactEmail || "") + '</p>';
               html += '<p class="mb-0 text-muted small">' + (contact.phoneNumber || "") + '</p>';
               html += '<p class="mb-0 text-muted small">' + (contact.name || "Not Registered") + '</p>';
               html += '</div>';

               if (contact.contactStatus == 'ADDED') {
                  // Actions
                  html += '<div class="btn-group">';
                  html += '<button class="btn btn-primary btn-sm" onclick="startChat(\'' + contact.contactUserId + '\')" title="Start Chat">'
                     + '<i class="fas fa-comment"></i>'
                     + '</button>';
                  html += '<button class="btn btn-outline-secondary btn-sm" onclick="viewProfile(\'' + contact.contactUserId + '\')" title="View Profile">'
                     + '<i class="fas fa-eye"></i>'
                     + '</button>';
               }
               html += '<div class="dropdown">'
                  + '<button class="btn btn-outline-secondary btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">'
                  + '<i class="fas fa-ellipsis-v"></i>'
                  + '</button>'
                  + '<ul class="dropdown-menu">'
                  // + '<li>'
                  // + '<a class="dropdown-item" href="#" onclick="editContact(\'' + contact.contactId + '\')">'
                  // + '<i class="fas fa-edit me-2"></i>Edit'
                  // + '</a>'
                  // + '</li>'
                  + '<li>'
                  + '<a class="dropdown-item text-danger" href="#" onclick="removeContact(\'' + contact.contactId + '\')">'
                  + '<i class="fas fa-trash me-2"></i>Remove'
                  + '</a>'
                  + '</li>'
                  + '</ul>'
                  + '</div>';
               html += '</div>'; // close btn-group

               html += '</div>'; // close contact-item
               if (contact.contactStatus == 'ADDED') {
                  activeContactsCount++;
               } else if (contact.contactStatus == 'INVITED') {
                  invitedContactsCount++;
               }

            });
         } else {
            html = '<div class="text-center p-5">'
               + '<i class="fas fa-address-book fa-3x text-muted mb-3"></i>'
               + '<h6 class="text-muted">No contacts yet</h6>'
               + '<p class="text-muted">Add contacts to start chatting</p>'
               + '<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addContactModal">'
               + '<i class="fas fa-user-plus me-2"></i>Add Your First Contact'
               + '</button>'
               + '</div>';
         }
         // Update statistics
         document.getElementById('activeContactsCount').textContent = activeContactsCount;
         document.getElementById('invitedContactsCount').textContent = invitedContactsCount;
         // Render contacts list
         $(".contacts-list").html(html);
      }

      $(document).ready(function () {
         loadContacts();
      })

      // document.addEventListener('DOMContentLoaded', function () {
      //    // Contact search functionality
      //    const contactSearch = document.getElementById('contactSearch');
      //    if (contactSearch) {
      //       contactSearch.addEventListener('input', function () {
      //          const query = this.value.toLowerCase();
      //          const contactItems = document.querySelectorAll('.contact-item');

      //          contactItems.forEach(item => {
      //             const name = item.querySelector('h6').textContent.toLowerCase();
      //             const username = item.querySelector('p').textContent.toLowerCase();

      //             if (name.includes(query) || username.includes(query)) {
      //                item.style.display = 'flex';
      //             } else {
      //                item.style.display = 'none';
      //             }
      //          });
      //       });
      //    }

      //    // User search for adding contacts
      //    const userSearch = document.getElementById('userSearch');
      //    if (userSearch) {
      //       let searchTimeout;
      //       userSearch.addEventListener('input', function () {
      //          clearTimeout(searchTimeout);
      //          const query = this.value.trim();

      //          if (query.length < 2) {
      //             document.getElementById('searchResults').style.display = 'none';
      //             return;
      //          }

      //          searchTimeout = setTimeout(() => {
      //             searchUsers(query);
      //          }, 500);
      //       });
      //    }
      // });

      // function searchUsers(query) {
      //    // Show loading state
      //    const resultsContainer = document.getElementById('searchResults');
      //    resultsContainer.style.display = 'block';
      //    resultsContainer.innerHTML = '<div class="text-center p-3"><i class="fas fa-spinner fa-spin"></i> Searching...</div>';

      //    // Simulate API call (replace with actual AJAX call)
      //    setTimeout(() => {
      //       fetch(`/api/search_users?q=encodeURIComponent(query)`)
      //          .then(response => response.json())
      //          .then(data => {
      //             displaySearchResults(data.users);
      //          })
      //          .catch(error => {
      //             resultsContainer.innerHTML = '<div class="text-center p-3 text-danger"><i class="fas fa-exclamation-triangle"></i> Search failed</div>';
      //          });
      //    }, 1000);
      // }

      //    function displaySearchResults(users) {
      //       const resultsContainer = document.getElementById('searchResults');

      //       if (users.length === 0) {
      //          resultsContainer.innerHTML = '<div class="text-center p-3 text-muted"><i class="fas fa-search"></i> No users found</div>';
      //          return;
      //       }

      //       const resultsHTML = users.map(user => `
      //      <div class="d-flex align-items-center p-3 border-bottom search-result-item" data-user-id="${user.id}">
      //          <div class="flex-shrink-0 me-3">
      //             `< img src = "" alt = "Avatar" class= "rounded-circle" style = "width: 40px; height: 40px; object-fit: cover;" > `
      //          </div>
      //          <div class="flex-grow-1">
      //              <h6 class="mb-1">user.full_name || user.username</h6>
      //              <small class="text-muted">user.username</small>
      //          </div>
      //          <button class="btn btn-primary btn-sm" onclick="sendContactRequest(user.id)">
      //              <i class="fas fa-user-plus"></i> Add
      //          </button>
      //      </div>
      //  `).join('');

      //       resultsContainer.innerHTML = resultsHTML;
      //    }


      // function editContact(contactId) {
      //    alert(`Edit contact functionality will be integrated for contact contactId`);
      // }

      // function acceptRequest(requestId) {
      //    alert(`Accept request functionality will be integrated for request requestId`);
      // }

      // function rejectRequest(requestId) {
      //    if (confirm('Are you sure you want to reject this contact request?')) {
      //       alert(`Reject request functionality will be integrated for request requestId`);
      //    }
      // }


      // function createGroup() {
      //    alert('Create group functionality will be integrated');
      // }

      // function importContacts() {
      //    alert('Import contacts functionality will be integrated');
      // }

      // function shareProfile() {
      //    // Generate share link or QR code
      //    const shareData = {
      //       title: 'ChatApp Profile',
      //       text: 'Connect with me on ChatApp!',
      //       url: window.location.origin + '/profile/{{ user.username }}'
      //    };

      //    if (navigator.share) {
      //       navigator.share(shareData);
      //    } else {
      //       // Fallback: copy to clipboard
      //       navigator.clipboard.writeText(shareData.url).then(() => {
      //          alert('Profile link copied to clipboard!');
      //       });
      //    }
      // }

      // function addByPhone() {
      //    const phone = prompt('Enter phone number:');
      //    if (phone) {
      //       alert(`Add by phone functionality will be integrated for: phone`);
      //    }
      // }

      // function scanQR() {
      //    alert('QR code scanner will be integrated using camera API');
      // }



   </script>