<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
      <div class="container-fluid vh-100 d-flex align-items-center justify-content-center bg-light">
          <div class="row w-100">
              <div class="col-md-6 col-lg-4 mx-auto">
                  <div class="card shadow-lg border-0">
                      <div class="card-body p-5">
                          <div class="text-center mb-4">
                              <i class="fas fa-comments fa-3x text-primary mb-3"></i>
                              <h2 class="h3 mb-1">Welcome Back</h2>
                              <p class="text-muted">Sign in to your account</p>
                          </div>

                           <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger">${fn:escapeXml(errorMessage)}</div>
                            </c:if>
                          <form action="${pageContext.request.contextPath}/authenticate" method="POST" id="loginForm">
                              <div class="mb-3">
                                  <label for="identifier" class="form-label">
                                      <i class="fas fa-user me-2"></i>Email or Phone
                                  </label>
                                  <input type="text" class="form-control form-control-lg" id="identifier"
                                         name="phoneNumberOrEmail" required placeholder="Enter email or phone number">
                              </div>

                              <div class="mb-4">
                                  <label for="password" class="form-label">
                                      <i class="fas fa-lock me-2"></i>Password
                                  </label>
                                  <div class="input-group">
                                      <input type="password" class="form-control form-control-lg" id="password"
                                             name="password" required placeholder="Enter password">
                                      <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                          <i class="fas fa-eye"></i>
                                      </button>
                                  </div>
                              </div>

                              <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
                                  <i class="fas fa-sign-in-alt me-2"></i>Sign In
                              </button>

                              <div class="text-center">
                                  <p class="mb-0">Don't have an account?
                                      <a href="${pageContext.request.contextPath}/register" class="text-decoration-none">
                                          Sign up here
                                      </a>
                                  </p>
                              </div>
                          </form>
                      </div>
                  </div>

                  <!-- Phone Auth Alternative -->
                 <!-- <div class="card mt-3 shadow-sm border-0">
                      <div class="card-body p-4">
                          <h6 class="card-title text-center mb-3">
                              <i class="fas fa-mobile-alt me-2"></i>Quick Phone Login
                          </h6>
                          <button class="btn btn-outline-primary w-100" id="phoneAuthBtn">
                              <i class="fas fa-sms me-2"></i>Login with SMS Code
                          </button>
                      </div>
                  </div>-->
              </div>
          </div>
      </div>
      <script>
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