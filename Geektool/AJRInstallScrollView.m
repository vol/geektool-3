#import "AJRInstallScrollView.h"

#import "AJRScrollView.h"
#import "LogTextField.h"
@implementation AJRInstallScrollView


// This is necessary
- (BOOL)isOpaque
{
    return NO;
}

// This isn't really necessary
- (void)drawRect:(NSRect)rect
{
    if (tableBorder) {
        NSRect    bounds = [self bounds];

        [[NSColor colorWithCalibratedWhite:1.00 alpha:0.2] set];
        NSRectFillUsingOperation(bounds, NSCompositeSourceOver);

        [[NSColor colorWithCalibratedWhite:0.68 alpha:1.0] set];
        NSFrameRect(bounds);
    } else if ([self borderType] == NSLineBorder) {
        NSRect    bounds = [self bounds];

        [[NSColor colorWithCalibratedWhite:0.68 alpha:1.0] set];
        NSFrameRect(bounds);
    }
}

// This first line is necessary, the remainder isn't...
- (void)awakeFromNib
{
    [[self contentView] setCopiesOnScroll:NO];
    if ([[self documentView] isKindOfClass:[LogTextField class]]) {
        [[self documentView] setDrawsBackground:NO];
    }
}

@end