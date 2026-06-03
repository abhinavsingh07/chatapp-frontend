<div class="container">
    <div class="back-link">
        <a href="${pageContext.request.contextPath}/home">
            <i class="fas fa-arrow-left"></i> Back to Home
        </a>
    </div>

    <div class="settings-container">
        <div class="settings-header">
            <h1><i class="fas fa-cog"></i> Settings</h1>
            <p>Manage your application preferences and notifications</p>
        </div>

        <!-- Notifications Section -->
        <div class="settings-section">
            <h2><i class="fas fa-bell me-2"></i>Notifications</h2>

            <div class="settings-item">
                <div class="settings-item-info">
                    <h3>Desktop Notifications</h3>
                    <p>Receive notifications for new messages even when the app is in background</p>
                </div>
                <div class="settings-item-action">
                    <button id="enableNotificationBtn" class="btn btn-primary">
                        <i class="fas fa-bell me-2"></i>Enable
                    </button>
                </div>
            </div>

            <!-- Notification Status Display -->
            <div id="notificationStatus"></div>
        </div>

        <!-- Other Settings Sections (for future use) -->
        <!-- <div class="settings-section">
            <h2><i class="fas fa-shield-alt me-2"></i>Privacy</h2>
            <div class="settings-item">
                <div class="settings-item-info">
                    <h3>Show Online Status</h3>
                    <p>Let others see when you're online</p>
                </div>
                <div class="settings-item-action">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="onlineStatusToggle" checked>
                    </div>
                </div>
            </div>
        </div> -->

        <!-- <div class="settings-section">
            <h2><i class="fas fa-palette me-2"></i>Theme</h2>
            <div class="settings-item">
                <div class="settings-item-info">
                    <h3>Dark Mode</h3>
                    <p>Use dark theme for reduced eye strain</p>
                </div>
                <div class="settings-item-action">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="darkModeToggle">
                    </div>
                </div>
            </div>
        </div> -->
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const button = document.getElementById('enableNotificationBtn');
        const statusDiv = document.getElementById('notificationStatus');

        // Check current notification permission status on page load
        checkNotificationStatus();

        // Add click event listener to the button
        button.addEventListener('click', async () => {
            // Check if the browser supports notifications
            if (!("Notification" in window)) {
                alert("This browser does not support desktop notifications.");
                return;
            }

            // Request permission
            const permission = await Notification.requestPermission();

            if (permission === "granted") {
                console.log("Permission granted!");
                button.style.display = 'none'; // Hide button if granted
                showNotificationStatus('granted');

                // Show a test notification
                const notification = new Notification("Notifications Enabled!", {
                    body: "You will now receive desktop notifications for new messages.",
                    icon: "${pageContext.request.contextPath}/assets/images/logo.png"
                });
            } else if (permission === "denied") {
                console.warn("Permission denied.");
                showNotificationStatus('denied');
            }
        });

        function checkNotificationStatus() {
            if (!("Notification" in window)) {
                statusDiv.innerHTML = '<div class="notification-status denied">Your browser does not support desktop notifications.</div>';
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
                statusDiv.innerHTML = '<div class="notification-status granted"><i class="fas fa-check-circle me-2"></i>Notifications are enabled!</div>';
            } else if (status === 'denied') {
                statusDiv.innerHTML = '<div class="notification-status denied"><i class="fas fa-times-circle me-2"></i>Notifications are disabled. Please enable them in your browser settings.</div>';
            } else {
                statusDiv.innerHTML = '';
            }
        }
    });
</script>