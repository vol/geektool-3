#import "GeekTool.h"
#import "LogWindow.h"
#import "LogWindowController.h"

#define _NO [ NSNumber numberWithBool: NO ]
#define _YES [ NSNumber numberWithBool: YES ]

@implementation GeekTool
- (void)awakeFromNib
{
    /*int version;
    if ([[ NSUserDefaults standardUserDefaults ] objectForKey: @"version" ])
        version = [[[ NSUserDefaults standardUserDefaults ] objectForKey: @"version" ] intValue ];
    else
        version = 0;
    if (version == 0)
    {
        NSRunAlertPanel(@"GeekTool", NSLocalizedString(@"Preferences need to be updated, please launch GeekTool Preferences",@""), @"OK",nil,nil);
        [ NSApp terminate: self ];
    }
     */
    //[ super awakeFromNib ];
    //[ NSEvent startPeriodicEventsAfterDelay:0 withPeriod:10 ];
    // This array will store the tunnels descriptions and windows/tasks references
    g_logs = [[ NSMutableArray alloc ] init ];
    
    // We register for some preferencePane notifications
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
							  selector: @selector(prefsNotification:)
							      name: nil
							    object: @"GeekToolPrefs"
				    suspensionBehavior: NSNotificationSuspensionBehaviorCoalesce
	];
    [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(applicationDidChangeScreenParameters:)
                                                              name: @"NSApplicationDidChangeScreenParametersNotification"
                                                            object: nil
        ];
    
    // Good, now publish the fact we are running, in case preferencePane is launched
    [ self notifyLaunched ];

    //[ self loadDefaults ];
    [ self updateWindows: NO ];    
    [ self setDelegate: self ];
}

- (void)notifyLaunched
{
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTLaunched"
								     object: @"GeekTool"
							           userInfo: nil
							 deliverImmediately: YES
	]; 
}

// This method handles all notifications sent by the preferencePane
-(void)prefsNotification:(NSNotification*)aNotification
{
    if ([[ aNotification name ] isEqualTo: @"GTUpdateWindows" ]) // Preferences changed, update
        [ self updateWindows: NO ];
    
    if ([[ aNotification name ] isEqualTo: @"GTForceUpdateWindows" ]) // Preferences changed, update
        [ self updateWindows: YES ];
    
    else if ([[ aNotification name ] isEqualTo: @"GTPrefsLaunched" ]) // Preferences here, show it
    {
	// Tell preferencePane we are here too
	[ self notifyLaunched ];
    }
    
    else if ([[ aNotification name ] isEqualTo: @"GTPrefsQuit" ])
    {
        if (hilighted > -1)
        {
            [[ g_logs objectAtIndex: hilighted ] setHilighted: NO ];
            hilighted = -1;
        }
    }
    
    else if ([[ aNotification name ] isEqualTo: @"GTQuit" ])
    {
	// Checkbox has been unchecked, quit
        [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTQuitOK"
                                                                         object: @"GeekTool"
                                                                       userInfo: nil
                                                             deliverImmediately: YES
            ];
        
	[[ NSApplication sharedApplication ] terminate: self ];
    }
    
    else if ([[ aNotification name ] isEqualTo: @"GTHilightWindow" ])
    {
        if ([[[ aNotification userInfo ] objectForKey: @"poolName" ] isEqualTo:
            [[ NSUserDefaults standardUserDefaults ] objectForKey: @"currentPool" ]])
        {
            int index = [[[ aNotification userInfo ] objectForKey: @"index" ] intValue ];
            unsigned int i;
            for (i=0;i<[ g_logs count ];i++)
                [[ g_logs objectAtIndex: i ] setHilighted: NO ];
            if (index > -1)
                [[ g_logs objectAtIndex: index ] setHilighted: YES ];

            hilighted = index;
        }
        else
        {
            if (hilighted > -1)
            {
                [[ g_logs objectAtIndex: hilighted ] setHilighted: NO ];
                hilighted = -1;
            }
        }
        [ self reorder ];
    }
    else if ([[ aNotification name ] isEqualTo: @"GTReorder" ])
    {
        int from = [[[ aNotification userInfo ] objectForKey: @"from" ] intValue ];
        int to = [[[ aNotification userInfo ] objectForKey: @"to" ] intValue ];
        [ g_logs insertObject: [ g_logs objectAtIndex: from ] atIndex: to ];
        if (to < from)
            [ g_logs removeObjectAtIndex: from + 1 ];
        else
            [ g_logs removeObjectAtIndex: from ];

        [ self reorder ];
    }
    else if ([[ aNotification name ] isEqualTo: @"GTTransparency" ])
    {
        if (hilighted != -1)
        {
            float tr = [[[ aNotification userInfo ] objectForKey: @"transparency" ] floatValue ];
            [[ g_logs objectAtIndex: hilighted ] setTransparency : tr ];
        }
    }
}

- (void)reorder
{
    NSEnumerator *e = [ g_logs objectEnumerator ];
    GTLog *log;
    while (log = [ e nextObject ])
        [ log front ];
}
// This method is responsible of reading preferences and initiliaze the g_logs array
-(void)loadDefaults:(BOOL)force
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    [ NSUserDefaults resetStandardUserDefaults ];
    
    // This temp array stores preferences dictionary "as is"
    NSString *currentPool = [[ NSUserDefaults standardUserDefaults ] objectForKey: @"currentPool" ];
    NSArray *logs = [[ NSUserDefaults standardUserDefaults ] objectForKey: @"logs" ];

    if ( logs == nil ) logs = [ NSArray array ];

    // We parse all logs to see if something changed.
    // We add log entries if there are new, and we delete some that could have been
    // deleted in prefs

    unsigned int i = 0;
    
    NSEnumerator *e = [ logs objectEnumerator ];
    NSDictionary *logD;
    while (logD = [ e nextObject ])
    {
        if (! [[ logD objectForKey: @"groups" ] containsObject: currentPool ])
            continue;
        //GTLog * log = [[ GTLog alloc ] initWithDictionary: logD] ;
	// If this is verified, we are updating existing entries
        if (i < [ g_logs count ])
        {
            GTLog *currentLog = [ g_logs objectAtIndex: i ];
            [ currentLog setDictionary: logD force: force];
                /*
            if (! [ log equals: currentLog])
            {
                [ currentLog terminate ];
                [ g_logs replaceObjectAtIndex: i  withObject: log ];
            }
                 */
        }
        else
        {
            GTLog * log = [[ GTLog alloc ] initWithDictionary: logD];
            [ g_logs addObject:  log];
            [ log openWindow ];
            [ log release ];
        }
        //[ log release ];
        i++;
    }
    // Remove all logs upon the count in preferences
    // (those have been deleted)
    while ([ g_logs count ] > i )
    {
        [[ g_logs lastObject ] terminate ];
        [ g_logs removeLastObject ];
    }
    
    logs = nil;
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTUpdateMenu"
                                                                     object: @"GeekTool"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];
    [ pool release ];
}

// This method takes content of g_logs array and update windows with last values in date
- (void)updateWindows:(BOOL)force
{
    [ self loadDefaults: force ];

}
- (void)flagsChanged:(NSEvent*)event
{
    if ([ event modifierFlags ] & NSCommandKeyMask)
    {
        magn = YES;
        xGuides = [[ NSMutableArray array ] retain ];
        yGuides = [[ NSMutableArray array ] retain ];
        NSArray *screens = [ NSScreen screens ];
        NSEnumerator *e = [ screens objectEnumerator ];
        NSScreen *screen;

        [ yGuides addObject: [ NSNumber numberWithFloat: [[ NSScreen mainScreen ] frame ].size.height - 22 ]];
        while (screen = [ e nextObject ])
        {
            [ xGuides addObject: [ NSNumber numberWithFloat: [ screen frame ].origin.x ]];
            [ xGuides addObject: [ NSNumber numberWithFloat: [ screen frame ].origin.x + [ screen frame ].size.width ]];
            [ yGuides addObject: [ NSNumber numberWithFloat: [ screen frame ].origin.y ]];
            [ yGuides addObject: [ NSNumber numberWithFloat: [ screen frame ].origin.y + [ screen frame ].size.height ]];
        }
    }
    else
    {
        magn = NO;
        [ xGuides release ];
        xGuides = nil;
        [ yGuides release ];
        yGuides = nil;
    }
}
- (BOOL)magn
{
    return magn;
}
- (NSMutableArray*)xGuides
{
    return xGuides;
}
- (NSMutableArray*)yGuides
{
    return yGuides;
}
- (void)setMagn:(BOOL)aBool
{
}
// Argh, who changed screen settings ????
- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification
{
    [ self updateWindows: YES ];
}

// Cleanup
- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    NSEnumerator *e = [ g_logs objectEnumerator ];
    GTLog *log;

    while (log = [ e nextObject ])
        [ log terminate ];
}

// We have to terminate tasks before quitting
-(void)dealloc
{
    [ g_logs release ];
}
@end
