function DateFormatter() { }

DateFormatter.prototype.formatUTCToLocalTimeZone = function (dateString) {
    const options = {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: true
    };
    return new Date(dateString).toLocaleString(undefined, options);
}