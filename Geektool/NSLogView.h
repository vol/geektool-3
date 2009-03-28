/* GeekTool */

#import <Cocoa/Cocoa.h>

@interface NSLogView : NSView
{
    NSPoint mouseLoc;
    NSRect windowFrame;
    IBOutlet id corner;
    IBOutlet id logWindowController;
    int dragType;
    NSTimer *timer;
    IBOutlet id picture;
    int highlighted;
    BOOL crop;
    NSRect cropRect;
    IBOutlet id text;

    BOOL magn;
    NSMutableArray *xGuides;
    NSMutableArray *yGuides;
}
//- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)setHighlighted:(BOOL)flag;
- (void)setCrop: (BOOL)aBool;
- (void)sendPosition;

@end