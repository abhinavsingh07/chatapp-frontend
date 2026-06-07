<%@ include file="/WEB-INF/views/common.jsp" %>
<div class="container">
    <div class="back-link">
        <a href="${ctx}/home">
            <i class="fas fa-arrow-left"></i> Back to Home
        </a>
    </div>

    <div class="settings-container">
        <div class="settings-header">
            <h1><i class="fas fa-user-circle"></i> Update Profile</h1>
            <p>Update your personal information and preferences</p>
        </div>

        <form id="updateProfileForm" action="${ctx}/update-profile" method="post" enctype="multipart/form-data" novalidate>
            <!-- Profile Picture Section -->
            <div class="settings-section">
                <h2><i class="fas fa-camera me-2"></i>Profile Picture</h2>
                
                <div class="text-center mb-4">
                    <div class="avatar-upload-container">
                        <div class="avatar avatar-xl mx-auto mb-3 position-relative">
                            <c:choose>
                                <c:when test="${not empty user.profilePictureUrl}">
                                    <img id="avatarPreview" src="${fn:escapeXml(user.profilePictureUrl)}" alt="Profile Avatar">
                                </c:when>
                                <c:otherwise>
                                    <img id="avatarPreview" src="${ctx}/icons/profile-user.png" alt="Profile Avatar">
                                </c:otherwise>
                            </c:choose>
                            <label for="avatarInput" class="position-absolute bottom-0 end-0 bg-primary text-white rounded-circle p-2 cursor-pointer" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-pencil-alt" style="font-size: 12px;"></i>
                            </label>
                        </div>
                        <input type="file" id="avatarInput" name="avatar" accept="image/*" class="d-none">
                    </div>
                    <p class="text-muted small">Click the camera icon to change your profile picture</p>
                </div>
            </div>

            <!-- Basic Information Section -->
            <div class="settings-section">
                <h2><i class="fas fa-user me-2"></i>Basic Information</h2>
                <input type="hidden" id="id" name="id" value="${fn:escapeXml(user.id)}">

                <div class="mb-3">
                    <label for="name" class="form-label">Name</label>
                    <input type="text" class="form-control profile-input" id="name" name="name" value="${fn:escapeXml(user.name)}" required>
                    <div class="invalid-feedback" id="nameError"></div>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">Email Address</label>
                    <input type="email" class="form-control profile-input" id="email" name="email" value="${fn:escapeXml(user.email)}" required>
                    <div class="invalid-feedback" id="emailError"></div>
                </div>

                <div class="mb-3">
                    <label for="phoneNumber" class="form-label">Phone Number</label>
                    <input type="tel" class="form-control profile-input" id="phoneNumber" name="phoneNumber" value="${fn:escapeXml(user.phoneNumber)}" placeholder="+1 234-567-8901">
                    <div class="invalid-feedback" id="phoneNumberError"></div>
                </div>

                <div class="mb-3">
                    <label for="about" class="form-label">About</label>
                    <textarea class="form-control profile-input" id="about" name="about" rows="3" maxlength="500" placeholder="Tell us about yourself..."><c:out value='${user.about}'/></textarea>
                    <div class="form-text text-muted"><span id="aboutCharCount">0</span>/500 characters</div>
                </div>
            </div>

            <!-- Password Change Section -->
            <div class="settings-section">
                <h2><i class="fas fa-lock me-2"></i>Change Password</h2>

                <div class="mb-3">
                    <label for="maskedCurrentPassword" class="form-label">Current Password</label>
                    <input type="password" class="form-control profile-input" id="maskedCurrentPassword" value="********" disabled autocomplete="off">
                </div>

                <div class="form-check form-switch mb-3">
                    <input class="form-check-input" type="checkbox" role="switch" id="changePasswordToggle">
                    <label class="form-check-label" for="changePasswordToggle">Change password</label>
                </div>

                <div id="passwordChangeFields" class="d-none">
                    <div class="mb-3">
                        <label for="oldPassword" class="form-label">Old Password</label>
                        <input type="password" class="form-control profile-input" id="oldPassword" name="oldPassword" placeholder="Enter your old password" autocomplete="current-password" disabled>
                        <div class="invalid-feedback" id="oldPasswordError"></div>
                    </div>

                    <div class="mb-3">
                        <label for="newPassword" class="form-label">New Password</label>
                        <input type="password" class="form-control profile-input" id="newPassword" name="newPassword" placeholder="Enter new password" autocomplete="new-password" disabled>
                        <div class="invalid-feedback" id="newPasswordError"></div>
                        <div class="form-text text-muted">Password must be at least 8 characters with uppercase, lowercase, number, and special character</div>
                    </div>

                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label">Confirm New Password</label>
                        <input type="password" class="form-control profile-input" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password" autocomplete="new-password" disabled>
                        <div class="invalid-feedback" id="confirmPasswordError"></div>
                    </div>
                </div>
            </div>

            <!-- Submit Button -->
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary" id="updateProfileBtn">
                    <i class="fas fa-save me-2"></i>Save Changes
                </button>
                <button type="button" class="btn btn-secondary" id="cancelBtn">
                    <i class="fas fa-times me-2"></i>Cancel
                </button>
            </div>
        </form>

        <!-- Success/Error Messages -->
        <div id="alertMessage" class="mt-3"></div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const validator = new Validator();
        const form = document.getElementById('updateProfileForm');
        const avatarInput = document.getElementById('avatarInput');
        const avatarPreview = document.getElementById('avatarPreview');
        const aboutTextarea = document.getElementById('about');
        const aboutCharCount = document.getElementById('aboutCharCount');
        const updateProfileBtn = document.getElementById('updateProfileBtn');
        const cancelBtn = document.getElementById('cancelBtn');
        const alertMessage = document.getElementById('alertMessage');
        const changePasswordToggle = document.getElementById('changePasswordToggle');
        const passwordChangeFields = document.getElementById('passwordChangeFields');
        const passwordInputs = [
            document.getElementById('oldPassword'),
            document.getElementById('newPassword'),
            document.getElementById('confirmPassword')
        ];

        // Initialize about character count
        aboutCharCount.textContent = aboutTextarea.value.length;

        // Avatar preview on file selection
        avatarInput.addEventListener('change', function (e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function (e) {
                    avatarPreview.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });

        // About character count
        aboutTextarea.addEventListener('input', function () {
            aboutCharCount.textContent = this.value.length;
        });

        changePasswordToggle.addEventListener('change', function () {
            const shouldChangePassword = this.checked;
            passwordChangeFields.classList.toggle('d-none', !shouldChangePassword);

            passwordInputs.forEach(input => {
                input.disabled = !shouldChangePassword;
                if (!shouldChangePassword) {
                    input.value = '';
                    input.classList.remove('is-invalid');
                    const errorDiv = document.getElementById(input.id + 'Error');
                    if (errorDiv) {
                        errorDiv.textContent = '';
                    }
                }
            });
        });

        // Cancel button - reload page
        cancelBtn.addEventListener('click', function () {
            window.location.href = '${ctx}/home';
        });

        // Form validation before submission
        form.addEventListener('submit', function (e) {
            // Clear previous errors
            clearErrors();
            
            let isValid = true;
            
            // Validate name
            const name = document.getElementById('name').value;
            if (validator.isEmpty(name)) {
                showError('name', 'Name is required');
                isValid = false;
            } else if (!validator.isSafe(name)) {
                showError('name', 'Name contains invalid characters');
                isValid = false;
            }
            
            // Validate email
            const email = document.getElementById('email').value;
            if (validator.isEmpty(email)) {
                showError('email', 'Email is required');
                isValid = false;
            } else if (!validator.isEmail(email)) {
                showError('email', 'Please enter a valid email address');
                isValid = false;
            }
            
            // Validate phone (optional)
            const phone = document.getElementById('phoneNumber').value;
            if (phone && !validator.isEmpty(phone) && !validator.isPhone(phone)) {
                showError('phoneNumber', 'Please enter a valid phone number');
                isValid = false;
            }
            
            // Validate password change
            if (changePasswordToggle.checked) {
                const oldPassword = document.getElementById('oldPassword').value;
                const newPassword = document.getElementById('newPassword').value;
                const confirmPassword = document.getElementById('confirmPassword').value;

                if (!oldPassword) {
                    showError('oldPassword', 'Old password is required to change password');
                    isValid = false;
                }
                
                if (!validator.isStrongPassword(newPassword)) {
                    showError('newPassword', 'Password must be at least 8 characters with uppercase, lowercase, number, and special character');
                    isValid = false;
                }
                
                if (newPassword !== confirmPassword) {
                    showError('confirmPassword', 'Passwords do not match');
                    isValid = false;
                }
            }
            
            if (!isValid) {
                e.preventDefault();
                showAlert('Please fix the errors above', 'danger');
            }
        });
        
        function showError(fieldId, message) {
            const field = document.getElementById(fieldId);
            const errorDiv = document.getElementById(fieldId + 'Error');
            
            field.classList.add('is-invalid');
            errorDiv.textContent = message;
        }
        
        function clearErrors() {
            const invalidFields = document.querySelectorAll('.is-invalid');
            invalidFields.forEach(field => {
                field.classList.remove('is-invalid');
            });
            
            const errorDivs = document.querySelectorAll('.invalid-feedback');
            errorDivs.forEach(div => {
                div.textContent = '';
            });
        }
        
        function showAlert(message, type) {
            const iconClass = type === 'success' ? 'check-circle' : 'exclamation-circle';
            alertMessage.innerHTML =
                '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                '<i class="fas fa-' + iconClass + ' me-2"></i>' +
                message +
                '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                '</div>';
        }
    });
</script>
