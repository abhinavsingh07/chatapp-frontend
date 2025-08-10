/**
 * Centralized AJAX function for any endpoint/method
 * @param {string} url - Endpoint URL
 * @param {string} method - HTTP method (GET, POST, PUT, DELETE)
 * @param {object|null} data - Request body (null for GET/DELETE)
 * @param {function} onSuccess - Callback on success (receives data)
 * @param {function} onError - Callback on error (receives error details)
 */
function ajaxRequest(url, method, data, onSuccess, onError) {
    $.ajax({
        url: url,
        method: method,
        data: data ? JSON.stringify(data) : null,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        beforeSend: function () {
            $("#loader").show(); // optional loader
        },
        success: function (response) {
            if (typeof onSuccess === "function") {
                onSuccess(response);
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX Error:", status, error, xhr.responseText);
            if (typeof onError === "function") {
                onError(xhr, status, error);
            }
        },
        complete: function () {
            $("#loader").hide(); // hide loader after request completes
        }
    });
}
