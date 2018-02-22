/**
 *  MyReaderDocument
 *
 *  @author Raphael Alla for http://mplus.software
*/

#import "LazyPDFDocument.h"

#ifndef MyReaderDocument_h
#define MyReaderDocument_h

@interface MyReaderDocument : LazyPDFDocument

@property NSString *title;

+ (LazyPDFDocument *)withDocumentFilePath:(NSString *)filePath password:(NSString *)phrase displayTitle:(NSString *) title;

- (BOOL)canEmail;
- (BOOL)canExport;
- (BOOL)canPrint;
- (NSString *)fileName;


@end

#endif /* MyReaderDocument_h */

