#import "AJRInstallClipView.h"
#import "AJRScrollView.h"
@implementation AJRInstallClipView
+ (void)load
{
    [[self class] poseAsClass:[NSClipView class]];
}
- (BOOL)isOpaque
{
    // You might get a small speed boost if this returned YES if the
    // background color had no alpha component.
    return NO;
}

- (void)drawRect:(NSRect)rect
{
    // If you want a partial background color, not purely transparent,
    //then draw it here.
    
    NSRect    bounds = [self bounds];
    [[(AJRScrollView*)[ self superview ] backgroundColor ] set];
    NSRectFillUsingOperation(bounds, NSCompositeSourceOver);
}

@end