//
//  GTLog.h
//  GeekTool
//
//  Created by Yann Bizeul on Sun Jan 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LogWindowController.h"

@interface GTLog : NSObject <NSCopying>
{
    IBOutlet id logWindowController;
    LogWindowController *windowController;
    NSArray *arguments;
    NSDictionary *attributes;
    NSDictionary *env;
    NSTask *task;
    NSTimer *timer;
    bool clear;
    bool empty;
    bool running;
    int i;

    NSString* group;
    int alignment;
    NSColor* backgroundColor;
    NSString* command;
    BOOL enabled;
    NSString* file;
    NSFont* font;
    NSString* fontName;
    float fontSize;
    BOOL force;
    NSString* forceTitle;
    int frameType;
    BOOL hide;
    NSImage* imageFailure;
    int imageFit;
    NSImage* imageSuccess;
    NSString* imageURL;
    NSString* name;
    int NSFrameType;
    int NSImageFit;
    int NSPictureAlignment;
    int pictureAlignment;
    NSRect realRect;
    NSRect rect;
    int refresh;
    int x;
    int y;
    int w;
    int h;
    BOOL shadowText;
    float shadowWindow;
    BOOL showIcon;
    NSColor* textColor;
    float transparency;
    int type;
    BOOL alwaysOnTop;
    BOOL wrap;
}

- (id)initWithDictionary:(NSDictionary*)aDictionary;
- (NSDictionary*)dictionary;
- (void)setDictionary:(NSDictionary*)aDictionary force:(BOOL)force;

#pragma mark -
#pragma mark Convience Accessors
- (NSRect)realRect;
- (NSRect)rect;
- (int)NSFrameType;
- (int)NSImageFit;
- (int)NSPictureAlignment;
- (NSFont*)font;
#pragma mark -
#pragma mark Convience Mutators

#pragma mark -
#pragma mark KVC Accessors
- (int)alignment;
- (NSColor*)backgroundColor;
- (NSString*)command;
- (BOOL)enabled;
- (NSString*)file;
- (NSString*)fontName;
- (float)fontSize;
- (BOOL)force;
- (NSString*)forceTitle;
- (NSString*)group;
- (int)frameType;
- (BOOL)hide;
- (NSImage*)imageFailure;
- (int)imageFit;
- (NSImage*)imageSuccess;
- (NSString*)imageURL;
- (NSString*)name;
- (int)pictureAlignment;
- (int)refresh;
- (float)x;
- (float)y;
- (float)w;
- (float)h;
- (BOOL)shadowText;
- (float)shadowWindow;
- (BOOL)showIcon;
- (NSColor*)textColor;
- (float)transparency;
- (int)type;
- (BOOL)alwaysOnTop;
- (BOOL)wrap;
#pragma mark -
#pragma mark Mutators
- (void)setAlignment:(int)var;
- (void)setBackgroundColorWithDictionary:(NSDictionary*)var;
- (void)setBackgroundColor:(NSColor*)var;
- (void)setCommand:(NSString*)var;
- (void)setEnabled:(BOOL)var;
- (void)setFile:(NSString*)var;
- (void)setFontName:(NSString*)var;
- (void)setFontSize:(float)var;
- (void)setForce:(BOOL)var;
- (void)setForceTitle:(NSString*)var;
- (void)setGroup:(NSString*)var;
- (void)setFrameType:(int)var;
- (void)setHide:(BOOL)var;
- (void)setImageFailure:(NSImage*)var;
- (void)setImageFit:(int)var;
- (void)setImageSuccess:(NSImage*)var;
- (void)setImageURL:(NSString*)var;
- (void)setName:(NSString*)var;
- (void)setPictureAlignment:(int)var;
- (void)setRefresh:(int)var;
- (void)setShadowText:(BOOL)var;
- (void)setShadowWindow:(BOOL)var;
- (void)setShowIcon:(BOOL)var;
- (void)setTextColorWithDictionary:(NSDictionary*)var;
- (void)setTextColor:(NSColor*)var;
- (void)setTransparency:(float)var;
- (void)setType:(int)var;
- (void)setAlwaysOnTop:(BOOL)var;
- (void)setWrap:(BOOL)var;
- (void)setX:(float)var;
- (void)setY:(float)var;
- (void)setW:(float)var;
- (void)setH:(float)var;
#pragma mark -
#pragma mark Logs operations
- (id)copyWithZone:(NSZone *)zone;
- (bool)equals:(GTLog*)comp;
- (void)front;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (void)newLines:(NSNotification*)aNotification;
- (void)openWindow;
- (void)setHilighted:(BOOL)myHilight;
- (void)setSticky:(BOOL)flag;
- (void)taskEnd:(NSNotification*)aNotification;
- (void)terminate;
- (void)updateCommand:(NSTimer*)timer;
- (void)updateWindow;
#pragma mark -
#pragma mark Misc
- (NSRect)screenToRect:(NSRect)var;

@end
