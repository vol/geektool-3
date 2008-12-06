/* ImageLogWindow */

#import <Cocoa/Cocoa.h>

@interface ImageLogWindow : NSWindow
{
    IBOutlet id image;
    IBOutlet id logView;
}
- (void)setHilighted:(BOOL)flag;
- (void)setClickThrough:(BOOL)clickThrough;
@end
