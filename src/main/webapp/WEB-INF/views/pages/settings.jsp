<%@ include file="/WEB-INF/views/common.jsp" %>
<div class="st-page-wrap">
    <div class="card border-0 shadow-sm st-main-card">

        <%-- Header --%>
        <div class="st-card-header">
            <div class="st-header-icon">
                <i class="fas fa-cog"></i>
            </div>
            <div>
                <h5 class="mb-0 fw-semibold text-white" style="font-size:0.95rem;">Settings</h5>
                <small class="text-white-50" style="font-size:0.75rem;">Manage your app preferences</small>
            </div>
            <a href="${pageContext.request.contextPath}/home" class="st-back-btn">
                <i class="fas fa-arrow-left me-1"></i>Back
            </a>
        </div>

        <%-- ── Notifications section ── --%>
        <div class="st-section">
            <div class="st-section-title">
                <span class="st-section-icon"><i class="fas fa-bell"></i></span>
                Notifications
            </div>

            <%-- Enable desktop notifications --%>
            <div class="st-item">
                <div class="st-item-info">
                    <div class="st-item-label">Desktop Notifications</div>
                    <div class="st-item-desc">Receive alerts for new messages even when the app is in the background</div>
                </div>
                <div class="st-item-action">
                    <button id="enableNotificationBtn" class="btn btn-primary btn-sm px-3 py-2">
                        <i class="fas fa-bell me-1"></i>Enable
                    </button>
                </div>
            </div>

            <%-- Notification status display. Protected: id="notificationStatus" --%>
            <div id="notificationStatus"></div>

            <%-- Message preview toggle. Protected: id="messagePreviewToggle" + id="showFullMsgInBodyValue" --%>
            <div class="st-item">
                <div class="st-item-info">
                    <div class="st-item-label">Message Preview in Notifications</div>
                    <div class="st-item-desc">Show full message text in notification popups</div>
                </div>
                <div class="st-item-action">
                    <div class="form-check form-switch mb-0">
                        <input class="form-check-input" type="checkbox" role="switch" id="messagePreviewToggle">
                        <label class="form-check-label" for="messagePreviewToggle"></label>
                    </div>
                </div>
            </div>
            <input type="hidden" id="showFullMsgInBodyValue" value="false">
        </div>

        <div class="st-divider"></div>

        <%-- ── Appearance section ── --%>
        <div class="st-section">
            <div class="st-section-title">
                <span class="st-section-icon st-section-icon--purple"><i class="fas fa-palette"></i></span>
                Appearance
            </div>

            <%-- Dark mode toggle. Protected: id="darkModeToggle" --%>
            <div class="st-item">
                <div class="st-item-info">
                    <div class="st-item-label">Dark Mode</div>
                    <div class="st-item-desc">Switch to a deep dark theme — easier on the eyes during long sessions</div>
                </div>
                <div class="st-item-action">
                    <div class="form-check form-switch mb-0">
                        <input class="form-check-input" type="checkbox" role="switch" id="darkModeToggle">
                        <label class="form-check-label" for="darkModeToggle"></label>
                    </div>
                </div>
            </div>
        </div>

    </div><%-- /.st-main-card --%>
</div><%-- /.st-page-wrap --%>

<script nonce="${cspNonce}">
    document.addEventListener('DOMContentLoaded', function () {
        const button = document.getElementById('enableNotificationBtn');
        const statusDiv = document.getElementById('notificationStatus');
        const messagePreviewToggle = document.getElementById('messagePreviewToggle');
        const showFullMsgInBodyValue = document.getElementById('showFullMsgInBodyValue');
        const darkModeToggle = document.getElementById('darkModeToggle');

        // ── Dark mode ──────────────────────────────────────────
        // Sync toggle to current state (theme-dark may already be on body via header init)
        darkModeToggle.checked = document.body.classList.contains('theme-dark');

        darkModeToggle.addEventListener('change', function () {
            if (this.checked) {
                document.body.classList.add('theme-dark');
                localStorage.setItem('cs-theme', 'dark');
            } else {
                document.body.classList.remove('theme-dark');
                localStorage.setItem('cs-theme', 'light');
            }
        });

        // ── Message preview ────────────────────────────────────
        const savedPreference = localStorage.getItem('showFullMsgInBody');
        if (savedPreference !== null) {
            const isEnabled = savedPreference === 'true';
            messagePreviewToggle.checked = isEnabled;
            showFullMsgInBodyValue.value = isEnabled.toString();
        }

        messagePreviewToggle.addEventListener('change', function () {
            const isChecked = this.checked;
            showFullMsgInBodyValue.value = isChecked.toString();
            localStorage.setItem('showFullMsgInBody', isChecked.toString());
        });

        // ── Desktop notifications ──────────────────────────────
        checkNotificationStatus();

        button.addEventListener('click', async () => {
            if (!("Notification" in window)) {
                alert("This browser does not support desktop notifications.");
                return;
            }

            const permission = await Notification.requestPermission();

            if (permission === "granted") {
                button.style.display = 'none';
                showNotificationStatus('granted');
                new Notification("Notifications Enabled!", {
                    body: "You will now receive desktop notifications for new messages.",
                    icon: "${pageContext.request.contextPath}/assets/images/logo.png"
                });
            } else if (permission === "denied") {
                showNotificationStatus('denied');
            }
        });

        function checkNotificationStatus() {
            if (!("Notification" in window)) {
                statusDiv.innerHTML = '<div class="st-notify-status st-notify-status--denied">Your browser does not support desktop notifications.</div>';
                button.disabled = true;
                return;
            }
            const permission = Notification.permission;
            if (permission === "granted") {
                showNotificationStatus('granted');
                button.style.display = 'none';
            } else if (permission === "denied") {
                showNotificationStatus('denied');
                button.disabled = true;
            }
        }

        function showNotificationStatus(status) {
            if (status === 'granted') {
                statusDiv.innerHTML = '<div class="st-notify-status st-notify-status--granted"><i class="fas fa-check-circle me-2"></i>Notifications are enabled!</div>';
            } else if (status === 'denied') {
                statusDiv.innerHTML = '<div class="st-notify-status st-notify-status--denied"><i class="fas fa-times-circle me-2"></i>Notifications are disabled. Please enable them in your browser settings.</div>';
            } else {
                statusDiv.innerHTML = '';
            }
        }
    });
</script>