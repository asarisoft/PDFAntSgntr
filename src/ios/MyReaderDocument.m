/**
 *  MyReaderDocument
 *
 *  @author Raphael Alla for http://mplus.software
*/

#import <Foundation/Foundation.h>
#import "MyReaderDocument.h"



@implementation MyReaderDocument: LazyPDFDocument

+ (MyReaderDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase displayTitle:(NSString *) title
{
    MyReaderDocument *document = [[MyReaderDocument alloc] initWithFilePath:filePath password:phrase];
    document.title = title;
    
    // Get userdefaults storage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *indexArray = [defaults objectForKey: document.fileName];

    
    for (NSNumber *index in indexArray) {
        [document.bookmarks addIndex:[index intValue]];
    }
    
    return document;
};


- (BOOL)canEmail
{
return NO;
}

- (BOOL)canExport
{
return NO;
}

- (BOOL)canPrint
{
return NO;
}

- (NSString *)fileName
{
    return self.title;
}

@end
