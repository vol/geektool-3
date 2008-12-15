//
//  GTLog.m
//  GeekTool
//
//  Created by Yann Bizeul on Sun Jan 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GTLog.h"
#define DEFAULT_REFRESH 10
#define NSYES [NSNumber numberWithBool: YES]
#define NSNO [NSNumber numberWithBool: NO]

// PictureAlignment
#define TOP_LEFT 0
#define TOP 1
#define TOP_RIGHT 2
#define LEFT 3
#define CENTER 4
#define RIGHT 5
#define BOTTOM_LEFT 6
#define BOTTOM 7
#define BOTTOM_RIGHT 8

// ImageFit
#define PROPORTIONALLY 0
#define TO_FIT 1
#define NONE 2

// FrameType
#define FRAME_NONE 0
#define FRAME_PHOTO 1
#define FRAME_GRAYBEZEL 2
#define FRAME_GROOVE 3
#define FRAME_BUTTON 4

// Type
#define TYPE_SHELL 0
#define TYPE_IMAGE 1
#define TYPE_FILE 2

@implementation GTLog

- (id)init
{
	if (!(self = [super init])) return nil;
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
        @"name", @"New log",
        @"type", @"0",
        @"enabled", @"1",

        @"fontName", @"Monaco",
        @"fontSize", @"12",

        @"file", @"",

        @"command", @"",
        @"hide", @"0",
        @"refresh", @"10",

        @"textColor", @"Black",
        @"backgroundColor", @"Black",
        @"wrap", @"0",
        @"shadowText", @"0",
        @"shadowWindow", @"0",
        @"alignment", @"0",

        @"force", @"0",
        @"forceTitle", @"0",
        @"showIcon", @"0",

        @"pictureAlignment", @"0",
        @"imageURL", @"0",
        @"transparency", @"0",
        @"imageFit", @"0",
        @"frameType", @"0",

        @"x", @"0",
        @"y", @"0",
        @"w", @"100",
        @"h", @"100",

        @"alwaysOnTop", @"0",
     nil];
     [self initWithDictionary:defaults];
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary;
{
	if (!(self = [super init])) return nil;
    
    [self setName:[dictionary objectForKey:@"name"]];
    [self setType:[[dictionary objectForKey:@"type"]intValue]];
    [self setEnabled:[[dictionary objectForKey:@"enabled"]boolValue]];

    [self setFontName:[dictionary objectForKey:@"fontName"]];
    [self setFontSize:[[dictionary objectForKey:@"fontSize"]floatValue]];

    [self setFile:[dictionary objectForKey:@"file"]];

    [self setCommand:[dictionary objectForKey:@"command"]];
    [self setHide:[[dictionary objectForKey:@"hide"]boolValue]];
    [self setRefresh:[[dictionary objectForKey:@"refresh"]intValue]];

    [self setTextColor:[dictionary objectForKey:@"textColor"]];
    [self setBackgroundColor:[dictionary objectForKey:@"backgroundColor"]];
    [self setWrap:[[dictionary objectForKey:@"wrap"]boolValue]];
    [self setShadowText:[[dictionary objectForKey:@"shadowText"]boolValue]];
    [self setShadowWindow:[[dictionary objectForKey:@"shadowWindow"]boolValue]];
    [self setAlignment:[[dictionary objectForKey:@"alignment"]intValue]];

    [self setForce:[[dictionary objectForKey:@"force"]boolValue]];
    [self setForceTitle:[dictionary objectForKey:@"forceTitle"]];
    [self setShowIcon:[[dictionary objectForKey:@"showIcon"]boolValue]];

    [self setPictureAlignment:[[dictionary objectForKey:@"pictureAlignment"]intValue]];
    [self setImageURL:[dictionary objectForKey:@"imageURL"]];
    [self setTransparency:[[dictionary objectForKey:@"transparency"]floatValue]];
    [self setImageFit:[[dictionary objectForKey:@"imageFit"]intValue]];
    [self setFrameType:[[dictionary objectForKey:@"frameType"]intValue]];

    [self setX:[[dictionary objectForKey:@"x"]floatValue]];
    [self setY:[[dictionary objectForKey:@"y"]floatValue]];
    [self setW:[[dictionary objectForKey:@"w"]floatValue]];
    [self setH:[[dictionary objectForKey:@"h"]floatValue]];

    [self setAlwaysOnTop:[[dictionary objectForKey:@"alwaysOnTop"]boolValue]];

    NSString *appSupp = [[NSString stringWithString: @"~/Library/Application Support/GeekTool Scripts"] stringByExpandingTildeInPath];
    NSMutableDictionary *tempEnv = [NSMutableDictionary dictionaryWithDictionary:
        [[NSProcessInfo processInfo] environment]
       ];
    NSString *path = [tempEnv objectForKey: @"PATH"];
    [tempEnv setObject: [NSString stringWithFormat: @"%@:%@",appSupp,path] forKey: @"PATH"];

    env =  [tempEnv copy];
    return self;
}

- (NSDictionary*)dictionary
{
    NSMutableDictionary *resultDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:
        [self name]                                       ,@"name",
        [NSNumber numberWithInt: [self type]]             ,@"type",
        [NSNumber numberWithBool: [self enabled]]         ,@"enabled",

        [self fontName]                                   ,@"fontName",
        [self fontSize]                                   ,@"fontSize",

        [self file]                                       ,@"file",

        [self command]                                    ,@"command",
        [self hide]                                       ,@"hide",
        [NSNumber numberWithInt: [self refresh]]          ,@"refresh",

        // put these colors into components
        [self textColor]                                  ,@"textColor",
        [self backgroundColor]                            ,@"backgroundColor",
        [NSNumber numberWithBool: [self wrap]]            ,@"wrap",
        [NSNumber numberWithBool: [self shadowText]]      ,@"shadowText",
        [NSNumber numberWithBool: [self shadowWindow]]    ,@"shadowWindow",
        [NSNumber numberWithInt: [self alignment]]        ,@"alignment",

        [NSNumber numberWithBool: [self force]]           ,@"force",
        [self forceTitle]                                 ,@"forceTitle",
        [NSNumber numberWithBool: [self showIcon]]        ,@"showIcon",
        
        [NSNumber numberWithInt: [self pictureAlignment]] ,@"pictureAlignment",
        [self imageURL]                                   ,@"imageURL",
        [NSNumber numberWithFloat: [self transparency]]   ,@"transparency",
        [NSNumber numberWithInt: [self imageFit]]         ,@"imageFit",
        [NSNumber numberWithInt: [self frameType]]        ,@"frameType",
        
        [NSNumber numberWithInt: [self x]]                ,@"x",
        [NSNumber numberWithInt: [self y]]                ,@"y",
        [NSNumber numberWithInt: [self w]]                ,@"w",
        [NSNumber numberWithInt: [self h]]                ,@"h",
        
        [NSNumber numberWithBool: [self alwaysOnTop]]     ,@"alwaysOnTop",
        nil
       ];

    if ([[self imageSuccess] TIFFRepresentation])
        [resultDictionary setObject: [[self imageSuccess] TIFFRepresentation] forKey: @"imageSuccess"];
    if ([[self imageFailure] TIFFRepresentation])
        [resultDictionary setObject: [[self imageFailure] TIFFRepresentation] forKey: @"imageFailure"];

    return [[resultDictionary retain]autorelease];
     
}

#pragma mark -
#pragma mark Convience Accessors
- (NSRect)realRect
{
    return [self screenToRect: [self rect]];
}

- (NSRect)rect
{
    return NSMakeRect([self x],
                      [self y],
                      [self w],
                      [self h]);
}

- (int)NSFrameType
{
    switch ([self frameType])
    {
        case FRAME_NONE:
            return NSImageFrameNone;
            break;
        case FRAME_PHOTO:
            return NSImageFramePhoto;
            break;
        case FRAME_GRAYBEZEL:
            return NSImageFrameGrayBezel;
            break;
        case FRAME_GROOVE:
            return NSImageFrameGroove;
            break;
        case FRAME_BUTTON:
            return NSImageFrameButton;
            break;
    }
    return NSImageFrameGrayBezel;
}

- (int)NSImageFit
{
    switch ([self imageFit])
    {
        case PROPORTIONALLY:
            return NSScaleProportionally;
            break;
        case TO_FIT:
            return NSScaleToFit;
            break;
        case NONE:
            return NSScaleNone;
            break;
    }
    return NSScaleNone;
}

- (int)NSPictureAlignment
{
    switch ([self pictureAlignment])
    {
        case TOP_LEFT:
            return NSImageAlignTopLeft;
            break;
        case TOP:
            return NSImageAlignTop;
            break;
        case TOP_RIGHT:
            return NSImageAlignTopRight;
            break;
        case LEFT:
            return NSImageAlignLeft;
            break;
        case CENTER:
            return NSImageAlignCenter;
            break;
        case RIGHT:
            return NSImageAlignRight;
            break;
        case BOTTOM_LEFT:
            return NSImageAlignBottomLeft;
            break;
        case BOTTOM:
            return NSImageAlignBottom;
            break;
        case BOTTOM_RIGHT:
            return NSImageAlignBottomRight;
            break;
    }
    return NSImageAlignTopLeft;
}

- (NSFont*)font
{
    NSFont* newFont = [NSFont fontWithName:fontName size:fontSize];
    return [[newFont retain] autorelease];
}

#pragma mark -
#pragma mark KVC Accessors
// NS* things ^f)lywjoreturn 0 retain] autorelease];^wi[[jddjj
// TODO: put initial values for all the NS* objects

- (int)alignment
{
    return alignment;
}

- (NSColor*)backgroundColor
{
    return [[backgroundColor retain] autorelease];
}

- (NSString*)command
{
    return [[command retain] autorelease];
}

- (BOOL)enabled
{
    return enabled;
}

- (NSString*)file
{
    return [[file retain] autorelease];
}

- (NSString*)fontName
{
    return [[fontName retain] autorelease];
}

- (float)fontSize
{
    return fontSize;
}

- (BOOL)force
{
    return force;
}

- (NSString*)forceTitle
{
    return [[forceTitle retain] autorelease];
}

- (int)frameType
{
    return frameType;
}

- (BOOL)hide
{
    return hide;
}

- (NSImage*)imageFailure
{
    return [[imageFailure retain] autorelease];
}

- (int)imageFit
{
    return imageFit;
}

- (NSImage*)imageSuccess
{
    return [[imageSuccess retain] autorelease];
}

- (NSString*)imageURL
{
    return [[imageURL retain] autorelease];
}

- (NSString*)name
{
    return [[name retain] autorelease];
}

- (int)pictureAlignment
{
    return pictureAlignment;
}

- (float)x
{
    return x;
}

- (float)y
{
    return y;
}

- (float)w
{
    return w;
}

- (float)h
{
    return h;
}

- (BOOL)shadowText
{
    return shadowText;
}

- (float)shadowWindow
{
    return shadowWindow;
}

- (BOOL)showIcon
{
    return showIcon;
}

- (NSColor*)textColor
{
    return [[textColor retain] autorelease];
}

- (float)transparency
{
    return transparency;
}

- (int)type
{
    return type;
}

- (BOOL)alwaysOnTop
{
    return alwaysOnTop;
    //return kCGDesktopWindowLevel;
}

- (BOOL)wrap
{
    return wrap;
}

#pragma mark -
#pragma mark KVC Mutators
/*
 * NS* things ^f)lywjoif(0 != var)
{
}kkwwdft~yawjo0release];^i[o0= [var copy];jjddjj
 * int things ^f)lyawjo0=var;^dft~jddjj
 */

- (void)setAlignment:(int)var
{
    alignment=var;
}

- (void)setBackgroundColor:(NSColor*)var
{
    if(backgroundColor != var)
    {
        [backgroundColor release];
        backgroundColor = [var copy];
    }
}

- (void)setCommand:(NSString*)var
{
    if(command != var)
    {
        [command release];
        command = [var copy];
    }
}

- (void)setEnabled:(BOOL)var
{
    enabled=var;
}

- (void)setFile:(NSString*)var
{
    if(file != var)
    {
        [file release];
        file = [var copy];
    }
}

- (void)setFontName:(NSString*)var
{
    if(fontName != var)
    {
        [fontName release];
        fontName = [var copy];
    }
}

- (void)setFontSize:(float)var
{
    fontSize = var;
}

- (void)setForce:(BOOL)var
{
    force=var;
}

- (void)setForceTitle:(NSString*)var
{
    if(forceTitle != var)
    {
        [forceTitle release];
        forceTitle = [var copy];
    }
}

- (void)setFrameType:(int)var
{
    frameType=var;
}

- (void)setHide:(BOOL)var
{
    hide=var;
}

- (void)setImageFailure:(NSImage*)var
{
    if(imageFailure != var)
    {
        [imageFailure release];
        imageFailure = [var copy];
    }
}

- (void)setImageFit:(int)var
{
    imageFit=var;
}

- (void)setImageSuccess:(NSImage*)var
{
    if(imageSuccess != var)
    {
        [imageSuccess release];
        imageSuccess = [var copy];
    }
}

- (void)setImageURL:(NSString*)var
{
    if(imageURL != var)
    {
        [imageURL release];
        imageURL = [var copy];
    }
}

- (void)setName:(NSString*)var
{
    if(name != var)
    {
        [name release];
        name = [var copy];
    }
}

- (void)setPictureAlignment:(int)var
{
    pictureAlignment=var;
}

- (void)setRefresh:(int)var
{
    refresh=var;
}

- (void)setShadowText:(BOOL)var
{
    shadowText=var;
}

- (void)setShadowWindow:(BOOL)var
{
    shadowWindow=var;
}

- (void)setShowIcon:(BOOL)var
{
    showIcon=var;
}

- (void)setTextColor:(NSColor*)var
{
    if(textColor != var)
    {
        [textColor release];
        textColor = [var copy];
    }
}

- (void)setTransparency:(float)var
{
    transparency=var;
    //if (windowController)
     //   [[windowController window] setAlphaValue: aTransparency];
}

- (void)setType:(int)var
{
    type=var;
}

- (void)setAlwaysOnTop:(BOOL)var
{
    alwaysOnTop=var;
}

- (void)setWrap:(BOOL)var
{
    wrap=var;
}

- (void)setX:(float)var
{
    x=var;
}

- (void)setY:(float)var
{
    y=var;
}

- (void)setW:(float)var
{
    w=var;
}

- (void)setH:(float)var
{
    h=var;
}
#pragma mark -
#pragma mark Logs operations

- (void)setImage:(NSString*)urlStr
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSURL *url;
    NSMutableString *myUrl = [NSMutableString stringWithString: urlStr];
    
    if (NSEqualRanges([myUrl rangeOfString: @"?"], NSMakeRange(NSNotFound, 0)))
        [myUrl appendString: @"?GTTIME="];
    else
        [myUrl appendString: @"&GTTIME="];
    [myUrl appendString: [[NSNumber numberWithLong:random()] stringValue]];

    url = [NSURL URLWithString: myUrl];
    NSImage *myImage = [[NSImage alloc] initWithData: [url resourceDataUsingCache:NO]];
    if ([urlStr isEqual: [self imageURL]])
        [windowController setImage: myImage];
    [myImage release];
    [pool release];
}

- (id)copyWithZone:(NSZone *)zone
{
    GTLog *copy = [[[self class] allocWithZone: zone]
            initWithDictionary:[self dictionary]];

    return copy;
}

- (bool)equals:(GTLog*)comp
{
    if ( [[self dictionary] isEqualTo: [comp dictionary]])
        return YES;
    return NO;
}

- (void)front
{
    [[windowController window] orderFront: self];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone: zone];
}

- (void)newLines:(NSNotification*)aNotification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSData *newLines;
    NSString *newLinesString;

    if ([[aNotification name] isEqual : @"NSFileHandleReadToEndOfFileCompletionNotification"])
    {
        newLines = [[aNotification userInfo] objectForKey: @"NSFileHandleNotificationDataItem"];
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                          name: [aNotification name]
                                                        object: nil];        
    }
    else
        newLines = [[aNotification object] availableData];
    
    newLinesString = [[NSString alloc] initWithData: newLines encoding:NSASCIIStringEncoding];
    if (! [newLinesString isEqualTo: @""] || [self type] == 1)
    {
        if (! [self hide] && ! [self force])
            [windowController addText: newLinesString clear: [self type]];
        if ([self type] == 0)
        {
            [windowController scrollEnd];
            [[aNotification object] waitForDataInBackgroundAndNotify];
        }
        
        //[windowController setFont: [self font]];
        [windowController setAttributes: attributes];
    }
    clear = NO;
    [windowController display];
    [newLinesString release];
    [pool release];
}

- (void)openWindow
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSPipe *pipe;
    if ([self enabled] && ! windowController)
    {
        switch ([self type])
        {
            case 0 :
                if ([[self file] isEqual: @""])
                    return;
           // windowController = [[LogWindowController alloc] initWithWindowNibName: @"logWindow"];

            task = [[NSTask alloc] init];

            [task setLaunchPath: @"/usr/bin/tail"];
            [task setArguments: [NSArray arrayWithObjects: @"-n",@"50",@"-F", [self file], nil]];
            [task setEnvironment: env];
            //if (pipe)
            //    [pipe release];
            pipe = [NSPipe pipe];
            [task setStandardOutput: pipe];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                       selector: @selector(newLines:)
                                                           name: @"NSFileHandleReadCompletionNotification"
                                                         object: [pipe fileHandleForReading]];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                       selector: @selector(newLines:)
                                                           name: @"NSFileHandleDataAvailableNotification"
                                                         object: [pipe fileHandleForReading]];
            [[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                       selector: @selector(taskEnd:)
                                                           name: @"NSTaskDidTerminateNotification"
                                                         object: task];            
            [task launch];
                break;
                /*
            case 1 :
                if ([[self command] isEqual: @""])
                    return;
                //windowController = [[LogWindowController alloc] initWithWindowNibName: @"logWindow"];
                //[windowController setReady: YES];
                break;
                
            case 2 :
                if ([[self imageURL] isEqual: @""])
                    return;

                //windowController = [[ImageLogWindowController alloc] initWithWindowNibName: @"imageLogWindow"];
                break;
                */
        }
        windowController = [[LogWindowController alloc] initWithWindowNibName: @"logWindow"];
        [windowController setType: [self type]];
        [[windowController window] setAutodisplay: YES];
        [self updateWindow];
    }
    else if (! [self enabled] && windowController)
        [self terminate];
    [windowController showWindow: self];
    [pool release];
}

- (void)setHilighted:(BOOL)myHilight
{
    [windowController setHilighted: myHilight];
}

- (void)setSticky:(BOOL)flag
{
    [windowController setSticky: flag];
}

- (void)taskEnd:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                      name: [aNotification name]
                                                    object: nil];
    if ([self type] == 0)
    {
        [self terminate];
    }
    if ([self type] == 1 && [self showIcon])
    {
        if ([task terminationStatus] == 0)
            [windowController setImage: [self imageSuccess]];
        else
            [windowController setImage: [self imageFailure]];        
    }
    //[windowController display];
    [task release];
    task = nil;
    return;
}

- (void)terminate;
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    if (task)
    {
        [task terminate];
        [task release];
        //[pipe release];
        task = nil;
    }
    
    if (windowController)
    {
        [[windowController window] close];
        windowController=nil;
    }

    if (timer)
    {
        [timer invalidate];
        [timer release];
        timer=nil;
    }
    if (arguments)
    {
        [arguments release];
        arguments = nil;
    }
}

- (void)updateCommand:(NSTimer*)timer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL free = YES;
    NSPipe *pipe;
    
    switch ([self type])
    {
        case 1 :
            if ([task isRunning])
                free=NO;
            if ( windowController != nil && free)
            {
                task = [[NSTask alloc] init];
                [task setLaunchPath: @"/bin/sh"];
                [task setArguments: arguments];
                [task setEnvironment: env];
                clear = YES;
                pipe = [[NSPipe alloc] init];
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                           selector: @selector(newLines:)
                                                               name: @"NSFileHandleReadToEndOfFileCompletionNotification"
                                                             object: [pipe fileHandleForReading]];
                [[pipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];

                [task setStandardOutput: pipe];

                [[NSNotificationCenter defaultCenter] addObserver: self
                                                           selector: @selector(taskEnd:)
                                                               name: @"NSTaskDidTerminateNotification"
                                                             object: task];
                [task launch];
                [pipe release];
            }
                break;
        case 2:
            [NSThread detachNewThreadSelector: @selector(setImage:)
                                      toTarget: self
                                    withObject: [self imageURL]];
            //[myImage release];
            break;      
    }
    //[windowController display];
    [pool release];
}

- (void)updateWindow
{
    NSWindow *window = [windowController window];

    [window setHasShadow: [self shadowWindow]];
    [window setLevel: [self alwaysOnTop]];
    // change this             VV (this is a bool)
    [self setSticky: [self alwaysOnTop] == kCGDesktopWindowLevel];

    [window setFrame: [self realRect] display: NO];
    [(LogWindow*)window setClickThrough: YES];

    if ([self type] == 0 || [self type] == 1 )
    {
        [windowController setTextBackgroundColor: [self backgroundColor]];
        //[windowController setTextColor: [self textColor]];
        //[windowController setFont: [self font]];
        [windowController setShadowText: [self shadowText]];

        //[windowController setTextAlignment: [self alignment]];
        //[windowController setWrap: [self wrap]];

        // Paragraph style

        NSMutableParagraphStyle *myParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        switch ([self alignment])
        {
            case 0:
                [myParagraphStyle setAlignment: NSLeftTextAlignment];
                break;
            case 1:
                [myParagraphStyle setAlignment: NSCenterTextAlignment];
                break;
            case 2:
                [myParagraphStyle setAlignment: NSRightTextAlignment];
                break;
            case 3:
                [myParagraphStyle setAlignment: NSJustifiedTextAlignment];
                break;
        }
        if ([self wrap])
            [myParagraphStyle setLineBreakMode: NSLineBreakByCharWrapping];
        else
            [myParagraphStyle setLineBreakMode: NSLineBreakByClipping];

        if (attributes)
            [attributes release];

        attributes = [[NSDictionary dictionaryWithObjectsAndKeys:
            myParagraphStyle,   NSParagraphStyleAttributeName,
            [self font],      NSFontAttributeName,
            [self textColor], NSForegroundColorAttributeName,nil] retain];
        [myParagraphStyle release];
        [windowController setAttributes: attributes];
    }
    if ([self type] == 0)
        [windowController scrollEnd];
    [windowController setStyle: [self NSFrameType]];
    
    NSRect rect = [[windowController window] frame];
    int imWidth = 0;
    if ([self showIcon] && [self type] == 1)
    {
        if ([[self imageSuccess] size].width > [[self imageFailure] size].width )
            imWidth = [[self imageSuccess] size].width;
        else
            imWidth = [[self imageFailure] size].width;
    }
    else
    {
        [windowController setImage: nil];
    }
    NSRect newRect;
    if ( [self NSFrameType] == NSImageFrameGrayBezel )
    {
        newRect = NSMakeRect(imWidth + 8,
                             8,
                             rect.size.width - 16  - imWidth,
                             rect.size.height - 16 );
    }
    else
    {
        newRect = NSMakeRect(imWidth,
                             0,
                             rect.size.width - imWidth,
                             rect.size.height);
    }
    [windowController setTextRect: newRect];
    if ([self type] == 1 || [self type] == 2)
    {
        [windowController setPictureAlignment: [self NSPictureAlignment]];
        if (timer)
        {
            [timer invalidate];
            [timer release];
            timer = nil;
        }
        if ([self type] == 1)
        {
            arguments = [[NSArray alloc] initWithObjects: @"-c",[self command], nil];
            clear = YES;
            NSString *temp = @"";
            if ([self hide])
                temp = @"";
            if ([self force])
                temp = [self forceTitle];
            [windowController addText: temp clear: YES];
        }
        else if ([self type] == 2 )
        {
            [windowController setTextBackgroundColor: [NSColor clearColor]];
            //                [windowController setStyle: [self NSFrameType]];
            [[windowController window] setAlphaValue: ([self transparency]*100)];
            [windowController setFit: [self imageFit]];
            //NSGraphicsContext *myGC = [NSGraphicsContext graphicsContextWithWindow:[windowController window]];
            //[myGC setShouldAntialias:YES];
        }
        timer = [[NSTimer scheduledTimerWithTimeInterval: [self refresh]
                                                   target: self
                                                 selector: @selector(updateCommand:)
                                                 userInfo: nil
                                                  repeats: YES] retain];

        [timer fire];
    }
    if ([self type] == 0)
        [windowController scrollEnd];
    [windowController display];
}
#pragma mark -
#pragma mark Misc

- (NSRect)screenToRect:(NSRect)var
{
  //  NSLog(@"%f,%f",rect.origin.y,rect.size.height);
    NSRect screenSize = [[NSScreen mainScreen] frame];
    return NSMakeRect(var.origin.x, (-var.origin.y + screenSize.size.height) - var.size.height, var.size.width,var.size.height);
}

- (NSString*)description
{
    return [NSString stringWithFormat: @"%@",[self dictionary]];
}

- (void)dealloc
{
    [self terminate];
    [super dealloc];
}
@end
