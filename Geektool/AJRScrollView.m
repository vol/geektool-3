#import "AJRInstallScrollView.h"

#import "AJRScrollView.h"
#import "LogTextField.h"
@implementation AJRScrollView
// This is necessary
- (BOOL)isOpaque
{
    return NO;
}

// This isn't really necessary

- (void)drawRect:(NSRect)rect
{
    /*
    if ([self borderType] == NSLineBorder) {
        NSRect    bounds = [self bounds];

        [[NSColor colorWithCalibratedWhite:0.68 alpha:1.0] set];
        NSFrameRect(bounds);
    }
     */
}

// This first line is necessary, the remainder isn't...
- (void)awakeFromNib
{
    backgroundColor = [[ NSColor clearColor ] retain ];;
    //[ self setContentView: textView ];
    [ self setDocumentView: textView ];
    [[self contentView] setCopiesOnScroll:NO];
    if ([[self documentView] isKindOfClass:[LogTextField class]]) {
	[[self documentView] setBackgroundColor: backgroundColor ];
        [[self documentView] setDrawsBackground:NO];
    }
}
- (NSColor*)backgroundColor;
{
    return backgroundColor;
}
- (void)setBackgroundColor:(NSColor*)color;
{
    [ backgroundColor release ];
    backgroundColor = [ color retain ];
}
@end