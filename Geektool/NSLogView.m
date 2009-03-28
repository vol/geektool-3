#import "NSLogView.h"
#import "GeekTool.h"
#import "LogWindow.h"
#import "LogWindowController.h"

// its magnetic windows!
#define MAGN 10

#define MoveDragType 2
#define ResizeDragType 1

// this class exists so we can move/resize our borderless window
// unfortunately, these common functions are unavailable to us because
// we are using an NSBorderlessWindow, so we must recreate them manually ourselves
@implementation NSLogView

- (void)awakeFromNib
{
    [ self setNextResponder: [ NSApplication sharedApplication ]];
    [self setHighlighted:0];
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    // lets us so user can move window immediately, instead of clicking on it
    // to make it "active" and then again to actually move it
    return YES;
}
- (void)drawRect:(NSRect)rect
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    [ super drawRect: rect ];
    NSBezierPath *bp = [ NSBezierPath bezierPathWithRect: [ self bounds ]];
    NSColor *color;
    
    // if we want this window to be highlighted
    if (highlighted)
    {
        // TODO: link into changing color here
        //color = [[NSColor blackColor] colorWithAlphaComponent:0.1];
        color = [[ NSColor alternateSelectedControlColor ] colorWithAlphaComponent:0.3];
        
        // further drawing will be done with this color
        [ color set ];
        
        // fill rect with this color
        [ bp fill ];
        
        // set the corner image to the resize handle (fun fact: "coin" means
        // "corner" in french)
        [ corner setImage: [ NSImage imageNamed: @"coin" ]];
    }
    else
    {
        // make the background clear
        color = [ NSColor clearColor ];
        [ color set ];
        [ bp fill ];
        
        // get rid of the corner handler, since we won't be needing it
        [ corner setImage: nil ];
    }
    [ pool release ];
}
- (void)mouseDragged:(NSEvent *)theEvent;
{
    // only handle clicks (drags) if the window is highlighted
    if (!highlighted)
        return;
    
    int newX, newY,newW,newH;
    
    NSPoint currentMouseLoc = [ NSEvent mouseLocation ];
    
    // check to se if we are resizing
    if (dragType == ResizeDragType)
    {
        newW = windowFrame.size.width + ( currentMouseLoc.x - mouseLoc.x );
        newH = windowFrame.size.height + ( mouseLoc.y - currentMouseLoc.y );
        newX = windowFrame.origin.x;
        newY = windowFrame.origin.y + ( currentMouseLoc.y - mouseLoc.y );
        
        // don't let the window be resized smaller than 20x20
        if (newW < 20)
            newW = 20;
        if (newH < 20)
        {
            newY = newY - (20-newH);
            newH = 20;
        }
        
        // snap to edges of window
        if ([(GeekTool*)[ NSApplication sharedApplication ] magn ])
        {
            NSEnumerator *e = [[(GeekTool*)[ NSApplication sharedApplication ] xGuides ] objectEnumerator ];
            NSEnumerator *f = [[(GeekTool*)[ NSApplication sharedApplication ] yGuides ] objectEnumerator ];
            NSNumber *xn,*yn;
            
            while (xn = [ e nextObject ])
            {
                float x = [ xn  floatValue ];
                if ((x-MAGN <= newX + newW) && (newX + newW <= x+MAGN))
                    newW = x - newX;
            }
            while (yn = [ f nextObject ])
            {
                float y = [ yn  floatValue ];
                if ((y-MAGN <= newY) && (newY <= y+MAGN))
                {
                    newH = newH + ( newY - y);
                    newY = y;
                }
            }
        }
        if ([ (LogWindowController*)logWindowController type ] == 0 )
            [ (LogWindowController*)logWindowController scrollEnd ];
    }
    // we are moving the window, not resizing it
    else
    {
        newW = windowFrame.size.width;
        newH = windowFrame.size.height;
        newX = windowFrame.origin.x + ( currentMouseLoc.x - mouseLoc.x );
        newY = windowFrame.origin.y - ( mouseLoc.y - currentMouseLoc.y );
        
        // snap to edges of screen if close enough
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
    mouseLoc = [[ self window ] convertBaseToScreen:[theEvent locationInWindow]];
    
    // dont accept clicks if the view is not highlighted
    if (!highlighted)
        return;
    
    windowFrame = [[ self window ] frame ];
    
    // figure out where we are clicking
    // either on the resize handle or not
    if (NSMouseInRect(mouseLoc,NSMakeRect(NSMaxX(windowFrame) - 10,NSMaxY(windowFrame) - NSHeight(windowFrame),10,10),NO))
        dragType=ResizeDragType;
    else
        dragType=MoveDragType;
    [ self display ];
}
- (void)mouseUp:(NSEvent *)theEvent;
{
    //NSLog(@"frame: %@",[[ logWindowController window ] stringWithSavedFrame]);
    if ([ (LogWindowController*)logWindowController type ] == 0)
        [ logWindowController scrollEnd ];
    [ text display ];
    
    // tell GTPrefs that we changed and then save afterward
    [ self sendPosition ];
}
- (void)setHighlighted:(BOOL)flag;
{
    highlighted = flag;
    if (highlighted)
        [[ self window ] makeKeyWindow ];
    [ self display ];
}


- (void)setCrop: (BOOL)aBool;
{
    crop = aBool;
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
                                                         deliverImmediately: YES];
}

// have our window accept commands when its highlighted. when its not, don't
// allow any direct user interaction
- (BOOL)acceptsFirstResponder {
    if (highlighted)
        return YES;
    return NO;
}
- (BOOL)resignFirstResponder {
    if (highlighted)
        return YES;
    return NO;
}
- (BOOL)becomeFirstResponder {
    if (highlighted)
        return YES;
    return NO;
}

@end