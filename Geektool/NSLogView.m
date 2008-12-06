#import "NSLogView.h"
#import "GeekTool.h"
#import "LogWindow.h"
#import "LogWindowController.h"

#define MAGN 10

#define MoveDragType 2
#define ResizeDragType 1

@implementation NSLogView
- (void)awakeFromNib
{
    [ self setNextResponder: [ NSApplication sharedApplication ]];
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}
- (void)drawRect:(NSRect)rect
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    [ super drawRect: rect ];
    NSBezierPath *bp = [ NSBezierPath bezierPathWithRect: [ self bounds ]];
    NSColor *color;
    if (hilighted)
    {
	//color = [[NSColor blackColor] colorWithAlphaComponent:0.1];
        color = [[ NSColor alternateSelectedControlColor ] colorWithAlphaComponent:0.3];

	[ color set ];
	[ bp fill ];
        [ corner setImage: [ NSImage imageNamed: @"coin" ]];
    }
    else
    {
	color = [ NSColor clearColor ];
	[ color set ];
	[ bp fill ];
        [ corner setImage: nil ];
    }
    [ pool release ];
}
- (void)mouseDragged:(NSEvent *)theEvent;
{
    if (! hilighted)
	return;

    int newX, newY,newW,newH;

    NSPoint currentMouseLoc = [ NSEvent mouseLocation ];

    if (dragType == ResizeDragType)
    {
        newW = windowFrame.size.width + ( currentMouseLoc.x - mouseLoc.x );
        newH = windowFrame.size.height + ( mouseLoc.y - currentMouseLoc.y );
        newX = windowFrame.origin.x;
        newY = windowFrame.origin.y + ( currentMouseLoc.y - mouseLoc.y );
        if (newW < 20)
            newW = 20;
        if (newH < 20)
        {
            newY = newY - (20-newH);
            newH = 20;
        }
        if ([(GeekTool*)[ NSApplication sharedApplication ] magn ])
            /*
        NSEvent *event = [ NSApp currentEvent ];
        int modifierFlags = [ event modifierFlags ];
        BOOL shiftDown = (0 != (modifierFlags & NSShiftKeyMask) );
        if (shiftDown)
             */
        {
            NSEnumerator *e = [[(GeekTool*)[ NSApplication sharedApplication ] xGuides ] objectEnumerator ];
            NSEnumerator *f = [[(GeekTool*)[ NSApplication sharedApplication ] yGuides ] objectEnumerator ];
            NSNumber *xn,*yn;

            while (xn = [ e nextObject ])
            {
                float x = [ xn  floatValue ];
                if (x-MAGN <= newX + newW && newX + newW <= x+MAGN)
                    newW = x - newX;
            }
            while (yn = [ f nextObject ])
            {
                float y = [ yn  floatValue ];
                if ( y-MAGN <= newY  && newY <= y+MAGN )
                {
                    newH = newH + ( newY - y);
                    newY = y;
                }
            }
        }
        if ([ (LogWindowController*)logWindowController type ] == 0 )
            [ (LogWindowController*)logWindowController scrollEnd ];
    }
    else
    {
        newW = windowFrame.size.width;
        newH = windowFrame.size.height;
        newX = windowFrame.origin.x + ( currentMouseLoc.x - mouseLoc.x );
        newY = windowFrame.origin.y - ( mouseLoc.y - currentMouseLoc.y );
        if ([(GeekTool*)[ NSApplication sharedApplication ] magn ])
        {
            NSEnumerator *e = [[(GeekTool*)[ NSApplication sharedApplication ] xGuides ] objectEnumerator ];
            NSEnumerator *f = [[(GeekTool*)[ NSApplication sharedApplication ] yGuides ] objectEnumerator ];
            NSNumber *xn,*yn;

            while (xn = [ e nextObject ])
            {
                float x = [ xn  floatValue ];
                if ( x-MAGN <= newX && newX <= x+MAGN )
                    newX = x;
                if (x-MAGN <= newX + newW && newX + newW <= x+MAGN)
                    newX = x - newW;
            }
            while (yn = [ f nextObject ])
            {
                float y = [ yn  floatValue ];
                if ( y-MAGN <= newY && newY <= y+MAGN)
                    newY = y;
                if ( y-MAGN <= newY + newH && newY + newH <= y+MAGN )
                    newY = y - newH;
            }
        }
    }

    [[ self window ] setFrame: NSMakeRect(newX,newY,newW,newH) display: YES ];
}

- (void)mouseDown:(NSEvent *)theEvent;
{
    //NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    mouseLoc = [[ self window ] convertBaseToScreen:[theEvent locationInWindow]];
    //mouseLoc = [ NSEvent mouseLocation ];
    if (! hilighted)
	return;
    
    windowFrame = [[ self window ] frame ];
    if (NSMouseInRect(mouseLoc,NSMakeRect(NSMaxX(windowFrame) - 10,NSMaxY(windowFrame) - NSHeight(windowFrame),10,10),NO))
	dragType=ResizeDragType;
    else
	dragType=MoveDragType;

/*    timer = [[ NSTimer scheduledTimerWithTimeInterval: 0.5
                                               target: self
                                             selector: @selector(timerSendPosition:)
                                             userInfo: nil
                                              repeats: YES ] retain ];
*/
    [ self display ];
    //[ pool release ];
}
- (void)mouseUp:(NSEvent *)theEvent;
{
    //[ logWindowController scrollEnd ];
    /*
    [ timer invalidate ];
    [ timer release ];
    timer = nil;
     */
    NSLog(@"frame: %@",[[ logWindowController window ] stringWithSavedFrame]);
    if ([ (LogWindowController*)logWindowController type ] == 0)
        [ logWindowController scrollEnd ];
    [ text display ];
    [ self sendPosition ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTApply"
                                                                     object: @"GeekTool"
                                                                   userInfo: nil
                                                         deliverImmediately: YES ];
}
- (void)setHilighted:(BOOL)flag;
{
    hilighted = flag;
    if (hilighted)
        [[ self window ] makeKeyWindow ];
    [ self display ];

// [ corner setVisible: flag ];
}
/*
- (void)flagsChanged:(NSEvent*)event
{
    NSLog(@"test1");
    [[ NSApplication sharedApplication ] setMagn: [ event modifierFlags ] & NSCommandKeyMask ];
    return;
}
*/
- (void)setCrop: (BOOL)aBool;
{
    crop = aBool;
}
- (void)timerSendPosition:(NSTimer*)aTimer
{
    [ self sendPosition ];
}
- (void)sendPosition
{
    NSRect screenSize = [[ NSScreen mainScreen ] frame ];
    LogWindow *logWindow = (LogWindow*)[ self window ];
    NSRect currentFrame = [ logWindow frame ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTWindowChanged"
                                                                     object: @"GeekTool"
                                                                   userInfo: [ NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [ NSNumber numberWithInt: currentFrame.origin.x ], @"x",
                                                                       [ NSNumber numberWithInt: screenSize.size.height - currentFrame.origin.y - currentFrame.size.height ], @"y",
                                                                       [ NSNumber numberWithInt: currentFrame.size.width ], @"w",
                                                                       [ NSNumber numberWithInt: currentFrame.size.height ], @"h",
                                                                       nil ]
                                                         deliverImmediately: YES
        ];
}
- (BOOL)acceptsFirstResponder {
    if (hilighted)
        return YES;
    return NO;
}
- (BOOL)resignFirstResponder {
    if (hilighted)
        return YES;
     return NO;
}
- (BOOL)becomeFirstResponder {
    if (hilighted)
        return YES;
     return NO;
}

@end