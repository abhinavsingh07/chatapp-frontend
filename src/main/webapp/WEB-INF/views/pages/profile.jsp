<%@ include file="/WEB-INF/views/common.jsp" %>
    <div class="pf-page-wrap">
        <div class="card border-0 shadow-sm pf-main-card">

            <%-- ── Header ── --%>
                <div class="pf-card-header">
                    <div class="pf-header-icon">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div>
                        <h5 class="mb-0 fw-semibold text-white" style="font-size:0.95rem;">Update Profile</h5>
                        <small class="text-white-50" style="font-size:0.75rem;">Manage your personal information</small>
                    </div>
                    <a href="${ctx}/home" class="pf-back-btn">
                        <i class="fas fa-arrow-left me-1"></i>Back
                    </a>
                </div>

                <form id="updateProfileForm" method="post" enctype="multipart/form-data"
                    data-url="${ctx}/api/update-profile" novalidate>

                    <%-- ══════════════════════════════════════ SECTION 1 — Avatar
                        ═══════════════════════════════════════ --%>
                        <div class="pf-section text-center">
                            <div class="pf-section-title justify-content-center">
                                <span class="pf-section-icon"><i class="fas fa-camera"></i></span>
                                Profile Picture
                            </div>

                            <div class="pf-avatar-wrap mx-auto mb-2">
                                <c:if test="${not empty userMediaId}">
                                    <div class="profile-picture-container" data-usermediaid="${userMediaId}" data-userid="${userId}" data-profilepicture="true"></div>
                                </c:if>
                                <c:if test="${empty userMediaId}">
                                    <div class="avatar-container">
                                        <img id="avatarPreview" src="${ctx}/icons/profile-user.png" alt="Profile Avatar"
                                            class="pf-avatar">
                                    </div>
                                </c:if>
                                <!-- When you click on a label with a for attribute, it automatically opens window to select file-->
                                <label for="profilePictureInput" class="pf-avatar-edit" title="Change photo">
                                    <i class="fas fa-pencil-alt"></i>
                                </label>
                            </div>
                            <!-- <input type="file" id="avatarInput" name="avatar" accept="image/*" class="d-none"> -->
                            <input type="file" id="profilePictureInput" accept="image/*" class="d-none">
                            <p class="text-muted small mb-0">Click the pencil to change your photo</p>

                            <%-- Upload Status & Retry (hidden by default) --%>
                                <div id="profileUploadStatus" class="alert alert-info small d-none mt-3 mb-2"
                                    role="alert"></div>
                                <button type="button" class="btn btn-sm btn-outline-secondary d-none mt-2"
                                    id="profileRetryUploadBtn">
                                    Retry Upload
                                </button>
                        </div>

                        <div class="pf-divider"></div>

                        <%-- ══════════════════════════════════════ SECTION 2 — Basic Information
                            ═══════════════════════════════════════ --%>
                            <div class="pf-section">
                                <div class="pf-section-title">
                                    <span class="pf-section-icon"><i class="fas fa-user"></i></span>
                                    Basic Information
                                </div>

                                <input type="hidden" id="id" name="id" value="${fn:escapeXml(user.id)}">

                                <%-- Name --%>
                                    <div class="mb-3">
                                        <label for="name" class="form-label fw-medium" style="font-size:0.85rem;">Full
                                            Name</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light border-end-0 text-secondary">
                                                <i class="fas fa-user fa-sm"></i>
                                            </span>
                                            <input type="text" class="form-control profile-input border-start-0"
                                                id="name" name="name" value="${fn:escapeXml(user.name)}"
                                                placeholder="Your full name" required>
                                        </div>
                                        <div class="invalid-feedback d-block" id="nameError"></div>
                                    </div>

                                    <%-- Email --%>
                                        <div class="mb-3">
                                            <label for="email" class="form-label fw-medium"
                                                style="font-size:0.85rem;">Email Address</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light border-end-0 text-secondary">
                                                    <i class="fas fa-envelope fa-sm"></i>
                                                </span>
                                                <input type="email" class="form-control profile-input border-start-0"
                                                    id="email" name="email" value="${fn:escapeXml(user.email)}"
                                                    placeholder="you@example.com" required>
                                            </div>
                                            <div class="invalid-feedback d-block" id="emailError"></div>
                                        </div>

                                        <%-- Phone — readonly --%>
                                            <div class="mb-3">
                                                <label for="phoneNumber" class="form-label fw-medium"
                                                    style="font-size:0.85rem;">
                                                    Phone Number
                                                    <span class="badge bg-secondary ms-1"
                                                        style="font-size:0.65rem;font-weight:500;">read-only</span>
                                                </label>
                                                <div class="input-group">
                                                    <span class="input-group-text bg-light border-end-0 text-secondary">
                                                        <i class="fas fa-phone fa-sm"></i>
                                                    </span>
                                                    <input type="tel" class="form-control profile-input border-start-0"
                                                        id="phoneNumber" name="phoneNumber"
                                                        value="${fn:escapeXml(user.phoneNumber)}"
                                                        placeholder="+1 234-567-8901" readonly>
                                                </div>
                                                <div class="invalid-feedback d-block" id="phoneNumberError"></div>
                                            </div>

                                            <%-- About --%>
                                                <div class="mb-1">
                                                    <label for="about" class="form-label fw-medium"
                                                        style="font-size:0.85rem;">About</label>
                                                    <textarea class="form-control profile-input" id="about" name="about"
                                                        rows="3" maxlength="500"
                                                        placeholder="Tell us about yourself..."><c:out value='${user.about}'/></textarea>
                                                    <div class="pf-char-count"><span id="aboutCharCount">0</span>/500
                                                    </div>
                                                </div>
                            </div>

                            <div class="pf-divider"></div>

                            <%-- ══════════════════════════════════════ SECTION 3 — Change Password
                                ═══════════════════════════════════════ --%>
                                <div class="pf-section">
                                    <div class="pf-section-title">
                                        <span class="pf-section-icon pf-section-icon--red"><i
                                                class="fas fa-lock"></i></span>
                                        Security
                                    </div>

                                    <%-- Masked current password placeholder --%>
                                        <div class="mb-3">
                                            <label for="maskedCurrentPassword" class="form-label fw-medium"
                                                style="font-size:0.85rem;">Current Password</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light border-end-0 text-secondary">
                                                    <i class="fas fa-key fa-sm"></i>
                                                </span>
                                                <input type="password"
                                                    class="form-control profile-input border-start-0 pf-password-mask"
                                                    id="maskedCurrentPassword" value="********" disabled
                                                    autocomplete="off">
                                            </div>
                                        </div>

                                        <%-- Toggle to reveal password fields --%>
                                            <div class="form-check form-switch mb-3">
                                                <input class="form-check-input" type="checkbox" role="switch"
                                                    id="changePasswordToggle">
                                                <label class="form-check-label fw-medium" for="changePasswordToggle"
                                                    style="font-size:0.875rem;">
                                                    Change password
                                                </label>
                                            </div>

                                            <%-- Protected: id="passwordChangeFields" class="d-none" toggled by JS --%>
                                                <div id="passwordChangeFields" class="d-none">
                                                    <div class="mb-3">
                                                        <label for="oldPassword" class="form-label fw-medium"
                                                            style="font-size:0.85rem;">Old Password</label>
                                                        <div class="input-group">
                                                            <span
                                                                class="input-group-text bg-light border-end-0 text-secondary">
                                                                <i class="fas fa-lock-open fa-sm"></i>
                                                            </span>
                                                            <input type="password"
                                                                class="form-control profile-input border-start-0"
                                                                id="oldPassword" name="oldPassword"
                                                                placeholder="Enter your old password"
                                                                autocomplete="current-password" disabled>
                                                        </div>
                                                        <div class="invalid-feedback d-block" id="oldPasswordError">
                                                        </div>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label for="newPassword" class="form-label fw-medium"
                                                            style="font-size:0.85rem;">New Password</label>
                                                        <div class="input-group">
                                                            <span
                                                                class="input-group-text bg-light border-end-0 text-secondary">
                                                                <i class="fas fa-lock fa-sm"></i>
                                                            </span>
                                                            <input type="password"
                                                                class="form-control profile-input border-start-0"
                                                                id="newPassword" name="newPassword"
                                                                placeholder="Enter new password"
                                                                autocomplete="new-password" disabled>
                                                        </div>
                                                        <div class="invalid-feedback d-block" id="newPasswordError">
                                                        </div>
                                                        <div class="form-text text-muted mt-1"
                                                            style="font-size:0.75rem;">
                                                            <i class="fas fa-info-circle me-1"></i>Min 8 chars with
                                                            uppercase, lowercase, number &amp; special character
                                                        </div>
                                                    </div>

                                                    <div class="mb-2">
                                                        <label for="confirmPassword" class="form-label fw-medium"
                                                            style="font-size:0.85rem;">Confirm New Password</label>
                                                        <div class="input-group">
                                                            <span
                                                                class="input-group-text bg-light border-end-0 text-secondary">
                                                                <i class="fas fa-check-double fa-sm"></i>
                                                            </span>
                                                            <input type="password"
                                                                class="form-control profile-input border-start-0"
                                                                id="confirmPassword" name="confirmPassword"
                                                                placeholder="Confirm new password"
                                                                autocomplete="new-password" disabled>
                                                        </div>
                                                        <div class="invalid-feedback d-block" id="confirmPasswordError">
                                                        </div>
                                                    </div>
                                                </div>
                                </div>

                                <div class="pf-divider"></div>

                                <%-- ── Action buttons ── --%>
                                    <div class="pf-section d-flex gap-2 pt-1">
                                        <button type="submit" class="btn btn-primary px-4" id="updateProfileBtn">
                                            <i class="fas fa-save me-2"></i>Save Changes
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary px-4" id="cancelBtn">
                                            <i class="fas fa-times me-2"></i>Cancel
                                        </button>
                                    </div>

                </form>

                <%-- Protected: id="alertMessage" used by showAlert() in script --%>
                    <div id="alertMessage" class="px-4 pb-3"></div>

        </div><%-- /.pf-main-card --%>
    </div><%-- /.pf-page-wrap --%>

        <script nonce="${cspNonce}">
            document.addEventListener('DOMContentLoaded', function () {
                const validator = new Validator();
                const form = document.getElementById('updateProfileForm');
                const avatarInput = document.getElementById('avatarInput');
                let avatarPreview = document.getElementById('avatarPreview');
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

                // ─────── Media Upload Handlers for Profile Picture ───────
                const profilePictureInput = document.getElementById('profilePictureInput');
                const profileUploadStatus = document.getElementById('profileUploadStatus');
                const profileRetryUploadBtn = document.getElementById('profileRetryUploadBtn');

                // Create upload button if not exists
                let uploadProfilePictureBtn = document.getElementById('uploadProfilePictureBtn');
                if (!uploadProfilePictureBtn && profilePictureInput) {
                    uploadProfilePictureBtn = document.createElement('button');
                    uploadProfilePictureBtn.type = 'button';
                    uploadProfilePictureBtn.id = 'uploadProfilePictureBtn';
                    uploadProfilePictureBtn.className = 'btn btn-primary btn-sm mt-3 d-none';
                    uploadProfilePictureBtn.textContent = 'Upload Profile Picture';
                    profilePictureInput.parentElement.insertAdjacentElement('afterend', uploadProfilePictureBtn);
                }

                // Track profile picture state
                let profilePictureState = {
                    file: null,
                    mediaId: null,
                    clientUploadId: null,
                    isUploading: false
                };

                // Handle profile picture file selection
                if (profilePictureInput) {
                    profilePictureInput.addEventListener('change', async function (e) {
                        const file = e.target.files[0];
                        if (!file) return;

                        // Validate file
                        const validation = validateSelectedFile(file, 'PROFILE_PICTURE');
                        if (!validation.valid) {
                            showUploadError(validation.error, 'profile');
                            profilePictureInput.value = '';
                            return;
                        }

                        // Store file and show upload button
                        profilePictureState.file = file;

                        // Show circular preview with yellow border
                        const reader = new FileReader();
                        reader.onload = function (e) {
                            const previewImg = document.createElement('img');
                            previewImg.src = e.target.result;
                            previewImg.className = 'pf-avatar';
                            previewImg.style.border = '3px solid #ffc107';
                            avatarPreview.parentElement.replaceChild(previewImg, avatarPreview);
                            // Update reference
                            avatarPreview = previewImg;
                        };
                        reader.readAsDataURL(file);

                        //handle automatic upload after selection
                        if (!profilePictureState.file) {
                            showUploadError('No file selected', 'profile');
                            return;
                        }

                        if (profilePictureState.isUploading) {
                            return; // Prevent duplicate submissions
                        }

                        profilePictureState.isUploading = true;
                        uploadProfilePictureBtn.disabled = true;
                        setUploadLoadingState('preparing', 'profile');

                        try {
                            profilePictureState.clientUploadId = generateClientUploadId();

                            // Step 1: Initialize upload
                            setUploadLoadingState('preparing', 'profile');
                            const initResponse = await initMediaUpload('PROFILE_PICTURE', profilePictureState.clientUploadId, {
                                file: profilePictureState.file
                            });

                            profilePictureState.mediaId = initResponse.mediaId;

                            // Step 2: Upload to S3
                            setUploadLoadingState('uploading', 'profile');
                            await uploadFileToS3(initResponse.uploadUrl, profilePictureState.file, (progress) => {
                                setUploadLoadingState('uploading', 'profile');
                            });

                            // Step 3: Complete upload
                            setUploadLoadingState('verifying', 'profile');
                            const completeResponse = await completeMediaUpload(profilePictureState.mediaId, profilePictureState.clientUploadId);

                            if (completeResponse.status === 'ACTIVE') {
                                // Upload successful
                                showUploadSuccess('Profile picture updated successfully!', 'profile');
                                setUploadLoadingState('completed', 'profile');

                                // Reset UI after success
                                setTimeout(() => {
                                    profilePictureState.file = null;
                                    profilePictureState.mediaId = null;
                                    profilePictureInput.value = '';
                                    uploadProfilePictureBtn.classList.add('d-none');
                                    uploadProfilePictureBtn.disabled = false;
                                    resetUploadState('profile');
                                    window.location.reload(); // Refresh to show the new profile picture
                                }, 1000);
                            } else {
                                showUploadError('Media status is not ACTIVE. Please try again.', 'profile');
                                uploadProfilePictureBtn.disabled = false;
                            }
                        } catch (error) {
                            showUploadError(error || 'Upload failed. Please try again.', 'profile');

                            // Show retry button if verification failed
                            if (profilePictureState.mediaId && profileRetryUploadBtn) {
                                profileRetryUploadBtn.classList.remove('d-none');
                            }

                            uploadProfilePictureBtn.disabled = false;
                        } finally {
                            profilePictureState.isUploading = false;
                        }

                    });
                }

                // Handle retry for failed verification
                if (profileRetryUploadBtn) {
                    profileRetryUploadBtn.addEventListener('click', async function (e) {
                        e.preventDefault();

                        if (!profilePictureState.mediaId || !profilePictureState.clientUploadId) {
                            showUploadError('No upload to retry', 'profile');
                            return;
                        }

                        profileRetryUploadBtn.disabled = true;
                        setUploadLoadingState('verifying', 'profile');

                        try {
                            const completeResponse = await retryUploadComplete(profilePictureState.mediaId, profilePictureState.clientUploadId);

                            if (completeResponse.status === 'ACTIVE') {
                                showUploadSuccess('Profile picture verified and updated!', 'profile');
                                setUploadLoadingState('completed', 'profile');

                                // Reset UI
                                setTimeout(() => {
                                    profilePictureState.file = null;
                                    profilePictureState.mediaId = null;
                                    profilePictureInput.value = '';
                                    uploadProfilePictureBtn?.classList.add('d-none');
                                    profileRetryUploadBtn.classList.add('d-none');
                                    resetUploadState('profile');
                                }, 1000);
                            } else {
                                showUploadError('Verification still failing. Please try uploading again.', 'profile');
                                profileRetryUploadBtn.disabled = false;
                            }
                        } catch (error) {
                            showUploadError(error || 'Retry failed. Please try again.', 'profile');
                            profileRetryUploadBtn.disabled = false;
                        }
                    });
                }

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
                    e.preventDefault();

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
                        showAlert('Please fix the errors above', 'danger');
                        return;
                    }

                    updateProfileBtn.disabled = true;

                    ajaxRequest(
                        form.dataset.url,
                        'POST',
                        new FormData(form),
                        function (response) {
                            updateProfileBtn.disabled = false;

                            if (response.responseCode === 'ERROR') {
                                showAlert(response.message || 'Unable to update profile', 'danger');
                                return;
                            }

                            if (changePasswordToggle.checked) {
                                let secondsRemaining = 3;
                                showAlert('Password updated successfully. Logging out in ' + secondsRemaining + '...', 'success');

                                const logoutCountdown = setInterval(function () {
                                    secondsRemaining--;

                                    if (secondsRemaining === 0) {
                                        clearInterval(logoutCountdown);
                                        window.location.href = '${ctx}/logout';
                                        return;
                                    }

                                    showAlert('Password updated successfully. Logging out in ' + secondsRemaining + '...', 'success');
                                }, 1000);
                                return;
                            }

                            showAlert(response.message || 'Profile updated successfully!', 'success');
                        },
                        function (xhr) {
                            updateProfileBtn.disabled = false;

                            const errorMessage = xhr.responseJSON && xhr.responseJSON.message
                                ? xhr.responseJSON.message
                                : 'Unable to update profile. Please try again.';
                            showAlert(errorMessage, 'danger');
                        },
                        { isFormData: true }
                    );
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