<%@ include file="/WEB-INF/views/common.jsp" %>
<div class="auth-wrapper">

    <%-- ═══ Left branding panel — visible on lg+ screens only, purely decorative ═══ --%>
    <div class="auth-brand-panel d-none d-lg-flex flex-column align-items-center justify-content-center">
        <div class="auth-brand-logo">
            <i class="fas fa-comments fa-2x text-white"></i>
        </div>
        <h1 class="auth-brand-title mt-3 mb-2">ChatSphere</h1>
        <p class="auth-brand-tagline">Connect, chat, and collaborate<br>in real-time with your contacts.</p>
        <div class="d-flex flex-column gap-3 mt-5 w-100" style="max-width: 280px;">
            <div class="auth-brand-feature">
                <i class="fas fa-shield-alt"></i>
                <span>Secure JWT sessions</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-bolt"></i>
                <span>Real-time WebSocket chat</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-users"></i>
                <span>Easy contact management</span>
            </div>
        </div>
    </div>

    <%-- ═══ Right form panel ═══ --%>
    <div class="auth-form-panel">
        <div class="auth-card card border-0">

            <%-- .card-body class is REQUIRED — inline JS showAlert() uses querySelector('.card-body') --%>
            <div class="card-body">

                <%-- Mobile brand header — hidden on lg+ --%>
                <div class="text-center mb-4 d-lg-none">
                    <div class="auth-logo-mobile mx-auto">
                        <i class="fas fa-comments"></i>
                    </div>
                    <p class="fw-bold text-primary mb-0 mt-1 small">ChatSphere</p>
                </div>

                <h2 class="h4 fw-bold mb-1">Welcome back</h2>
                <p class="text-muted small mb-4">Sign in to continue to ChatSphere</p>

                <%-- Protected: JSTL c:if conditions + fn:escapeXml EL expressions --%>
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

                <%-- Protected: action URL + id="loginForm" referenced by JS --%>
                <form action="${pageContext.request.contextPath}/authenticate" method="POST" id="loginForm">

                    <div class="mb-3">
                        <label for="identifier" class="form-label fw-semibold small">Email or Phone</label>
                        <%-- Bootstrap input-group with icon prefix --%>
                        <div class="input-group">
                            <span class="input-group-text bg-light">
                                <i class="fas fa-user text-muted"></i>
                            </span>
                            <%-- Protected: id="identifier", name="phoneNumberOrEmail", EL value binding --%>
                            <input type="text" class="form-control" id="identifier"
                                   name="phoneNumberOrEmail" required placeholder="Enter email or phone number"
                                   value="${fn:escapeXml(auth.phoneNumberOrEmail)}">
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label for="password" class="form-label fw-semibold small mb-0">Password</label>
                            <%-- Protected: href URL mapping --%>
                            <a href="${pageContext.request.contextPath}/forgot-password"
                               class="small text-decoration-none link-primary">Forgot password?</a>
                        </div>
                        <%-- Bootstrap input-group: icon + field + toggle. id="password" + id="togglePassword" used by JS --%>
                        <div class="input-group">
                            <span class="input-group-text bg-light">
                                <i class="fas fa-lock text-muted"></i>
                            </span>
                            <input type="password" class="form-control" id="password"
                                   name="password" required placeholder="Enter password">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 mb-4">
                        <i class="fas fa-sign-in-alt me-2"></i>Sign In
                    </button>

                    <div class="text-center">
                        <p class="text-muted small mb-0">Don't have an account?
                            <%-- Protected: href URL mapping --%>
                            <a href="${pageContext.request.contextPath}/register"
                               class="fw-semibold text-decoration-none link-primary">Sign up</a>
                        </p>
                    </div>

                </form>
            </div><%-- /.card-body --%>
        </div><%-- /.auth-card --%>
    </div><%-- /.auth-form-panel --%>

</div><%-- /.auth-wrapper --%>

<%-- Protected: nonce EL expression + entire JS block behavior unchanged --%>
<script nonce="${requestScope['cspNonce']}">
document.addEventListener('DOMContentLoaded', function() {
    // Toggle password visibility
    const togglePassword = document.getElementById('togglePassword');
    const passwordField = document.getElementById('password');

    togglePassword.addEventListener('click', function() {
        const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordField.setAttribute('type', type);

        const icon = this.querySelector('i');
        icon.classList.toggle('fa-eye');
        icon.classList.toggle('fa-eye-slash');
    });

    // Form validation
    const loginForm = document.getElementById('loginForm');
    loginForm.addEventListener('submit', function(e) {
        const identifier = document.getElementById('identifier').value.trim();
        const password = document.getElementById('password').value;

        if (!identifier) {
            e.preventDefault();
            showAlert('Please enter your email or phone number', 'error');
            return;
        }

        if (!password) {
            e.preventDefault();
            showAlert('Please enter your password', 'error');
            return;
        }

        // Show loading state
        const submitBtn = this.querySelector('button[type="submit"]');
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Signing In...';
        submitBtn.disabled = true;
    });

    // Phone auth placeholder
   /** document.getElementById('phoneAuthBtn').addEventListener('click', function() {
        showAlert('Phone authentication will be integrated with backend service', 'info');
    });**/
});

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
