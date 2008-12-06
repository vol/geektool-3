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
    int hilighted;
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
- (void)setHilighted:(BOOL)flag;
- (void)setCrop: (BOOL)aBool;
- (void)timerSendPosition:(NSTimer*)aTimer;
- (void)sendPosition;

@end