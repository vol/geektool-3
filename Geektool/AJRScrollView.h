/* MyScrollView */

#import <Cocoa/Cocoa.h>

@interface AJRScrollView : NSScrollView
{
    IBOutlet id textView;
    NSColor *backgroundColor;
}
- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)color;
@end
