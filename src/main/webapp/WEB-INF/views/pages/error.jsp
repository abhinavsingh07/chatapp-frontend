 <style>
    .error-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 2rem;
    }
    .error-icon {
    font-size: 4rem;
    color: #dc3545;
    }
 </style>
 <div class="error-container">
    <div class="card shadow-lg p-4">
       <div class="card-body">
          <div class="error-icon mb-3"></div>
          <h3 class="card-title text-danger">Oops! Something went wrong.</h3>
          <p class="card-text">We're unable to connect to the backend server right now.<br>Please try again later or contact support if the issue persists.</p>
          <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-danger mt-3">Return to Login</a>
       </div>
    </div>
 </div>
