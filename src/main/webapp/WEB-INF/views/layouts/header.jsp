  <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
                <i class="fas fa-comments me-2"></i>ChatApp
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link {% if request.endpoint == 'chat_list' %}active{% endif %}" href="${pageContext.request.contextPath}/home">
                            <i class="fas fa-home me-1"></i>Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {% if request.endpoint == 'contacts' %}active{% endif %}" href="${pageContext.request.contextPath}/contacts">
                            <i class="fas fa-users me-1"></i>Contacts
                        </a>
                    </li>
                </ul>
                
                <!-- Search Form -->
                <form class="d-flex me-3" action="${pageContext.request.contextPath}/search" method="GET">
                    <div class="input-group">
                        <input class="form-control" type="search" name="q" placeholder="Search..." aria-label="Search">
                        <button class="btn btn-outline-light" type="submit">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>
                
                <!-- User Menu -->
                <div class="dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i>
                        <c:if test="${not empty username}">
                            <span>Hello! ${username}!</span>
                        </c:if>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                            <i class="fas fa-user me-2"></i>Profile
                        </a></li>
                       <li><a class="dropdown-item" href="${pageContext.request.contextPath}/settings">
                            <i class="fas fa-cog me-2"></i>Settings
                        </a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>
    <!-- Flash Messages -->
   <!-- <div class="container-fluid mt-3">
      <div class="alert alert-{{ 'danger' if category == 'error' else 'primary' if category == 'info' else category }} alert-dismissible fade show" role="alert">
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    </div>-->
