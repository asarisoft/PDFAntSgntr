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
    [self.commandDelegate runInBackground:^{
        NSString* filename = [command.arguments objectAtIndex:0];
        NSString* title = [command.arguments objectAtIndex:1];
        int top = [[command.arguments objectAtIndex:2] intValue];
        int left = [[command.arguments objectAtIndex:3] intValue];
        int w = [[command.arguments objectAtIndex:4] intValue];
        int h = [[command.arguments objectAtIndex:5] intValue];
        
        NSLog(@"filename=%@ title=%@ top=%d left=%d h=%d w=%d", filename, title, left, top, w, h);
        
        CGRect viewerBox = CGRectMake(left, top, w, h);
        
        // NSBundle* main = [NSBundle mainBundle];
        // NSString *localPath = [main pathForResource: filename ofType:@"pdf" inDirectory: directory];
        
        CDVPluginResult *pluginResult = nil;

        self.document = [MyReaderDocument withDocumentFilePath:filename password: nil displayTitle: title];
        if (self.document != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.readerViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument: self.document];
                self.readerViewController.delegate = self;
                [self.viewController addChildViewController: self.readerViewController];
                
                self.readerViewController.view.frame = viewerBox;
                [self.webView addSubview: self.readerViewController.view];
            });
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"It's fail to open the pdf file."];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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
    
    CDVPluginResult *pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dismiss:(CDVInvokedUrlCommand*)command
{
    NSString *resultFile = [command argumentAtIndex:0];
    
    NSLog(@"Dismiss now from code");
    
    if (self.readerViewController != nil) {
        [self.readerViewController finalizeDrwaing];
        
        [self.readerViewController.view removeFromSuperview];
        [self.readerViewController removeFromParentViewController];
        self.readerViewController = nil;
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = nil;
        if (self.document) {
            [self.document savePDFTo:resultFile];
            self.document = nil;
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There is no the opened document."];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)addImage:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        int iArg = 0;
        NSString *pdfFile = [command argumentAtIndex:iArg++];
        NSString *resultFile = [command argumentAtIndex:iArg++];
        NSString *imageFile = [command argumentAtIndex:iArg++];
        int pageNumber = [[command argumentAtIndex:iArg++] intValue];
        float viewWidth = [[command argumentAtIndex:iArg++] floatValue];
        float viewHeight = [[command argumentAtIndex:iArg++] floatValue];
        float imageX = [[command argumentAtIndex:iArg++] floatValue];
        float imageY = [[command argumentAtIndex:iArg++] floatValue];
        float imageWidth = [[command argumentAtIndex:iArg++] floatValue];
        float imageHeight = [[command argumentAtIndex:iArg++] floatValue];
        
        CDVPluginResult *pluginResult = nil;

        MyReaderDocument *document = [MyReaderDocument withDocumentFilePath:pdfFile password: nil displayTitle:@"Document title.pdf"];
        if (document != nil) {
            int pageCount = [document.pageCount intValue];
            if (pageNumber > pageCount || pageNumber < -pageCount || pageNumber == 0) {
                pageNumber = -1;
            } else if (pageNumber < 0) {
                pageNumber = pageNumber + pageCount + 1;
            }
            
            if (pageNumber > 0) {
                NSMutableDictionary *annotDict = [NSMutableDictionary dictionary];
                [annotDict setValue:[NSNumber numberWithInteger:pageNumber] forKey:@"page"];
                [annotDict setValue:[document fileDate] forKey:@"fileDate"];
                [annotDict setValue:[document fileSize] forKey:@"fileSize"];
                [annotDict setValue:[document pageCount] forKey:@"pageCount"];
                [annotDict setValue:[document filePath] forKey:@"filePath"];
                
                [[LazyPDFDataManager sharedInstance] addImage:imageFile in:CGSizeMake(viewWidth, viewHeight) rect:CGRectMake(imageX, imageY, imageWidth, imageHeight) params:annotDict];
                [document savePDFTo:resultFile];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The page number is invalidate."];
            }
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"It's fail to open the pdf file."];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    [self dismiss:nil];
}


@end
