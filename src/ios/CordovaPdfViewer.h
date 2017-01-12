/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */


#import <Cordova/CDV.h>
#import "ReaderViewController.h"

@interface CordovaPdfViewer : CDVPlugin

@property ReaderViewController *readerViewController;

- (void)show:(CDVInvokedUrlCommand*)command;

- (void)redim:(CDVInvokedUrlCommand*)command;


@end
