#import <Cocoa/Cocoa.h>

@interface AJRInstallScrollView : NSScrollView
{
    BOOL         tableBorder:1;
}

- (BOOL)isOpaque;

@end