<%@ include file="/WEB-INF/views/common.jsp" %>
<div class="auth-wrapper">

    <%-- ═══ Left branding panel — decorative, lg+ screens only ═══ --%>
    <div class="auth-brand-panel d-none d-lg-flex flex-column align-items-center justify-content-center">
        <div class="auth-brand-logo">
            <i class="fas fa-key fa-2x text-white"></i>
        </div>
        <h1 class="auth-brand-title mt-3 mb-2">Reset Password</h1>
        <p class="auth-brand-tagline">Securely reset your password and regain access to your account.</p>
        <div class="d-flex flex-column gap-3 mt-5 w-100" style="max-width: 280px;">
            <div class="auth-brand-feature">
                <i class="fas fa-shield-alt"></i>
                <span>Secure reset process</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-lock"></i>
                <span>Strong password enforcement</span>
            </div>
            <div class="auth-brand-feature">
                <i class="fas fa-sign-in-alt"></i>
                <span>Back in seconds</span>
            </div>
        </div>
    </div>

    <%-- ═══ Right form panel ═══ --%>
    <div class="auth-form-panel">
        <div class="auth-card card border-0">

            <%-- .card-body REQUIRED — JS showAlert() uses querySelector('.card-body') --%>
            <div class="card-body">

                <%-- Mobile brand header — hidden on lg+ --%>
                <div class="text-center mb-4 d-lg-none">
                    <div class="auth-logo-mobile mx-auto">
                        <i class="fas fa-key"></i>
                    </div>
                    <p class="fw-bold text-primary mb-0 mt-1 small">ChatSphere</p>
                </div>

                <h2 class="h4 fw-bold mb-1">Forgot password?</h2>
                <p class="text-muted small mb-4">Enter your account details and a new password below</p>

                <%-- Protected: JSTL c:if + fn:escapeXml --%>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger d-flex align-items-center gap-2 py-2" role="alert">
                        <i class="fas fa-exclamation-circle flex-shrink-0"></i>
                        <span>${fn:escapeXml(errorMessage)}</span>
                    </div>
                </c:if>

                <%-- Protected: action URL + id="forgotPasswordForm" + autocomplete="off" used by JS --%>
                <form action="${pageContext.request.contextPath}/forgot-password" method="POST" id="forgotPasswordForm" autocomplete="off">

                    <div class="mb-3">
                        <label for="identifier" class="form-label fw-semibold small">Email or Phone</label>
                        <%-- Protected: id="identifier", name="phoneNumberOrEmail", EL value binding, autocomplete="off" --%>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-user text-muted"></i></span>
                            <input type="text" class="form-control" id="identifier"
                                   name="phoneNumberOrEmail" required placeholder="Enter email or phone number"
                                   value="${fn:escapeXml(auth.phoneNumberOrEmail)}" autocomplete="off">
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label fw-semibold small">New Password</label>
                        <%-- Protected: id="password", name="password", id="togglePassword", autocomplete="new-password" --%>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-lock text-muted"></i></span>
                            <input type="password" class="form-control" id="password"
                                   name="password" required placeholder="Enter new password" autocomplete="new-password">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 mb-4">
                        <i class="fas fa-save me-2"></i>Reset Password
                    </button>

                    <div class="text-center">
                        <p class="text-muted small mb-0">Remembered your password?
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
      document.addEventListener('DOMContentLoaded', function() {
          const togglePassword = document.getElementById('togglePassword');
          const passwordField = document.getElementById('password');

          togglePassword.addEventListener('click', function() {
              const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
              passwordField.setAttribute('type', type);

              const icon = this.querySelector('i');
              icon.classList.toggle('fa-eye');
              icon.classList.toggle('fa-eye-slash');
          });

          const forgotPasswordForm = document.getElementById('forgotPasswordForm');
          forgotPasswordForm.addEventListener('submit', function(e) {
              const identifier = document.getElementById('identifier').value.trim();
              const password = document.getElementById('password').value;

              if (!identifier) {
                  e.preventDefault();
                  showAlert('Please enter your email or phone number', 'error');
                  return;
              }

              if (!password) {
                  e.preventDefault();
                  showAlert('Please enter your new password', 'error');
                  return;
              }

              const submitBtn = this.querySelector('button[type="submit"]');
              submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Resetting...';
              submitBtn.disabled = true;
          });
      });

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
