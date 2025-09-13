class UserPresencePoller {
    constructor(userIds, updateCallback) {
        this.userIds = userIds;
        this.updateCallback = updateCallback;
        this.interval = null;
    }

    start() {
        this.interval = setInterval(() => this.fetchUserPresence(), 5000); // poll every 5 seconds
        this.fetchUserPresence(); // run immediately once
    }

    stop() {
        if (this.interval) clearInterval(this.interval);
    }

    fetchUserPresence() {
        ajaxRequest(
            `${window.location.origin}/chat/api/user/lastActiveStatus?userId=${this.userIds.join(",")}`,
            "GET",
            null,
            (response) => {
                // success callback
                if (this.updateCallback) {
                    this.updateCallback(response); // update UI with server response
                }
            },
            () => {
                // error callback
                console.error("Failed to fetch user status. Please try again.");
            }
        );
    }

    setUpdateCallback(updateCallback) {
        this.updateCallback = updateCallback;
    }

}
