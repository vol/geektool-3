#import "ImageLogWindow.h"
#import <Carbon/Carbon.h>
@implementation ImageLogWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
    self = [ super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:NO ];
    [ self setHasShadow: NO ];
    [ self setOpaque: NO ];
    //[ self setBackgroundColor: [ NSColor clearColor ]];
    [ self setReleasedWhenClosed:YES ];
    //[ self setIgnoresMouseEvents: YES ];
    //[ self setClickThrough: YES ];
    return self;
}
-(BOOL)acceptsFirstResponder
{
    return NO;
}
- (void)setHighlighted:(BOOL)flag;
{
    if (flag)
        [ self setClickThrough: NO ];
    else
        [ self setClickThrough: YES ];

    [ logView setHighlighted: flag ];
}
- (void)setClickThrough:(BOOL)clickThrough
{
    /* carbon */
    void *ref = [ self windowRef];
    if (clickThrough)
        ChangeWindowAttributes(ref, kWindowIgnoreClicksAttribute,kWindowNoAttributes);
    else
        ChangeWindowAttributes(ref, kWindowNoAttributes, kWindowIgnoreClicksAttribute);
    /* cocoa */
    [ self setIgnoresMouseEvents:clickThrough];
}
@end
