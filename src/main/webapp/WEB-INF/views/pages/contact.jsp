<%@ include file="/WEB-INF/views/common.jsp" %>
   <%-- Protected: .mutual-button:disabled used by JS --%>
      <style type="text/css">
         .mutual-button:disabled {
            pointer-events: auto;
         }
      </style>

      <div class="container-fluid px-3 px-lg-4 py-4">
         <div class="row g-4">

            <%-- ═══ Left: Contacts list ═══ --%>
               <div class="col-lg-8">
                  <div class="card border-0 shadow-sm overflow-hidden">

                     <div class="ct-card-header d-flex align-items-center justify-content-between px-4 py-3">
                        <div class="d-flex align-items-center gap-2">
                           <div class="ct-header-icon">
                              <i class="fas fa-users" style="font-size:0.85rem;"></i>
                           </div>
                           <span class="fw-bold text-white">My Contacts</span>
                        </div>
                        <%-- Protected: data-bs-toggle + data-bs-target="#addContactModal" --%>
                           <button class="btn ct-header-btn btn-sm d-flex align-items-center gap-2"
                              data-bs-toggle="modal" data-bs-target="#addContactModal">
                              <i class="fas fa-user-plus" style="font-size:0.78rem;"></i>
                              <span class="d-none d-sm-inline">Add Contact</span>
                           </button>
                     </div>

                     <div class="card-body p-0">

                        <div class="ct-search-wrap">
                           <div class="input-group">
                              <span class="input-group-text ct-search-icon">
                                 <i class="fas fa-search" style="font-size:0.78rem;"></i>
                              </span>
                              <%-- Protected: id="contactSearch" --%>
                                 <input type="text" class="form-control ct-search-input"
                                    placeholder="Search contacts..." id="contactSearch">
                           </div>
                        </div>

                        <%-- Protected: .contacts-list filled by JS $(".contacts-list").html() --%>
                           <div class="contacts-list ct-list">
                           </div>

                     </div>
                  </div>
               </div>

               <%-- ═══ Right: Actions + Stats ═══ --%>
                  <div class="col-lg-4 d-flex flex-column gap-4">

                     <%-- Quick Actions --%>
                        <div class="card border-0 shadow-sm">
                           <div class="card-body p-4">
                              <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
                                 <span class="ct-section-icon ct-section-icon--yellow">
                                    <i class="fas fa-bolt" style="font-size:0.78rem;"></i>
                                 </span>
                                 Quick Actions
                              </h6>
                              <%-- Protected: data-bs-toggle + data-bs-target="#addContactModal" --%>
                                 <button class="btn btn-primary w-100 py-2" data-bs-toggle="modal"
                                    data-bs-target="#addContactModal">
                                    <i class="fas fa-user-plus me-2"></i>Add New Contact
                                 </button>
                           </div>
                        </div>

                        <%-- Statistics --%>
                           <div class="card border-0 shadow-sm">
                              <div class="card-body p-4">
                                 <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
                                    <span class="ct-section-icon ct-section-icon--blue">
                                       <i class="fas fa-chart-bar" style="font-size:0.78rem;"></i>
                                    </span>
                                    Statistics
                                 </h6>
                                 <div class="row g-3">
                                    <div class="col-6">
                                       <div class="ct-stat-card">
                                          <%-- Protected: id="activeContactsCount" set by JS --%>
                                             <div class="ct-stat-num" id="activeContactsCount">—</div>
                                             <div class="ct-stat-label">Active</div>
                                       </div>
                                    </div>
                                    <div class="col-6">
                                       <div class="ct-stat-card ct-stat-card--amber">
                                          <%-- Protected: id="invitedContactsCount" set by JS --%>
                                             <div class="ct-stat-num ct-stat-num--amber" id="invitedContactsCount">—
                                             </div>
                                             <div class="ct-stat-label">Invited</div>
                                       </div>
                                    </div>
                                 </div>
                              </div>
                           </div>

                  </div>
         </div>
      </div>

      <%-- Add Contact Modal. Protected: id="addContactModal" , tabindex="-1" --%>
         <div class="modal fade" id="addContactModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
               <div class="modal-content border-0 shadow ct-modal">
                  <div class="modal-header ct-modal-header">
                     <h5 class="modal-title fw-bold">
                        <i class="fas fa-user-plus me-2"></i>Add New Contact
                     </h5>
                     <%-- Protected: data-bs-dismiss="modal" --%>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                  </div>
                  <div class="modal-body p-4">
                     <p class="text-muted small mb-3">Search by the contact's registered email address.</p>
                     <%-- Protected: .js-add-by-email-button used by JS querySelector --%>
                        <button class="btn btn-primary w-100 py-2 js-add-by-email-button" type="button">
                           <i class="fas fa-envelope me-2"></i>Add by Email
                        </button>
                  </div>
               </div>
            </div>
         </div>

         <%-- Contact Profile Modal. Protected: id="contactProfileModal" , id="profileContent" , tabindex="-1" --%>
            <div class="modal fade" id="contactProfileModal" tabindex="-1">
               <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content border-0 shadow ct-modal">
                     <div class="modal-header ct-modal-header">
                        <h5 class="modal-title fw-bold">Contact Profile</h5>
                        <%-- Protected: data-bs-dismiss="modal" --%>
                           <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                     </div>
                     <%-- Protected: id="profileContent" JS inserts HTML here --%>
                        <div class="modal-body p-4" id="profileContent">
                        </div>
                  </div>
               </div>
            </div>
            <script nonce="${cspNonce}">
               //these values coming from commons.jsp which is included at the top of this file. commons.jsp is used to set common variables like ctx and userid for all jsp files.
               //init in header.jsp
               // const ctx = "<c:out value='${ctx}'/>";
               // const userId = "<c:out value='${userid}'/>";

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

               function startChat(event) {
                  if (event.target) {
                     var toUserId = event.currentTarget.getAttribute("data-contactuserid");
                     var validator = new Validator();
                     if (!validator.isSafe(userId)) return;
                     if (!validator.isSafe(toUserId)) return;

                     const url = `${ctx}/api/conversation/get-or-create/`
                        + encodeURIComponent(toUserId);

                     ajaxRequest(
                        url,
                        "GET",
                        null,
                        function (response) {
                           if (response && response.data) {
                              const conversationId = response.data;
                              // After conversation is ready, load chat room view
                              window.location.href = `${ctx}/chat-room/` + encodeURIComponent(conversationId) + "/" + encodeURIComponent(toUserId);
                           } else {
                              console.log("Failed to create or fetch conversation. Please try again.");
                           }
                        },
                        function (err) {
                           console.error("Error while creating conversation:", err);
                        }
                     );
                  }

               }

               function viewProfile(event) {
                  if (event.target) {
                     const userId = event.currentTarget.getAttribute("data-contactuserid");
                     const validator = new Validator();
                     if (!validator.isSafe(userId)) return;

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
                        function (err) {
                           profileContent.innerHTML = `<div class="text-center text-danger p-3">Failed to load user details. Please try again.</div>`;
                        }
                     );
                  }

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
                  html += '<button class="btn btn-primary js-start-chat-button" type="button" data-contactuserid="' + user.id + '">';
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
                  // var validator = new Validator();
                  // if (!validator.isEmail(email)) {
                  //    alert('Please enter a valid email address.');
                  //    return;
                  // }

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



               function removeContact(event) {
                  if (confirm('Are you sure you want to remove this contact?')) {
                     const validator = new Validator();
                     const contactId = event.currentTarget.getAttribute("data-contactid");
                     if (!validator.isSafe(contactId)) return;

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
                  ajaxRequest(
                     "${ctx}/api/contact", //  spring mvc endpoint
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
                        html += '<div class="ct-contact-item">';

                        // Avatar with status indicator
                        html += '<div class="ct-contact-avatar">';
                        if (contact.mediaId != null && contact.mediaId !== "") {
                           // html += '<img src="' + contact.mediaId + '" alt="Avatar" />';
                           html += '<div class="ch-avatar-wrap">'
                              + '<div data-user-media-id="' + contact.mediaId + '"'
                              + ' data-user-id="' + contact.contactUserId + '" data-profile-picture="true">'
                              + '</div>'
                              + '</div>';
                        } else {
                           html += '<div class="avatar"><i class="fas fa-user"></i></div>';
                        }
                        if (contact.status === 'ONLINE') {
                           html += '<span class="ct-online-badge"></span>';
                        }
                        html += '</div>';

                        // Contact Info Section
                        html += '<div class="ct-contact-info-wrap">';
                        html += '<div class="ct-contact-name">' + (contact.name || "Unknown Contact") + '</div>';

                        // Meta info (email, phone) on same line with separator
                        var metaParts = [];
                        if (contact.contactEmail) metaParts.push(contact.contactEmail);
                        if (contact.phoneNumber) metaParts.push('@' + contact.phoneNumber);
                        var metaText = metaParts.join(' | ');
                        html += '<div class="ct-contact-meta">' + (metaText || "No contact info") + '</div>';

                        // Status badge
                        var statusClass = contact.contactStatus === 'ADDED' ? 'ct-contact-status-badge--added' : 'ct-contact-status-badge--invited';
                        var statusText = contact.contactStatus === 'ADDED' ? 'Active' : 'Invited';
                        html += '<div class="ct-contact-status-badge ' + statusClass + '">' + statusText + '</div>';
                        html += '</div>';

                        // Action Buttons
                        html += '<div class="ct-contact-actions">';

                        if (contact.contactStatus == 'ADDED') {
                           // Start Chat button (primary)
                           html += '<button class="ct-action-btn-icon ct-action-primary js-start-chat-button" '
                              + 'type="button" data-contactuserid="' + contact.contactUserId + '" '
                              + 'title="Start Chat"><i class="fas fa-comment"></i></button>';

                           // View Profile button
                           html += '<button class="ct-action-btn-icon js-view-profile-button" '
                              + 'type="button" data-contactuserid="' + contact.contactUserId + '" '
                              + 'title="View Profile"><i class="fas fa-eye"></i></button>';
                        }

                        // More menu (dropdown)
                        html += '<div class="dropdown">';
                        html += '<button class="ct-action-btn-icon" type="button" data-bs-toggle="dropdown" title="More actions">'
                           + '<i class="fas fa-ellipsis-v"></i></button>';
                        html += '<ul class="dropdown-menu dropdown-menu-end">';
                        html += '<li><a class="dropdown-item text-danger js-remove-contact-button" href="#" data-contactid="' + contact.contactId + '">'
                           + '<i class="fas fa-trash me-2"></i>Remove</a></li>';
                        html += '</ul>';
                        html += '</div>';

                        html += '</div>'; // close ct-contact-actions
                        html += '</div>'; // close ct-contact-item

                        if (contact.contactStatus == 'ADDED') {
                           activeContactsCount++;
                        } else if (contact.contactStatus == 'INVITED') {
                           invitedContactsCount++;
                        }

                     });
                  } else {
                     html = '<div class="ct-empty-state-wrapper">';
                     html += '<div class="ct-empty-state-icon"><i class="fas fa-address-book"></i></div>';
                     html += '<div class="ct-empty-state-title">No contacts yet</div>';
                     html += '<div class="ct-empty-state-text">Start building your network by adding your first contact</div>';
                     html += '<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addContactModal">';
                     html += '<i class="fas fa-user-plus me-2"></i>Add Your First Contact</button>';
                     html += '</div>';
                  }
                  // Update statistics
                  document.getElementById('activeContactsCount').textContent = activeContactsCount;
                  document.getElementById('invitedContactsCount').textContent = invitedContactsCount;
                  // Render contacts list
                  $(".contacts-list").html(html);
                  // Observe new profile pictures after a short delay to ensure DOM is updated


               }

               $(document).ready(function () {
                  loadContacts();
                  bindContactClickHandlers();
                  setTimeout(function () {
                     MediaLoader.observeNewProfilePictures();
                  }, 1000);
               })

               function bindContactClickHandlers() {
                  const addByEmailButton = document.querySelector('.js-add-by-email-button');
                  if (addByEmailButton) {
                     addByEmailButton.addEventListener('click', addByEmail);
                  }

                  document.addEventListener('click', function (event) {
                     const startChatButton = event.target.closest('.js-start-chat-button');
                     if (startChatButton) {
                        event.preventDefault();
                        startChat({ target: startChatButton, currentTarget: startChatButton });
                        return;
                     }

                     const viewProfileButton = event.target.closest('.js-view-profile-button');
                     if (viewProfileButton) {
                        event.preventDefault();
                        viewProfile({ target: viewProfileButton, currentTarget: viewProfileButton });
                        return;
                     }

                     const removeContactButton = event.target.closest('.js-remove-contact-button');
                     if (removeContactButton) {
                        event.preventDefault();
                        removeContact({ target: removeContactButton, currentTarget: removeContactButton });
                     }
                  });
               }

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
               //          <button class="btn btn-primary btn-sm js-send-contact-request-button" data-userid="user.id">
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