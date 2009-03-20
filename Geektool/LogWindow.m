#import "LogWindow.h"
#import <Carbon/Carbon.h>

@implementation LogWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:NO];
    [self setHasShadow: NO];
    [self setOpaque: NO];
    [text setEnabled: NO];
    [self setReleasedWhenClosed:YES];
    return self;
}

- (void)display
{
    [super display];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)setHighlighted:(BOOL)flag;
{
    if (flag)
        [self setClickThrough: NO];
    else
        [self setClickThrough: YES];
    
    [logView setHighlighted: flag];
}

- (void)setClickThrough:(BOOL)clickThrough
{
    /* carbon */
    void *ref = [self windowRef];
    if (clickThrough)
        ChangeWindowAttributes(ref, kWindowIgnoreClicksAttribute,kWindowNoAttributes);
    else
        ChangeWindowAttributes(ref, kWindowNoAttributes, kWindowIgnoreClicksAttribute);
    /* cocoa */
    [self setIgnoresMouseEvents:clickThrough];
}
@end
