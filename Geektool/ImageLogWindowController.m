#import "ImageLogWindowController.h"

@implementation ImageLogWindowController
- (void)setImage:(NSImage*)anImage
{
    [ picture setImage: anImage ];
}
- (void)setHilighted:(BOOL)flag;
{
    [(ImageLogWindow*)[ self window ] setHilighted: flag ];
    [ self display ];
}
- (void)setStyle:(int)style
{
    [ picture setImageFrameStyle: style ];
}
-(void)setFit:(int)fit;
{
        [ picture setImageScaling: fit ];
}
-(void)setCrop:(BOOL)crop;
{
    [ logView setCrop: crop ];
}
-(void)setPictureAlignment:(int)alignment
{
    [ picture setImageAlignment: alignment ];
}
- (void)display
{
    [[ self window ] display ];
}
- (void)setText:(NSString*)newText;
{
    [ textField setStringValue: newText ];
}
- (void)setFont:(NSFont*)font
{
    [ textField setFont: font ];
}
- (void)setShadowText:(bool)shadow
{
    [ textField setShadowText: shadow ];
}
- (void)setTextColor:(NSColor*)color
{
    [ textField setTextColor: color ];
}
- (void)setTextRect:(NSRect)rect
{
    [ textField setFrame: rect ];
    [ textField display ];
}
@end
