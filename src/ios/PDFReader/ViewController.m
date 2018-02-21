//
//  ViewController.m
//  PDFReader
//
//  Created by Smart Pro on 2/20/18.
//  Copyright © 2018 Smart Pro. All rights reserved.
//

#import "ViewController.h"
#import "PDFKit/LazyPDFKit.h"

@interface ViewController () <LazyPDFViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = infoDictionary[@"CFBundleName"];
    NSString *version = infoDictionary[@"CFBundleVersion"];
    
    self.title = [NSString stringWithFormat:@"%@ v%@", name, version];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapToPresent:(id)sender {
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
    
    LazyPDFDocument *document = [LazyPDFDocument withDocumentFilePath:filePath password:phrase];

    if (document != nil) // Must have a valid LazyPDFDocument object in order to proceed with things
    {
        LazyPDFViewController *lazyPDFViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument:document];
        
        lazyPDFViewController.delegate = self; // Set the LazyPDFViewController delegate to self

#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        [self.navigationController pushViewController:lazyPDFViewController animated:YES];
        
#else // present in a modal view controller
        
        lazyPDFViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        lazyPDFViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:lazyPDFViewController animated:YES completion:NULL];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    // dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
