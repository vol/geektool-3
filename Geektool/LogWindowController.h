/* LogWindowController */

#import <Cocoa/Cocoa.h>
#import "LogWindow.h"

@interface LogWindowController : NSWindowController
{
    IBOutlet id text;
    IBOutlet id scrollView;
    IBOutlet id picture;
    IBOutlet id logView;
    int		type;
    //bool rc = NO;
}
- (void)setFont:(NSFont*)font;
- (void)setShadowText:(bool)shadow;
- (void)setTextBackgroundColor:(NSColor*)color;
- (void)setTextColor:(NSColor*)color;
- (void)setTextAlignment:(int)alignment;
- (void)setFrame:(NSRect)logWindowRect display:(bool)flag;
- (void)setHasShadow:(bool)flag;
- (void)setOpaque:(bool)flag;
- (void)setAutodisplay:(BOOL)value;
- (void)setLevel: (int)level;
- (void)makeKeyAndOrderFront: (id)sender;
- (void)display;
- (void)windowWillClose:(NSNotification *)aNotification;
- (void)addText:(NSString*)newText clear:(BOOL)clear;
- (void)scrollEnd;
- (void)setHilighted:(BOOL)flag;
- (void)setWrap:(BOOL)wrap;
- (void)setStyle:(int)style;
- (void)setFit:(int)fit;
- (void)setCrop:(BOOL)crop;
- (void)setPictureAlignment:(int)alignment;
- (void)setTextRect:(NSRect)rect;
- (void)setImage:(NSImage*)anImage;
- (void)setType:(int)anInt;
- (int)type;
- (void)setAttributes:(NSDictionary*)attributes;
- (void)setSticky:(BOOL)flag;
@end
