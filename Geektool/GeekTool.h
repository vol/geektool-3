/* GeekTool */

#import <Cocoa/Cocoa.h>
#import "GTLog.h"

@interface GeekTool : NSApplication
{
    CFStringRef appID;
    
    id GeekToolPrefs;
    NSUserDefaults *defaults;
    NSMutableArray *g_logs;
    NSConnection *theConnection;
    NSConnection *theConnectionPrefs;
    BOOL isAddingLog;

    int hilighted;

    BOOL magn;
    NSMutableArray *xGuides;
    NSMutableArray *yGuides;
}
- (void)notifyLaunched;
- (void)updateWindows:(BOOL)force;
- (void)prefsNotification:(NSNotification*)aNotification;
- (void)reorder;
- (void)loadDefaults:(BOOL)force;
- (NSMutableArray*)xGuides;
- (NSMutableArray*)yGuides;
- (BOOL)magn;
@end
