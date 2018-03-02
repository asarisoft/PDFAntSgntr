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
        
        self.document = [MyReaderDocument withDocumentFilePath:filename password: nil displayTitle: title];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.readerViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument: self.document];
            self.readerViewController.delegate = self;
            [self.viewController addChildViewController: self.readerViewController];
            
            self.readerViewController.view.frame = viewerBox;
            [self.webView addSubview: self.readerViewController.view];
        });
        
        CDVPluginResult* pluginResult = nil;
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
        
        NSError *error = nil;
        if (![self copyFrom:pdfFile to:resultFile error:&error]) {
            NSLog(@"Failed to copy: %@", [error description]);
        } else {
            MyReaderDocument *document = [MyReaderDocument withDocumentFilePath:resultFile password: nil displayTitle:@"Document title.pdf"];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFile];
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(viewWidth, viewHeight), NO, 0.f);
            [image drawInRect:CGRectMake(imageX, imageY, imageWidth, imageHeight)];
            UIImage * const scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSMutableDictionary *annotDict = [NSMutableDictionary dictionary];
            NSData *imageData = UIImagePNGRepresentation(scaledImage);
            [annotDict setValue:imageData forKey:@"image"];
            [annotDict setValue:[NSNumber numberWithInteger:pageNumber] forKey:@"page"];
            
            [annotDict setValue:[document fileDate] forKey:@"fileDate"];
            [annotDict setValue:[document fileSize] forKey:@"fileSize"];
            [annotDict setValue:[document pageCount] forKey:@"pageCount"];
            [annotDict setValue:[document filePath] forKey:@"filePath"];
            
            [[LazyPDFDataManager sharedInstance] addAnnotation:annotDict];
        }
        
        CDVPluginResult* pluginResult = nil;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    [self dismiss:nil];
}

- (BOOL)copyFrom:(NSString*)src to:(NSString*)dest error:(NSError* __autoreleasing*)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:src]) {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error != NULL) {
            (*error) = [NSError errorWithDomain:@"PDFViewer Plugin" code:200 userInfo:@{NSLocalizedDescriptionKey: errorString}];
        }
        return NO;
    }
    
    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    BOOL destExists = [fileManager fileExistsAtPath:dest];
    
    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error]) {
        return NO;
    }
    
    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error]) {
        return NO;
    }
    
    // create path to dest
    if (!destExists && ![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error]) {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    } else {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
}


@end
