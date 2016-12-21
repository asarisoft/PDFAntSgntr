var exec = require('cordova/exec');

exports.show = function(viewerId, src, success, error) {
    var elem = document.getElementById(viewerId);
    if (!elem) {
        msg = 'Unable to find element with id ' + viewerId;
        console.log(msg);
        error(msg);
        return;
    }
    elem.style.setProperty('overflow', 'auto');
    elem.style.setProperty('-webkit-overflow-scrolling', 'touch');

    var innerHTML = '<object style="width: 100%; height: 100%" data="' + src + '"></object>';
    elem.innerHTML = innerHTML;
    success();
};
