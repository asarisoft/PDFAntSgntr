var exec = require('cordova/exec');

console.log('-------- INIT -----------');
window.addEventListener('orientationchange', onOrientationChange);

var viewerElement;
var isCurrentlyViewing = false;

function onOrientationChange(e) {
    console.log('Orientation changed');
    console.log(e);
    console.log(window.orientation);
    var rect = viewerElement.getBoundingClientRect();
    console.log(rect);

    success = function() {
        console.log('onOrientationChange success');
    };
    error = function() {
        console.log('onOrientationChange error');
    };

    exec(success, error, "CordovaPdfViewer", "redim", [rect.top, rect.left, rect.width, rect.height]);
}


exports.show = function(viewerId, src, success, error) {
    var extension = src.split('.').pop();

    console.log('Source ' + src);
    console.log('extension ' + extension);

    if (extension != 'pdf') {
        msg = 'File extension must be pdf';
        console.log(msg);
        error(msg);
        return;
    }

    var elem = document.getElementById(viewerId);
    if (!elem) {
        msg = 'Unable to find element with id ' + viewerId;
        console.log(msg);
        error(msg);
        return;
    }

    var filename = src.replace( /.*\//, "" );
    var directory = src.slice(src, -1 * filename.length - 1); // -1 for the /
    filename = filename.slice(0, -4);

    console.log('dir=' + directory + '  filename=' + filename);

    var rect = elem.getBoundingClientRect();
    console.log(rect);

    isCurrentlyViewing = true;
    viewerElement = elem;

    exec(success, error, "CordovaPdfViewer", "show", [filename, directory, rect.top, rect.left, rect.width, rect.height]);
};

exports.redim = function(success, error, top, left, width, height) {
    exec(success, error, "CordovaPdfViewer", "redim", [top, left, width, height]);
};


exports.show2 = function(viewerId, src, success, error) {
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
