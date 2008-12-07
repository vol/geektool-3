#import "GeekToolMenuView.h"


@implementation GeekToolMenuView


- initWithFrame:(NSRect)r menuExtra:m
{
    // Description forthcoming :-P
    self = [super initWithFrame:r];

    if( !self )
        return nil;

    menuExtra = m;

    return self;
}

// This is called by SystemUIServer when it wants to draw the menu extra view
- (void)drawRect:(NSRect)r;
{
    if( [menuExtra alternateImage] && [menuExtra isMenuDown] )
        [[menuExtra alternateImage] compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
    else
        if( [menuExtra image] && ![menuExtra isMenuDown] )
            [[menuExtra image] compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
}

@end
