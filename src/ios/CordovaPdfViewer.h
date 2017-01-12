/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */


#import <Cordova/CDV.h>

@interface CordovaPdfViewer : CDVPlugin

- (void)show:(CDVInvokedUrlCommand*)command;

@end
