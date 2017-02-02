/**
 *  MyReaderDocument
 *
 *  @author Raphael Alla for http://mplus.software
*/

#import "ReaderDocument.h"

#ifndef MyReaderDocument_h
#define MyReaderDocument_h

@interface MyReaderDocument : ReaderDocument

@property NSString *title;

+ (ReaderDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase displayTitle:(NSString *) title;

- (BOOL)canEmail;
- (BOOL)canExport;
- (BOOL)canPrint;
- (NSString *)fileName;


@end

#endif /* MyReaderDocument_h */

