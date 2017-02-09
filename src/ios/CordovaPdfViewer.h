/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */


#import <Cordova/CDV.h>
#import "ReaderViewController.h"
#import "MyReaderDocument.h"

@interface CordovaPdfViewer : CDVPlugin

@property ReaderViewController *readerViewController;
@property MyReaderDocument *document;

- (void)show:(CDVInvokedUrlCommand*)command;

- (void)redim:(CDVInvokedUrlCommand*)command;


@end
