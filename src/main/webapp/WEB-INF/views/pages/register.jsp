<%@ include file="/WEB-INF/views/common.jsp" %>
<div class="auth-wrapper">

    <%-- ═══ Left branding panel — decorative, lg+ screens only ═══ --%>
    <div class="auth-brand-panel d-none d-lg-flex flex-column align-items-center justify-content-center">
        <div class="auth-brand-logo">
            <i class="fas fa-user-plus fa-2x text-white"></i>
        </div>
        <h1 class="auth-brand-title mt-3 mb-2">Join ChatSphere</h1>
        <p class="auth-brand-tagline">Create your account and start connecting with people around you.</p>
        <div class="d-flex flex-column gap-3 mt-5 w-100" style="max-width: 280px;">
            <div class="auth-brand-feature">
                <i class="fas fa-bolt"></i>
                <span>Quick account setup</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-shield-alt"></i>
                <span>Secure &amp; private by design</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-comments"></i>
                <span>Real-time messaging</span>
            </div>
        </div>
    </div>

    <%-- ═══ Right form panel ═══ --%>
    <div class="auth-form-panel auth-form-panel--scroll">
        <div class="auth-card card border-0 w-100" style="max-width: 520px;">

            <%-- .card-body REQUIRED — JS showAlert() uses querySelector('.card-body') --%>
            <div class="card-body p-4 p-md-5">

                <%-- Mobile brand header — hidden on lg+ --%>
                <div class="text-center mb-4 d-lg-none">
                    <div class="auth-logo-mobile mx-auto">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <p class="fw-bold text-primary mb-0 mt-1 small">ChatSphere</p>
                </div>

                <h2 class="h4 fw-bold mb-1">Create account</h2>
                <p class="text-muted small mb-4">Fill in the details below to get started</p>

                <%-- Protected: JSTL c:if + fn:escapeXml --%>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 py-2" role="alert">
                        <i class="fas fa-exclamation-circle flex-shrink-0"></i>
                        <span>${fn:escapeXml(errorMessage)}</span>
                    </div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success d-flex align-items-center gap-2 py-2" role="alert">
                        <i class="fas fa-check-circle flex-shrink-0"></i>
                        <span>${fn:escapeXml(successMessage)}</span>
                    </div>
                </c:if>

                <%-- Protected: action URL + id="registerForm" used by JS --%>
                <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm">

                    <%-- Row 1: Name + Email --%>
                    <div class="row g-3 mb-3">
                        <div class="col-sm-6">
                            <label for="name" class="form-label fw-semibold small">Full Name <span class="text-danger">*</span></label>
                            <%-- Protected: id="name", name="name", c:out EL binding --%>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="fas fa-user text-muted"></i></span>
                                <input type="text" class="form-control" id="name" name="name" required
                                    placeholder="Your name" value="<c:out value='${param.name}'/>">
                            </div>
                        </div>

                        <div class="col-sm-6">
                            <label for="email" class="form-label fw-semibold small">Email <span class="text-danger">*</span></label>
                            <%-- Protected: id="email", name="email", c:out EL binding --%>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="fas fa-envelope text-muted"></i></span>
                                <input type="email" class="form-control" id="email" name="email" required
                                    placeholder="your@email.com" value="<c:out value='${param.email}'/>">
                            </div>
                        </div>
                    </div>

                    <%-- Phone --%>
                    <div class="mb-3">
                        <label for="phone" class="form-label fw-semibold small">Phone Number <span class="text-muted fw-normal">(optional)</span></label>
                        <%-- Protected: id="phone", name="phoneNumber", c:out EL binding --%>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-phone text-muted"></i></span>
                            <input type="tel" class="form-control" id="phone" name="phoneNumber"
                                placeholder="+91 5551234567" value="<c:out value='${param.phoneNumber}'/>">
                        </div>
                    </div>

                    <%-- Row 2: Password + Confirm — structure kept for JS strength meter --%>
                    <%-- JS uses: getElementById('password').parentNode.parentNode to inject #passwordStrength --%>
                    <div class="row g-3 mb-4">
                        <div class="col-sm-6">
                            <label for="password" class="form-label fw-semibold small">Password <span class="text-danger">*</span></label>
                            <%-- Protected: id="password", name="password", id="togglePassword1" --%>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" class="form-control" id="password" name="password"
                                    required placeholder="Create password">
                                <button class="btn btn-outline-secondary" type="button" id="togglePassword1">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <%-- Protected: id="passwordError" used by JS --%>
                            <div class="invalid-feedback d-block small" id="passwordError"></div>
                            <div class="form-text">Min 8 chars with upper, lower, number &amp; symbol</div>
                        </div>

                        <div class="col-sm-6">
                            <label for="confirm_password" class="form-label fw-semibold small">Confirm Password <span class="text-danger">*</span></label>
                            <%-- Protected: id="confirm_password", id="togglePassword2" --%>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="fas fa-lock text-muted"></i></span>
                                <input type="password" class="form-control" id="confirm_password" required
                                    placeholder="Confirm password">
                                <button class="btn btn-outline-secondary" type="button" id="togglePassword2">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <%-- Protected: id="confirmPasswordError" used by JS --%>
                            <div class="invalid-feedback d-block small" id="confirmPasswordError"></div>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 mb-4">
                        <i class="fas fa-user-plus me-2"></i>Create Account
                    </button>

                    <div class="text-center">
                        <p class="text-muted small mb-0">Already have an account?
                            <%-- Protected: href URL mapping --%>
                            <a href="${pageContext.request.contextPath}/login"
                               class="fw-semibold text-decoration-none link-primary">Sign in</a>
                        </p>
                    </div>

                </form>
            </div><%-- /.card-body --%>
        </div><%-- /.auth-card --%>
    </div><%-- /.auth-form-panel --%>

</div><%-- /.auth-wrapper --%>

    <script nonce="${cspNonce}">
        document.addEventListener('DOMContentLoaded', function () {
            function setupPasswordToggle(toggleId, passwordId) {
                const toggleBtn = document.getElementById(toggleId);
                const passwordField = document.getElementById(passwordId);

                toggleBtn.addEventListener('click', function () {
                    const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
                    passwordField.setAttribute('type', type);
                    const icon = this.querySelector('i');
                    icon.classList.toggle('fa-eye');
                    icon.classList.toggle('fa-eye-slash');
                });
            }

            setupPasswordToggle('togglePassword1', 'password');
            setupPasswordToggle('togglePassword2', 'confirm_password');

            const registerForm = document.getElementById('registerForm');
            const passwordField = document.getElementById('password');
            const confirmPasswordField = document.getElementById('confirm_password');
            const passwordError = document.getElementById('passwordError');
            const confirmPasswordError = document.getElementById('confirmPasswordError');
            const validator = new Validator();

            function validatePassword() {
                const password = passwordField.value;
                const confirmPassword = confirmPasswordField.value;
                let isValid = true;

                passwordField.classList.remove('is-invalid');
                confirmPasswordField.classList.remove('is-invalid');
                passwordError.textContent = '';
                confirmPasswordError.textContent = '';
                passwordField.setCustomValidity('');
                confirmPasswordField.setCustomValidity('');

                if (password && !validator.isStrongPassword(password)) {
                    passwordField.classList.add('is-invalid');
                    passwordError.textContent = 'Password must include uppercase, lowercase, number, and special character';
                    passwordField.setCustomValidity('Password is not strong enough');
                    isValid = false;
                }

                if (confirmPassword && password !== confirmPassword) {
                    confirmPasswordField.classList.add('is-invalid');
                    confirmPasswordError.textContent = 'Passwords do not match';
                    confirmPasswordField.setCustomValidity('Passwords do not match');
                    isValid = false;
                }

                return isValid;
            }

            confirmPasswordField.addEventListener('input', validatePassword);

            passwordField.addEventListener('input', function () {
                const password = this.value;
                const strength = calculatePasswordStrength(password);
                updatePasswordStrength(strength);
                validatePassword();
            });

            registerForm.addEventListener('submit', function (e) {
                if (!validatePassword()) {
                    e.preventDefault();
                    showAlert('Please fix the password errors above', 'error');
                    return;
                }

                const submitBtn = this.querySelector('button[type="submit"]');
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Creating Account...';
                submitBtn.disabled = true;
            });
        });

        function calculatePasswordStrength(password) {
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            return strength;
        }

        function updatePasswordStrength(strength) {
            const colors = ['danger', 'danger', 'warning', 'info', 'success', 'success'];
            const texts = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong', 'Very Strong'];

            let strengthIndicator = document.getElementById('passwordStrength');
            if (!strengthIndicator) {
                strengthIndicator = document.createElement('div');
                strengthIndicator.id = 'passwordStrength';
                strengthIndicator.className = 'form-text';
                document.getElementById('password').parentNode.parentNode.appendChild(strengthIndicator);
            }

            strengthIndicator.innerHTML =
                '<small class="text-' + colors[strength] + '">' +
                'Password Strength: ' + texts[strength] +
                '</small>';
        }

        function showAlert(message, type) {
            const alertClass = type === 'error' ? 'alert-danger' : 'alert-info';
            const alertHtml =
                '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
                message +
                '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                '</div>';

            const existingAlert = document.querySelector('.alert');
            if (existingAlert) {
                existingAlert.remove();
            }

            document.querySelector('.card-body').insertAdjacentHTML('afterbegin', alertHtml);
        }
    </script>