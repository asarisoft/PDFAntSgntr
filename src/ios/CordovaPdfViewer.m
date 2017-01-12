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

@implementation CordovaPdfViewer

- (void)show:(CDVInvokedUrlCommand*)command
{
    NSString* filename = [command.arguments objectAtIndex:0];
    NSString* directory = [command.arguments objectAtIndex:1];
    int top = [[command.arguments objectAtIndex:2] intValue];
    int left = [[command.arguments objectAtIndex:3] intValue];
    int w = [[command.arguments objectAtIndex:4] intValue];
    int h = [[command.arguments objectAtIndex:5] intValue];

    NSLog(@"filename=%@ directory=%@ x=%d y=%d h=%d w=%d", filename, directory, left, top, w, h);

    NSLog(@"Trying to display using pdf reader");

    CGRect myBox = CGRectMake(left, top, w, h);

    NSBundle* main = [NSBundle mainBundle];
    NSString *localPath = [main pathForResource: filename ofType:@"pdf" inDirectory: directory];

    ReaderDocument *document = [ReaderDocument withDocumentFilePath:localPath password: nil];

    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    [self.viewController addChildViewController: readerViewController];


    //myBox.origin.y += self.viewController.topLayoutGuide.length;
    //myBox.size.height -= self.viewController.topLayoutGuide.length;

    readerViewController.view.frame = myBox;
    [self.webView addSubview:readerViewController.view];

    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
