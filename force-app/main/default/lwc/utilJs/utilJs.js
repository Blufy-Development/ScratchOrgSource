// Return Query String Parameters in Object Form, User Can Easyly get Value By Passing Key.
const getURLParameters = () => {
    let params = {};
    let search = location.search.substring(1);
    if (search) {
        params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
            return key === "" ? value : decodeURIComponent(value)
        });
    }

    return params;
}
const isEmpty = (obj) => {
    for(var key in obj) {
        if(obj.hasOwnProperty(key))
            return false;
    }
    return true;
}
/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}
export function getCookieByName(name) {
    let cookieString = "; " + document.cookie;
    let parts = cookieString.split("; " + name + "=");
    if (parts.length === 2) {
        return parts.pop().split(";").shift();
    }
    return null;
}
export function setCookie(key, value) {
    let date = new Date();
    date.setTime(date.getTime() + (6000 * 1000));
    document.cookie = key + "=" + value + ";expires=" + date.toUTCString() + ";path=/";
}
export { getURLParameters, isEmpty };