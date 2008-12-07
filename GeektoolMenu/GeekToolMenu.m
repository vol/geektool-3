//
//  GeekToolMenu.m
//  GeekTool
//
//  Created by Yann Bizeul on Thu Apr 24 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GeekToolMenu.h"

@implementation GeekToolMenu
- initWithBundle:(NSBundle*)bundle
{
    self = [super initWithBundle:bundle];
    prefsPath = [[ self searchPrefsPath ] retain ];
    if( !self )
        return nil;
    appID = CFSTR("org.tynsoe.geektool");
    // Install our laconic menu
    icon = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"geektoolmenu"]];
    altIcon = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"geektoolmenualt"]];

    // alas, System does not seem to respond to the key equivalents in menu extras...
    menu = [[NSMenu alloc] initWithTitle:@""];
    [[menu addItemWithTitle: ENABLE action:@selector(enable:) keyEquivalent: @"" ] setTarget: self ];
    [menu addItem:[NSMenuItem separatorItem]];
    [ self refreshMenu ];
    view = [[GeekToolMenuView alloc] initWithFrame:[[self view] frame] menuExtra:self];
    [ self setView: view ];

    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(refreshNotif:)
                                                              name: nil
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(refreshNotif:)
                                                              name: nil
                                                            object: @"GeekToolPrefs"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(up:)
                                                              name: @"GTLaunched"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(down:)
                                                              name: @"GTQuitOK"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTPrefsLaunched"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];

    
    return self;
}
- (NSString*)searchPrefsPath
{
    NSString *home = [[ NSString stringWithString: @"~/Library/PreferencePanes/" ] stringByExpandingTildeInPath ];

    NSArray *testArray = [ NSArray arrayWithObjects:
        [ home stringByAppendingPathComponent: @"GeektoolPreferencePane.prefPane/" ],
        @"/Library/PreferencePanes/GeektoolPreferencePane.prefPane/",
        @"/System/Library/PreferencePanes/GeektoolPreferencePane.prefPane/",
        nil ];
    NSEnumerator *e = [ testArray objectEnumerator ];
    NSString *path;
    BOOL isDir;
    while (path = [ e nextObject ])
        if ([[ NSFileManager defaultManager ] fileExistsAtPath: path isDirectory: &isDir ])
            if (isDir)
                return path;
    return nil;
}
- (void)refreshNotif:(NSNotification*)aNotification
{
    [ self refreshMenu ];
}
- (void)up:(NSNotification*)aNotification
{
    [ menu removeItemAtIndex: 0 ];
    [[menu insertItemWithTitle: DISABLE action:@selector(disable:) keyEquivalent: @"" atIndex: 0] setTarget: self ];
}
- (void)down:(NSNotification*)aNotification
{
    [ menu removeItemAtIndex: 0 ];
    [[menu insertItemWithTitle: ENABLE action:@selector(enable:) keyEquivalent: @"" atIndex: 0] setTarget: self ];
}
- (void)refreshMenu
{
    while ([ menu numberOfItems ] > 2)
        [ menu removeItemAtIndex: [ menu numberOfItems ] - 1 ];
    
    [[menu addItemWithTitle: GROUPS action:nil keyEquivalent: @"" ] setTarget: self ];

    CFPreferencesAppSynchronize( appID );
    NSArray *temp = (NSArray*)CFPreferencesCopyAppValue( CFSTR("pools"), appID );
    if ([ temp count ] == 0)
    {
        [[menu addItemWithTitle: NOGROUPS action:@selector(foo:) keyEquivalent:@""] setTarget: self ];
    }
    else
    {
        NSString *current = (NSString*)CFPreferencesCopyAppValue( CFSTR("currentPool"), appID );
        NSEnumerator *e = [ temp objectEnumerator ];
        NSString *menuName;

        while (menuName = [ e nextObject ])
        {
            NSMenuItem *tmenuitem = [ menu addItemWithTitle:[ NSString stringWithFormat: @"  %@",menuName ] action:@selector(choice:) keyEquivalent:@""];
            [ tmenuitem setTarget:self];
            if ([ menuName isEqual: current ])
                [ tmenuitem setState: NSOnState ];
            else
                [ tmenuitem setState: NSOffState ];
        }
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [[menu addItemWithTitle: UPDATE action:@selector(update:) keyEquivalent: @"" ] setTarget: self ];
    [menu addItem:[NSMenuItem separatorItem]];
    [[menu addItemWithTitle: PREFS action:@selector(openPrefs:) keyEquivalent: @"" ] setTarget: self ];
}
- (void)openPrefs:(id)sender
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject: prefsPath ]];
}
- (void)choice:(id)sender
{
    CFPreferencesSetAppValue( CFSTR("currentPool"), [[ sender title ] substringFromIndex: 2 ], appID );
    CFPreferencesAppSynchronize( appID );
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTUpdateWindows"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];
}
- (void)enable:(id)sender
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
                             arguments:[NSArray arrayWithObject: [ prefsPath stringByAppendingString: @"/Contents/Resources/GeekTool.app"]]
        ];
}
- (void)disable:(id)sender
{
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTQuit"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];
}
- (void)update:(id)sender
{
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTForceUpdateWindows"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];    
}
- (NSImage*) image
{
    return icon;
}
- (NSImage*) alternateImage
{
    return altIcon;
}

- (NSMenu*) menu
{
    return menu;
}
@end
