var exec = require('cordova/exec');

exports.show = function(viewerId, src, success, error) {
    var elem = document.getElementById(viewerId);
    if (!elem) {
        msg = 'Unable to find element with id ' + viewerId;
        console.log(msg);
        error(msg);
        return;
    }
    var iframe = document.createElement('iframe');
    elem.appendChild(iframe);
    iframe.src = src;
    success();
};
