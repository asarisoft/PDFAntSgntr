/**
 *  CordovaPdfViewer.h
 *  @author Raphael Alla raphael.alla@mplus.software
 *  @url    http://mplus.software
 *
 *  MIT Licence
 */

#import "CordovaPdfViewer.h"
#import <Cordova/CDV.h>

@implementation CordovaPdfViewer

- (void)show:(CDVInvokedUrlCommand*)command
{
    NSString* src = [command.arguments objectAtIndex:0];
    int x = [[command.arguments objectAtIndex:1] intValue];
    int y = [[command.arguments objectAtIndex:2] intValue];
    int w = [[command.arguments objectAtIndex:3] intValue];
    int h = [[command.arguments objectAtIndex:4] intValue];

    NSLog(@"src=%@ x=%d y=%d h=%d w=%d", src, x, y, w, h);

    NSLog(@"Trying to display using pdf reader");

    CGRect myBox = CGRectMake(300, 150, 724, 618);

    NSBundle* main = [NSBundle mainBundle];
    NSString *localPath = [main pathForResource:@"exemple" ofType:@"pdf" inDirectory:@"www"];

    /*
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:localPath password: nil];
    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    [self.viewController addChildViewController: readerViewController];


    myBox.origin.y += self.viewController.topLayoutGuide.length;
    myBox.size.height -= self.viewController.topLayoutGuide.length;

    readerViewController.view.frame = myBox;
    [self.webView addSubview:readerViewController.view];
    */

    CDVPluginResult* pluginResult = nil;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
