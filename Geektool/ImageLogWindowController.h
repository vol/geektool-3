/* ImageLogWindowController */

#import <Cocoa/Cocoa.h>
#import "ImageLogWindow.h"

@interface ImageLogWindowController : NSWindowController
{
    IBOutlet id picture;
    IBOutlet id logView;
    IBOutlet id textField;
}
- (void)setImage:(NSImage*)anImage;
- (void)setHighlighted:(BOOL)flag;
- (void)setStyle:(int)style;
- (void)display;
-(void)setFit:(int)fit;
-(void)setCrop:(BOOL)crop;
-(void)setPictureAlignment:(int)alignment;
- (void)setText:(NSString*)newText;
- (void)setFont:(NSFont*)font;
- (void)setShadowText:(bool)shadow;
- (void)setTextColor:(NSColor*)color;
- (void)setTextRect:(NSRect)rect;
@end
