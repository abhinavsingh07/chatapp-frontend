# AGENTS.md — ChatSphere Application

## Project Overview

**ChatSphere** is a Spring Boot web application (packaged as a WAR) that serves as the **frontend/UI layer** of a chat system. It communicates with a backend API service (`api-dispatcher-service`) via a custom local JAR client. The app renders JSP views, handles authentication via JWT cookies, and supports real-time chat using WebSockets.

- **Group ID:** `com.example`
- **Artifact ID:** `chatsphere`
- **Version:** `0.0.1-SNAPSHOT`
- **Java Version:** 17
- **Spring Boot Version:** 3.5.4
- **Packaging:** WAR
- **Context Path:** `/chat`
- **Port:** `8081`

---

## Project Root Structure

```
chatsphere/                        ← workspace root
└── chatsphere/                    ← Maven module root
    ├── pom.xml                    ← Maven build descriptor
    ├── chatsphere.iml             ← IntelliJ module file
    ├── HELP.md                    ← Spring Boot generated help
    ├── mvnw / mvnw.cmd            ← Maven wrapper scripts
    ├── logs/
    │   └── app.log                ← Runtime application log output
    ├── libs-repo/                 ← Local Maven repository for custom JARs
    │   └── com/apiservice/
    │       └── api-dispatcher-service/
    │           └── 0.0.1-SNAPSHOT/
    │               ├── api-dispatcher-service-0.0.1-SNAPSHOT.pom
    │               ├── maven-metadata-local.xml
    │               └── _remote.repositories
    └── src/
        ├── main/
        │   ├── java/              ← Java source code
        │   ├── resources/         ← application.properties + static assets
        │   └── webapp/            ← JSP views (WEB-INF)
        └── test/
            └── java/              ← Test source code
```

---

## Java Source — `src/main/java/com/example/chatsphere/`

```
src/main/java/com/example/chatsphere/
│
├── ChatsphereApplication.java
│       Spring Boot entry point.
│       @SpringBootApplication + @ComponentScan for both
│       "com.example.chatsphere" and "com.apiservice.client" packages.
│
├── config/
│   ├── ApplicationConfig.java
│   │       MVC configuration class.
│   │       - Registers InternalResourceViewResolver (prefix: /WEB-INF/views/, suffix: .jsp)
│   │       - Declares ApiDispatcherService bean (base URL: http://localhost/synk)
│   │       - Registers UserInterceptor on all paths except /api/**, /static/**,
│   │         /login, /register, /forgot-password, /, /css/**, /js/**, /images/**
│   │
│   ├── CspNonceFilter.java
│   │       OncePerRequestFilter that generates a cryptographically secure
│   │       Base64 nonce (16 bytes via SecureRandom) per request.
│   │       - Sets "cspNonce" as a request attribute (used in JSP <script> tags)
│   │       - Sets Content-Security-Policy response header with nonce inline
│   │         allowing scripts, font-src, img-src blob/data, WS connect-src
│   │
│   └── UserInterceptor.java
│           HandlerInterceptor (preHandle).
│           - Skips /login, /register, /authenticate, /forgot-password, /api, /icons
│           - For all other paths: calls userService.getUserMe() to validate session
│           - On success: sets "userId" and "username" as request attributes
│           - On failure: redirects to /login (session expired)
│
├── controller/
│   ├── AuthController.java
│   │       Handles authentication-related page routes and actions.
│   │       GET  /            → login page (index page with login view)
│   │       GET  /login       → login page
│   │       GET  /register    → registration page
│   │       GET  /forgot-password → forgot password page
│   │       GET  /logout      → clears auth cookies, redirects to /login
│   │       GET  /error       → error page (optional ?message= param)
│   │       POST /api/auth/login    → calls AuthService.login(), sets JWT cookies
│   │       POST /api/auth/register → calls AuthService.register()
│   │
│   ├── ChatController.java
│   │       Handles chat room page and chat-related API endpoints.
│   │       GET  /chat-room/{conversationId}/{toUserId}
│   │               → loads messages + toUser details, renders chat-room view
│   │       GET  /api/conversation/get-or-create/{fromUserId}/{toUserId}
│   │               → @ResponseBody: returns or creates a conversationId
│   │       GET  /api/messages/conversation/{conversationId}
│   │               → @ResponseBody: returns list of MessageDTO
│   │
│   ├── ContactController.java
│   │       Handles contacts page and contacts API endpoints.
│   │       GET    /contacts              → renders contacts page view
│   │       GET    /api/contact/{userId}  → @ResponseBody: list of ContactUserDTO
│   │       POST   /api/contact/add       → @ResponseBody: add new contact
│   │       DELETE /api/contact/{contactId}/remove → @ResponseBody: remove contact
│   │
│   ├── HomeController.java
│   │       Handles home and settings page routes.
│   │       GET /home      → loads conversation list (ConversationLastMsgDTO),
│   │                         sets "chatData" model attr, renders chat-home view
│   │       GET /settings  → renders settings page view
│   │
│   └── UserController.java
│           Handles profile page and user API endpoints.
│           GET  /profile                      → loads logged-in user details, renders profile view
│           GET  /api/user/all                 → @ResponseBody: list of all UserDTO
│           GET  /api/user/{userId}            → @ResponseBody: single UserDTO
│           GET  /api/user/lastActiveStatus    → @ResponseBody: UserStatusDTO (?userId=)
│           POST /api/user/update/{userId}     → @ResponseBody: update user profile
│
├── service/
│   ├── AuthService.java                  ← Interface
│   ├── ChatService.java                  ← Interface
│   ├── ContactService.java               ← Interface
│   ├── UserService.java                  ← Interface
│   │
│   ├── AuthenticatedApiService.java
│   │       Core HTTP client wrapper around ApiDispatcherService (from JAR).
│   │       - Overloaded call() for simple Class<T> and ParameterizedTypeReference<T>
│   │       - On ApiException: triggers RefreshTokenService.refreshCurrentSession()
│   │         then rebuilds headers and retries exactly once
│   │       - If retry also fails: throws SessionExpiredException
│   │
│   ├── CookieService.java
│   │       Utility service for reading and writing HTTP cookies.
│   │       - Sets JWT access token cookie
│   │       - Sets refresh token cookie
│   │       - clearAuthCookies(): expires both cookies on logout
│   │
│   ├── RefreshTokenService.java
│   │       Manages the silent refresh token flow.
│   │       - Reads refresh token from cookie
│   │       - Calls auth.refresh endpoint via ApiDispatcherService (no auth retry)
│   │       - On success: writes new JWT cookie
│   │       - Returns boolean: true if refresh succeeded
│   │
│   └── impl/
│       ├── AuthServiceImpl.java
│       │       Implements AuthService using AuthenticatedApiService + EndpointRegistry.
│       │       login()          → POST /auth/authenticate
│       │       register()       → POST /auth/register
│       │       logout()         → POST /auth/logout
│       │       forgotPassword() → POST /auth/forgot-password
│       │
│       ├── ChatServiceImpl.java
│       │       Implements ChatService using AuthenticatedApiService + EndpointRegistry.
│       │       getMessagesByConversationId() → GET /api/messages/conversation/{id}
│       │       getOrCreateConversationId()   → POST /api/conversations/get-or-create/{from}/{to}
│       │       getLastMessageByLoggedInUserId() → GET /api/conversations/{userId}/last-message
│       │
│       ├── ContactServiceImpl.java
│       │       Implements ContactService using AuthenticatedApiService + EndpointRegistry.
│       │       getContactsByUserId() → GET /api/contacts/search
│       │       addContact()          → POST /api/contacts
│       │       removeContact()       → DELETE /api/contacts/{contactId}
│       │
│       └── UserServiceImpl.java
│               Implements UserService using AuthenticatedApiService + EndpointRegistry.
│               getUserMe()              → GET /api/users/me
│               getByUserId()            → GET /api/users/{userId}
│               getAllUsers()            → GET /api/users/all
│               getUserLastActiveStatus()→ GET /api/users/lastActiveStatus
│               updateUserById()         → PUT /api/users/{userId}
│
├── dto/
│   ├── AuthDTO.java                  ← Login/register request body (username, password)
│   ├── ContactDTO.java               ← Add-contact request body (userId, contactUserId)
│   ├── ContactUserDTO.java           ← Contact entry combined with user details
│   ├── ConversationLastMsgDTO.java   ← Last message summary per conversation (home list)
│   ├── MessageDTO.java               ← Single chat message (id, content, senderId, timestamp)
│   ├── RefreshTokenDTO.java          ← Refresh token request/response body
│   ├── UserDTO.java                  ← Full user profile (id, name, email, avatar, etc.)
│   └── UserStatusDTO.java            ← User presence: online flag + lastActiveAt timestamp
│
├── exception/
│   ├── GlobalExceptionHandler.java
│   │       @ControllerAdvice — catches SessionExpiredException and
│   │       other unhandled exceptions; redirects to /login or /error page.
│   │
│   └── SessionExpiredException.java
│           RuntimeException thrown by AuthenticatedApiService when
│           the JWT is expired and the refresh token flow also fails.
│
├── mappings/
│   ├── EndpointRegistry.java
│   │       @Component("endpointRegistry") — immutable Map of logical keys
│   │       to ApiEndpoint(path, HttpMethod). Central registry for all
│   │       backend API calls. See "API Endpoint Registry" section below.
│   │
│   ├── ErrorMessageMappings.java
│   │       Constants for user-facing error message strings.
│   │
│   └── PageMappings.java
│           Constants for JSP view names and redirect strings:
│           INDEX_PAGE="index", VIEW_PLACEHOLDER="view",
│           LOGIN_VIEW="login", REGISTER_VIEW="register",
│           HOME_PAGE_VIEW="chat-home", CHAT_PAGE_VIEW="chat-room",
│           PROFILE_VIEW="profile", SETTINGS_VIEW="settings",
│           CONTACTS_VIEW="contact", ERROR_VIEW="error",
│           REDIRECT_LOGIN="redirect:/login", REDIRECT_HOME="redirect:/home"
│
└── util/
    ├── ApiRequestBuilderUtil.java
    │       Builds ApiRequest objects from EndpointRegistry entries.
    │       getDefaultHeaders(): constructs HttpHeaders reading JWT token
    │       from the current request cookie.
    │       Inner class ApiEndpoint holds path + HttpMethod.
    │
    ├── JwtResponse.java
    │       Response wrapper for JWT token from backend: accessToken, refreshToken.
    │
    └── SuccessResponse.java
            Generic API response wrapper used across the app:
            fields: status (String), message (String), data (List<T>).
```

---

## Test Source — `src/test/java/com/example/chatsphere/`

```
src/test/java/com/example/chatsphere/
└── ChatsphereApplicationTests.java
        Basic Spring Boot context load test (@SpringBootTest).
```

---

## Resources — `src/main/resources/`

```
src/main/resources/
│
├── application.properties
│       spring.application.name=chat
│       server.servlet.context-path=/chat
│       server.port=8081
│       logging.file.name=logs/app.log
│       logging.level.root=INFO
│       logging.pattern.console / logging.pattern.file configured
│
└── static/
    ├── css/
    │   ├── bootstrap.min.css           ← Bootstrap 5 — vendor stylesheet
    │   └── app/
    │       └── styles.css              ← Custom application stylesheet
    │
    ├── js/
    │   ├── bootstrap.bundle.min.js     ← Bootstrap JS bundle — vendor
    │   ├── fontawesome.min.js          ← Font Awesome icons kit — vendor
    │   ├── jquery-3.7.1.min.js         ← jQuery 3.7.1 — vendor
    │   └── app/
    │       ├── ajax.js                 ← Reusable AJAX helper (wraps jQuery $.ajax)
    │       ├── app.js                  ← Main app init and shared utilities
    │       ├── chat.js                 ← Chat room UI: send message, render messages, scroll
    │       ├── user-presence-poller.js ← Polls /api/user/lastActiveStatus for online badges
    │       ├── validator.js            ← Client-side form validation helpers
    │       └── ws-worker.js            ← WebSocket lifecycle manager (connect/reconnect/send)
    │
    └── icons/
        └── site.webmanifest            ← PWA web app manifest (icons, theme color, name)
```

---

## Webapp (JSP Views) — `src/main/webapp/`

```
src/main/webapp/
└── WEB-INF/
    └── views/
        │
        ├── common.jsp
        │       Shared JSTL taglib declarations and common variables
        │       included by all pages.
        │
        ├── index.jsp
        │       Root layout shell. Includes header, footer, style/script
        │       fragments, and dynamically includes the page view set
        │       via the "view" model attribute (e.g. pages/login.jsp).
        │
        ├── fragments/
        │   ├── styles.jsp      ← CSS <link> tags fragment (Bootstrap, app styles)
        │   └── scripts.jsp     ← JS <script> tags fragment (jQuery, Bootstrap, app JS)
        │
        ├── layouts/
        │   ├── header.jsp      ← Top navigation bar (nav links, user avatar, logout)
        │   └── footer.jsp      ← Page footer
        │
        └── pages/
            ├── login.jsp           ← Login form; calls POST /api/auth/login via AJAX
            ├── register.jsp        ← Registration form; calls POST /api/auth/register
            ├── forgot-password.jsp ← Forgot password form
            ├── chat-home.jsp       ← Conversation list; contact search; start new chat
            ├── chat-room.jsp       ← Message thread view; WebSocket send/receive via ws-worker.js
            ├── contact.jsp         ← Contacts list; add/remove contact actions
            ├── profile.jsp         ← User profile display and edit form
            ├── settings.jsp        ← App settings page
            └── error.jsp           ← Generic error display page
```

---

## Local Maven Repository — `libs-repo/`

```
libs-repo/
└── com/apiservice/api-dispatcher-service/
    └── 0.0.1-SNAPSHOT/
        ├── api-dispatcher-service-0.0.1-SNAPSHOT.pom
        ├── maven-metadata-local.xml
        └── _remote.repositories
```

This folder is declared as a local file-system Maven repository in `pom.xml`.
It provides three key classes used throughout the app:

| Class | Package | Purpose |
|---|---|---|
| `ApiDispatcherService` | `com.apiservice.client` | Executes HTTP calls to the backend |
| `ApiRequest` | `com.apiservice.client` | Fluent builder for HTTP request (path, headers, body, params) |
| `ApiException` | `com.apiservice.client` | Thrown on non-2xx backend responses |

---

## API Endpoint Registry

All backend API calls are registered in `EndpointRegistry.java` as immutable key → `(path, method)` entries:

| Key | Backend Path | HTTP Method |
|---|---|---|
| `auth.login` | `/auth/authenticate` | POST |
| `auth.register` | `/auth/register` | POST |
| `auth.refresh` | `/auth/refresh` | POST |
| `auth.forgotPassword` | `/auth/forgot-password` | POST |
| `auth.logout` | `/auth/logout` | POST |
| `user.getUserMe` | `/api/users/me` | GET |
| `user.getByUserId` | `/api/users/{userId}` | GET |
| `user.getAllUsers` | `/api/users/all` | GET |
| `user.getUserLastActiveStatus` | `/api/users/lastActiveStatus` | GET |
| `user.updateUserById` | `/api/users/{userId}` | PUT |
| `message.getByConvId` | `/api/messages/conversation/{conversationId}` | GET |
| `conv.getOrCreateConv` | `/api/conversations/get-or-create/{fromUserId}/{toUserId}` | POST |
| `conv.getLastConversationByLoggedInUser` | `/api/conversations/{userId}/last-message` | GET |
| `contact.add` | `/api/contacts` | POST |
| `contact.remove` | `/api/contacts/{contactId}` | DELETE |
| `contacts.getByUserId` | `/api/contacts/search` | GET |

---

## Key Architecture Concepts

### Full Request Flow

```
Browser
  └─► Spring DispatcherServlet
        ├─► CspNonceFilter          (generates CSP nonce, sets response header)
        ├─► UserInterceptor          (validates JWT via /api/users/me, sets userId attr)
        └─► Controller
              └─► ServiceImpl
                    └─► AuthenticatedApiService
                          ├─► ApiDispatcherService (JAR) ──► Backend API Server
                          └─► [on 401] RefreshTokenService ──► POST /auth/refresh
                                └─► Retry original request once
```

### Layout / View Pattern

All controllers return `"index"` (maps to `index.jsp`) and set a `"view"` model attribute.
`index.jsp` uses `<jsp:include>` to dynamically pull in the correct page from `pages/`:

```
Controller sets: model.addAttribute("view", "chat-home")
index.jsp includes: pages/chat-home.jsp
```

### Session & Token Lifecycle

1. Login → backend returns `accessToken` + `refreshToken` → `CookieService` stores both as HTTP cookies.
2. Every protected request → `UserInterceptor` calls `getUserMe()` → `AuthenticatedApiService` attaches JWT from cookie header.
3. If backend returns 401 → `RefreshTokenService` posts refresh token → gets new JWT → cookie updated → original request retried.
4. If refresh also fails → `SessionExpiredException` → `GlobalExceptionHandler` → redirect to `/login`.

### Content Security Policy

`CspNonceFilter` generates a new nonce per request. JSP `<script>` tags must use:
```jsp
<script nonce="${cspNonce}">...</script>
```
The CSP header allows: `self`, nonce-based inline scripts, FontAwesome CDN fonts, WebSocket connections to `ws://localhost`.

---

## Dependencies Summary

| Dependency | Version | Purpose |
|---|---|---|
| `spring-boot-starter-web` | 3.5.4 | MVC, REST controllers, embedded Tomcat |
| `spring-boot-starter-websocket` | 3.5.4 | WebSocket/STOMP support |
| `spring-boot-starter-validation` | 3.1.5 | Bean validation (`@Valid`, `@NotBlank`, etc.) |
| `tomcat-embed-jasper` | managed | JSP rendering engine |
| `javax.servlet-api` | 3.1.0 | Servlet API (provided) |
| `jsp-api` | 2.1 | JSP API (provided) |
| `jakarta.servlet.jsp.jstl-api` | 3.0.0 | JSTL tag library API |
| `jakarta.servlet.jsp.jstl` (GlassFish) | 3.0.1 | JSTL implementation |
| `spring-boot-starter-tomcat` | managed | Embedded Tomcat (provided scope for WAR) |
| `api-dispatcher-service` (local JAR) | 0.0.1-SNAPSHOT | Custom HTTP client for backend API calls |
| `spring-boot-starter-test` | 3.5.4 | JUnit 5, Mockito, Spring test support |

---

## Build & Run

```bash
# Clean build and package WAR
./mvnw clean package

# Run with embedded Tomcat
./mvnw spring-boot:run

# Application available at:
http://localhost:8081/chat

# Logs written to:
logs/app.log
```

> **Note:** The backend API server (`api-dispatcher-service` / Synk) must be running at `http://localhost/synk` for the app to function. Configure the base URL in `ApplicationConfig.java` → `apiDispatcherService()` bean.