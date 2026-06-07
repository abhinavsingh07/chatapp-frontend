/**
 * Centralized AJAX function for any endpoint/method
 * @param {string} url - Endpoint URL
 * @param {string} method - HTTP method (GET, POST, PUT, DELETE)
 * @param {object|null} data - Request body (null for GET/DELETE)
 * @param {function} onSuccess - Callback on success (receives data)
 * @param {function} onError - Callback on error (receives error details)
 * @param {object} options - Optional settings, supports { isFormData: true }
 */
function ajaxRequest(url, method, data, onSuccess, onError, options) {
    var isFormData = options && options.isFormData === true;

    if (!isFormData) {
        isFormData = typeof FormData !== "undefined"
        && (data instanceof FormData || Object.prototype.toString.call(data) === "[object FormData]");
    }

    $.ajax({
        url: url,
        method: method,
        data: isFormData ? data : (data ? JSON.stringify(data) : null),
        contentType: isFormData ? false : "application/json; charset=utf-8",//contentType: false tells jQuery not to automatically add a Content-Type header to your HTTP request as it needs correct boundry for file uploads
        processData: !isFormData, //By default, jQuery tries to convert your data into a query string as process data:false says"Don't touch my FormData object. Send it as-is."
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
            //console.error("AJAX Error:", status, error, xhr.responseText);
            if (typeof onError === "function") {
                onError(xhr, status, error);
            }
        },
        complete: function () {
            $("#loader").hide(); // hide loader after request completes
        }
    });
}
