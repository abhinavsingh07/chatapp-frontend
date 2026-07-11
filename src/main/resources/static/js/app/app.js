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

//as using webpack and module bundlers, we can expose the ajaxRequest function globally so that jsp javascript can access it without importing it explicitly. This is useful for legacy code or when you want to use the function in inline scripts.
window.DateFormatter = DateFormatter;