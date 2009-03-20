/* LogWindow */

#import <Cocoa/Cocoa.h>

@interface LogWindow : NSWindow
{
    IBOutlet id text;
    IBOutlet id logView;
    NSString *logFile;
}
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag;- (BOOL)canBecomeKeyWindow;
- (void)setHighlighted:(BOOL)flag;
- (void)setClickThrough:(BOOL)clickThrough;
@end
