/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */

#import "CordovaPdfViewer.h"
#import <Cordova/CDV.h>
#import "ReaderViewController.h"
#import "MyReaderDocument.h"

@implementation CordovaPdfViewer

- (void)show:(CDVInvokedUrlCommand*)command
{
    NSString* filename = [command.arguments objectAtIndex:0];
    NSString* directory = [command.arguments objectAtIndex:1];
    int top = [[command.arguments objectAtIndex:2] intValue];
    int left = [[command.arguments objectAtIndex:3] intValue];
    int w = [[command.arguments objectAtIndex:4] intValue];
    int h = [[command.arguments objectAtIndex:5] intValue];

    NSLog(@"filename=%@ directory=%@ top=%d left=%d h=%d w=%d", filename, directory, left, top, w, h);

    CGRect viewerBox = CGRectMake(left, top, w, h);

//    NSBundle* main = [NSBundle mainBundle];
//    NSString *localPath = [main pathForResource: filename ofType:@"pdf" inDirectory: directory];

    MyReaderDocument *document = [MyReaderDocument withDocumentFilePath:filename password: nil displayTitle: @"TITRE"];

    self.readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    [self.viewController addChildViewController: self.readerViewController];

    self.readerViewController.view.frame = viewerBox;
    [self.webView addSubview: self.readerViewController.view];

    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)redim:(CDVInvokedUrlCommand*)command
{
    NSLog(@"redim");
    int top = [[command.arguments objectAtIndex:0] intValue];
    int left = [[command.arguments objectAtIndex:1] intValue];
    int w = [[command.arguments objectAtIndex:2] intValue];
    int h = [[command.arguments objectAtIndex:3] intValue];

    NSLog(@"redim top=%d left=%d h=%d w=%d", left, top, w, h);

    CGRect viewerBox = CGRectMake(left, top, w, h);
    self.readerViewController.view.frame = viewerBox;

    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dismiss:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Dismiss now from code");
    [self.readerViewController.view removeFromSuperview];
    [self.readerViewController removeFromParentViewController];
    self.readerViewController = nil;
    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
