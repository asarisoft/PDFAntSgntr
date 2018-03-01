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
#import "LazyPDFDataManager.h"

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
    self.readerViewController.delegate = self;
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

- (void)addImage:(CDVInvokedUrlCommand*)command
{
    NSString *pdfFile = [command argumentAtIndex:0];
    NSString *title = [command argumentAtIndex:1];
    NSString *imageFile = [command argumentAtIndex:2];
    int pageNumber = [[command argumentAtIndex:3] intValue];
    float viewX = [[command argumentAtIndex:4] floatValue];
    float viewY = [[command argumentAtIndex:5] floatValue];
    float viewWidth = [[command argumentAtIndex:6] floatValue];
    float viewHeight = [[command argumentAtIndex:7] floatValue];
    float imageX = [[command argumentAtIndex:8] floatValue];
    float imageY = [[command argumentAtIndex:9] floatValue];
    float imageWidth = [[command argumentAtIndex:10] floatValue];
    float imageHeight = [[command argumentAtIndex:11] floatValue];

    self.document = [MyReaderDocument withDocumentFilePath:pdfFile password: nil displayTitle: title];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFile];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(viewWidth, viewHeight), NO, 0.f);
    [image drawInRect:CGRectMake(imageX, imageY, imageWidth, imageHeight)];
    UIImage * const scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableDictionary *annotDict = [NSMutableDictionary dictionary];
    NSData *imageData = UIImagePNGRepresentation(scaledImage);
    [annotDict setValue:imageData forKey:@"image"];
    [annotDict setValue:[NSNumber numberWithInteger:pageNumber] forKey:@"page"];
    
    [annotDict setValue:[self.document fileDate] forKey:@"fileDate"];
    [annotDict setValue:[self.document fileSize] forKey:@"fileSize"];
    [annotDict setValue:[self.document pageCount] forKey:@"pageCount"];
    [annotDict setValue:[self.document filePath] forKey:@"filePath"];
    
    [[LazyPDFDataManager sharedInstance] addAnnotation:annotDict];
    
    CGRect viewerBox = CGRectMake(viewX, viewY, viewWidth, viewHeight);

    self.readerViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument: self.document];
    self.readerViewController.delegate = self;
    [self.viewController addChildViewController: self.readerViewController];
    
    self.readerViewController.view.frame = viewerBox;
    [self.webView addSubview: self.readerViewController.view];

    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    [self dismiss:nil];
}


@end
