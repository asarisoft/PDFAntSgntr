/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */

#import "CordovaPdfViewer.h"
#import <Cordova/CDV.h>
#import "LazyPDFViewController.h"
#import "MyReaderDocument.h"

@interface CordovaPdfViewer() <LazyPDFViewControllerDelegate>

@end

@implementation CordovaPdfViewer

- (void)show:(CDVInvokedUrlCommand*)command
{
    NSString* filename = [command.arguments objectAtIndex:0];
    NSString* title = [command.arguments objectAtIndex:1];
    int top = [[command.arguments objectAtIndex:2] intValue];
    int left = [[command.arguments objectAtIndex:3] intValue];
    int w = [[command.arguments objectAtIndex:4] intValue];
    int h = [[command.arguments objectAtIndex:5] intValue];

    NSLog(@"filename=%@ title=%@ top=%d left=%d h=%d w=%d", filename, title, left, top, w, h);

    CGRect viewerBox = CGRectMake(left, top, w, h);

//    NSBundle* main = [NSBundle mainBundle];
//    NSString *localPath = [main pathForResource: filename ofType:@"pdf" inDirectory: directory];

    self.document = [MyReaderDocument withDocumentFilePath:filename password: nil displayTitle: title];

    self.readerViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument: self.document];
    self.readerViewController.delegate = self;
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

    [self.readerViewController.view removeFromSuperview];
    [self.readerViewController removeFromParentViewController];
    self.readerViewController = nil;

    CGRect viewerBox = CGRectMake(left, top, w, h);
    self.readerViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument: self.document];
    [self.viewController addChildViewController: self.readerViewController];

    self.readerViewController.view.frame = viewerBox;
    [self.webView addSubview: self.readerViewController.view];

    /* This code does not work:

    CGRect viewerBox = CGRectMake(left, top, w, h);
    self.readerViewController.view.frame = viewerBox;
    */

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

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    [self dismiss:nil];
}


@end
