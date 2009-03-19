#import "LogWindowController.h"
#import "CGSPrivate.h"
#import "defines.h"

#define ZeroRange NSMakeRange(NSNotFound, 0)

@implementation LogWindowController

- (void)setFont:(NSFont*)font
{
    [text setFont: font];
}

- (void)setShadowText:(bool)shadow
{
    [text setShadowText: shadow];
}

- (void)setTextBackgroundColor:(NSColor*)color
{
    //[text setBackgroundColor: color];
    [scrollView setBackgroundColor: color];
    [[self window] setBackgroundColor: [NSColor clearColor]];
}

- (void)setTextColor:(NSColor*)color
{
    [text setTextColor: color];
}

- (void)setTextAlignment:(int)alignment
{
    switch (alignment)
    {
        case ALIGN_LEFT:
            [text setAlignment:NSLeftTextAlignment];
            break;
        case ALIGN_CENTER:
            [text setAlignment:NSCenterTextAlignment];
            break;
        case ALIGN_RIGHT:
            [text setAlignment:NSRightTextAlignment];
            break;
        case ALIGN_JUSTIFIED:
            [text setAlignment:NSJustifiedTextAlignment];
            break;
    }
    //[self display];

}

- (void)setFrame:(NSRect)logWindowRect display:(bool)flag
{
    [[self window] setFrame:logWindowRect display:flag];
}

- (void)setHasShadow:(bool)flag
{
    [[self window] setHasShadow:flag];
}

- (void)setOpaque:(bool)flag
{
    [[self window] setOpaque:flag];
}

- (void)setAutodisplay:(BOOL)value
{
    [[self window] setAutodisplay:value];
}

- (void)setLevel:(int)level
{
    [[self window] setLevel:level];
}

- (void)makeKeyAndOrderFront:(id)sender
{
    [[self window] makeKeyAndOrderFront:sender];
}

- (void)display
{
    //[[self window] display];
    [text display];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [self autorelease];
}

- (void)addText:(NSString*)newText clear:(BOOL)clear
{
    NSMutableCharacterSet *cs = [[NSCharacterSet controlCharacterSet] mutableCopy];
    [cs removeCharactersInRange: NSMakeRange(10,1)];
    NSMutableString *theText = [newText mutableCopy];
    NSRange r;
    while (! NSEqualRanges(r=[theText rangeOfCharacterFromSet: cs],ZeroRange))
    {
//        NSLog(@"range : %i,%i (%@)",r.location,r.length,theText);
        [theText deleteCharactersInRange: r];
    }
    if (clear)
        [text setString: theText];
    else
        [text insertText: theText];
    [theText release];
    [cs release];
}

- (void)scrollEnd
{
    /*
    int i = ([[text string] length]);
    if (i<0) i=0;
     */
    NSRange range = NSMakeRange([[text string] length],1);
    [text scrollRangeToVisible: range];
}

- (void)setHilighted:(BOOL)flag;
{
    [(LogWindow*)[self window] setHilighted: flag];
    [self display];
}

- (void)setWrap:(BOOL)wrap
{
    if ([[text string] length] == 0 )
        [text setString: @" "];
    NSRange range=NSMakeRange(0,[[text string] length]);
    NSTextStorage *textStorage=[text textStorage];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle
        defaultParagraphStyle] mutableCopy];
    if (wrap)
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    else
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [textStorage addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle range:range];
    //[self display];
}

- (void)setStyle:(int)style
{
    [picture setImageFrameStyle: style];
}

-(void)setFit:(int)fit;
{
    [picture setImageScaling: fit];
}

-(void)setCrop:(BOOL)crop;
{
    [logView setCrop: crop];
}

-(void)setPictureAlignment:(int)alignment
{
    [picture setImageAlignment: alignment];
}

- (void)setTextRect:(NSRect)rect
{
    //[text setFrame: rect];
    [scrollView setFrame: rect];
    [scrollView display];
    //[text display];
}

- (void)setImage:(NSImage*)anImage
{
    [picture setImage: anImage];
}

- (void)setType:(int)anInt
{
    type = anInt;
}

- (int)type
{
    return type;
}

- (void)setAttributes:(NSDictionary*)attributes
{
   // NSLog(@"%@",attributes);
//    [[text textStorage] beginEditing];
    [[text textStorage] setAttributes: attributes range: NSMakeRange(0,[[text string] length])];
//    [[text textStorage] endEditing];
    //[self display];
}

-(void)setSticky:(BOOL)flag 
{
    CGSConnection cid;
    CGSWindow wid;
    SInt32 vers; 

    Gestalt(gestaltSystemVersion,&vers); 
    if (vers < 0x1030)
	return;
    wid = [[self window] windowNumber];
    cid = _CGSDefaultConnection();
    int tags[2];
    tags[0] = tags[1] = 0;
    OSStatus retVal = CGSGetWindowTags(cid, wid, tags, 32);
    if(!retVal) {
	if (flag)
	    tags[0] = tags[0] | 0x00000800;
	else
	    tags[0] = tags[0] & 0x00000800;

	retVal = CGSSetWindowTags(cid, wid, tags, 32);
    }
}
@end
