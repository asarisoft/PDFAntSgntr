var exec = require('cordova/exec');

console.log('-------- INIT -----------');
window.addEventListener('orientationchange', onOrientationChange);

var viewerElement;
var documentSrc;
var documentTitle;
var isCurrentlyViewing = false;

function onOrientationChange(e) {
    if (!isCurrentlyViewing) {
        return;
    }

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


exports.show = function(_viewerId, src, _title, success, error) {
    if (isCurrentlyViewing) {
        exec(function() {}, function() {}, "CordovaPdfViewer", "dismiss");
    }

    viewerId = _viewerId;
    documentSrc = src;
    documentTitle = _title + '.pdf';
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

    console.log('src=' + src);

    var rect = elem.getBoundingClientRect();
    console.log(rect);

    isCurrentlyViewing = true;
    viewerElement = elem;

    exec(success, error, "CordovaPdfViewer", "show", [src, documentTitle, rect.top, rect.left, rect.width, rect.height]);
};

exports.redim = function(success, error, top, left, width, height) {
    if (!isCurrentlyViewing) {
        return;
    }

    console.log('Redim new');
    console.log(viewerId);
    console.log('src=' + documentSrc);
    console.log('src=' + documentTitle);
    console.log('now showing again');
    pdfViewer.show(viewerId, documentSrc, documentTitle, success, error); 
    //exec(success, error, "CordovaPdfViewer", "redim", [top, left, width, height]);
};

exports.autoRedim = function() {
    console.log('autoRedim');
    var success = function() {};
    var error   = function() {};
    pdfViewer.redim(success, error, '', '', '', '');
};

exports.dismiss = function(resultPath, success, error) {
    console.log('Dismiss');
    isCurrentlyViewing = false;
    exec(success, error, "CordovaPdfViewer", "dismiss", [resultPath]);
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

exports.addImage = function(pdffile, resultfile, imagefile, page, viewwidth, viewheight, posx, posy, imgwidth, imgheight, success, error) {
    var extension = pdffile.split('.').pop();
    
    console.log('Source ' + pdffile);
    console.log('extension ' + extension);
    
    if (extension != 'pdf') {
        msg = 'File extension must be pdf';
        console.log(msg);
        error(msg);
        return;
    }

    exec(success, error, "CordovaPdfViewer", "addImage", [pdffile, resultfile, imagefile, page, viewwidth, viewheight, posx, posy, imgwidth, imgheight]);
};

