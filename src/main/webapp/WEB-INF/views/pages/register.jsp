<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <div class="container-fluid vh-100 d-flex align-items-center justify-content-center bg-light">
            <div class="row w-100">
                <div class="col-md-8 col-lg-6 mx-auto">
                    <div class="card shadow-lg border-0">
                        <div class="card-body p-5">
                            <div class="text-center mb-4">
                                <i class="fas fa-user-plus fa-3x text-primary mb-3"></i>
                                <h2 class="h3 mb-1">Create Account</h2>
                                <p class="text-muted">Join the conversation</p>
                            </div>
                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger">${fn:escapeXml(errorMessage)}</div>
                            </c:if>
                            <c:if test="${not empty successMessage}">
                                <div class="alert alert-success">${fn:escapeXml(successMessage)}</div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="name" class="form-label">
                                            <i class="fas fa-at me-2"></i>Name *
                                        </label>
                                        <input type="text" class="form-control" id="name" name="name" required
                                            placeholder="Enter name" value="<c:out value='${param.name}'/>">
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="email" class="form-label">
                                            <i class="fas fa-envelope me-2"></i>Email *
                                        </label>
                                        <input type="email" class="form-control" id="email" name="email" required
                                            placeholder="your@email.com" value="<c:out value='${param.email}'/>">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="phone" class="form-label">
                                        <i class="fas fa-phone me-2"></i>Phone Number
                                    </label>
                                    <input type="tel" class="form-control" id="phone" name="phoneNumber"
                                        placeholder="+91 5551234567" value="<c:out value='${param.phoneNumber}'/>">
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="password" class="form-label">
                                            <i class="fas fa-lock me-2"></i>Password *
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="password" name="password"
                                                required placeholder="Create password">
                                            <button class="btn btn-outline-secondary" type="button"
                                                id="togglePassword1">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                        <div class="form-text">At least 8 characters</div>
                                    </div>

                                    <div class="col-md-6 mb-4">
                                        <label for="confirm_password" class="form-label">
                                            <i class="fas fa-lock me-2"></i>Confirm Password *
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="confirm_password" required
                                                placeholder="Confirm password">
                                            <button class="btn btn-outline-secondary" type="button"
                                                id="togglePassword2">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
                                    <i class="fas fa-user-plus me-2"></i>Create Account
                                </button>

                                <div class="text-center">
                                    <p class="mb-0">Already have an account?
                                        <a href="${pageContext.request.contextPath}/login" class="text-decoration-none">
                                            Sign in here
                                        </a>
                                    </p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
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

                confirmPasswordField.addEventListener('input', function () {
                    if (this.value && this.value !== passwordField.value) {
                        this.setCustomValidity('Passwords do not match');
                        this.classList.add('is-invalid');
                    } else {
                        this.setCustomValidity('');
                        this.classList.remove('is-invalid');
                    }
                });

                passwordField.addEventListener('input', function () {
                    const password = this.value;
                    const strength = calculatePasswordStrength(password);
                    updatePasswordStrength(strength);
                });

                registerForm.addEventListener('submit', function (e) {
                    const password = passwordField.value;
                    const confirmPassword = confirmPasswordField.value;

                    if (password !== confirmPassword) {
                        e.preventDefault();
                        showAlert('Passwords do not match', 'error');
                        return;
                    }

                    if (password.length < 8) {
                        e.preventDefault();
                        showAlert('Password must be at least 8 characters long', 'error');
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

                strengthIndicator.innerHTML = `
        <small class="text-${colors[strength]}">
            Password Strength: ${texts[strength]}
        </small>
    `;
            }

            function showAlert(message, type) {
                const alertClass = type === 'error' ? 'alert-danger' : 'alert-info';
                const alertHtml = `
        <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

                const existingAlert = document.querySelector('.alert');
                if (existingAlert) {
                    existingAlert.remove();
                }

                document.querySelector('.card-body').insertAdjacentHTML('afterbegin', alertHtml);
            }
        </script>