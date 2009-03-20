/* GeekTool */

#import <Cocoa/Cocoa.h>
#import "GTLog.h"

@interface GeekTool : NSApplication
{    
    id GeekToolPrefs;
    NSUserDefaults *defaults;
    NSMutableArray *g_logs;
    NSConnection *theConnection;
    NSConnection *theConnectionPrefs;
    BOOL isAddingLog;

    int highlighted;

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
