/**
 *  MyReaderDocument
 *
 *  @author Raphael Alla for http://mplus.software
*/

#import <Foundation/Foundation.h>
#import "MyReaderDocument.h"



@implementation MyReaderDocument: ReaderDocument

+ (ReaderDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase displayTitle:(NSString *) title
{
    MyReaderDocument *document = nil; // ReaderDocument object

    document = (MyReaderDocument*) [MyReaderDocument unarchiveFromFileName:filePath password:phrase];

    if (document == nil) // Unarchive failed so create a new ReaderDocument object
    {
        document = [[MyReaderDocument alloc] initWithFilePath:filePath password:phrase];
    }

    document.title = title;

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
