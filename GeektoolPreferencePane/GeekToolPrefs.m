//
//  GeekToolPrefPref.m
//  GeekToolPref
//
//  Created by Yann Bizeul on Thu Nov 21 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "GeekToolPrefs.h"
#import "defines.h"

@implementation GeekToolPrefs
- (id)initWithBundle:(NSBundle *)bundle
{
    // due to shortcomings of NSUserDefaults, we must use CFPreferences
    // or else we will write to com.apple.systempreferences, which is
    // not really what we want to be doing
    // as such, we will probably not be able to use IB bindings for our prefs
    if ((self = [super initWithBundle:bundle]) != nil)
        appID = CFSTR("com.allocinit.tynsoe.geektool");
    return self;
}

- (void) mainViewDidLoad
{
    // Register for some notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applyAndNotifyNotification:)
                                                 name: NSControlTextDidEndEditingNotification
                                               object: nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(geekToolLaunched:)
                                                            name: @"GTLaunched"
                                                          object: @"GeekTool"
                                              suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(geekToolQuit:)
                                                            name: @"GTQuitOK"
                                                          object: @"GeekTool"
                                              suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(geekToolWindowChanged:)
                                                            name: @"GTWindowChanged"
                                                          object: @"GeekTool"
                                              suspensionBehavior: NSNotificationSuspensionBehaviorCoalesce];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(applyNotification:)
                                                            name: @"GTApply"
                                                          object: @"GeekTool"
                                              suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
    
    // load all our logs
    g_logs = [NSMutableArray array];
    NSArray *logsArray = (NSArray*)CFPreferencesCopyAppValue(CFSTR("logs"), appID);
    
    NSEnumerator *e = [logsArray objectEnumerator];
    NSDictionary *gtDict;
    
    while (gtDict = [e nextObject])
    {
        [g_logs addObject: [[GTLog alloc]initWithDictionary:gtDict]];
    }

    // TODO: setContent to currently active group
    [logManager setContent:g_logs];
    
    // Yes, we need transparency
    [[NSColorPanel sharedColorPanel] setShowsAlpha: YES];
    
    NSNumber *en = (NSNumber*)CFPreferencesCopyAppValue(CFSTR("enableMenu"), appID);
    if ([en boolValue]) [self loadMenu];    

    [self initGroupsMenu];
    [self saveNotifications];
    //[self updatePanel];
}

- (void)saveNotifications
{
    // watch all these variables and run the observeValueForKeyPath function below each time any change
 	[logManager addObserver:self forKeyPath:@"arrangedObjects.enabled" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.name" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.type" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.enabled" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.group" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.fontName" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.fontSize" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.file" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.command" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.hide" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.refresh" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.textColor" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.backgroundColor" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.wrap" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.shadowText" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.shadowWindow" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.alignment" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.force" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.forceTitle" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.showIcon" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.pictureAlignment" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.imageURL" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.transparency" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.imageFit" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.frameType" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.x" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.y" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.w" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.h" options:0 context:nil];
    [logManager addObserver:self forKeyPath:@"arrangedObjects.alwaysOnTop" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self savePrefs];
}

- (IBAction)save:(id)sender
{
    [self savePrefs];
}

#pragma mark -
#pragma mark UI management
- (void)initGroupsMenu
{    
    // clear out everything that is there
    [groupSelection removeAllItems];
    [currentGroup removeAllItems];
    
    // make up our special static menu items via a menu (cant do it via NSPopUpButton)
    NSMenu *standardMenu = [[[NSMenu alloc] initWithTitle:@"StandardMenu"]autorelease];
    [standardMenu addItem:[NSMenuItem separatorItem]];
    [standardMenu addItemWithTitle:@"Customize Groups..." action:nil keyEquivalent:@""];
    
    [groupSelection setMenu:standardMenu];
    
    // put the groups into the popup buttons
    NSMutableArray *groupsArray = [NSMutableArray array];
    NSEnumerator *e = [g_logs objectEnumerator];
    GTLog *tmpLog;
    
    while (tmpLog = [e nextObject])
    {
        if([tmpLog group] && ![groupsArray containsObject:[tmpLog group]])
        {
            [groupSelection insertItemWithTitle:[tmpLog group] atIndex:0];
            [currentGroup insertItemWithTitle:[tmpLog group] atIndex:0];
        }
    }
    
    // get everything selected right (really don't want nil selections)
    NSString *currentGroupString = (NSString*)CFPreferencesCopyAppValue(CFSTR("currentGroup"), appID);
    [currentGroup selectItemWithTitle:currentGroupString];
    [groupSelection selectItemAtIndex:0];
    
    if ([currentGroup selectedItem] == nil) [currentGroup selectItemAtIndex:0];
}

-(IBAction)fileChoose:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseFiles: YES];
    [openPanel beginSheetForDirectory: @"/var/log/"
                                 file: @"system.log"
                                types: nil
                       modalForWindow: [[self mainView] window]
                        modalDelegate: self
                       didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    [NSApp endSheet: sheet];
    if (returnCode == NSOKButton) {
        NSArray *filesToOpen = [sheet filenames];
        // TODO: write to path dictionary directly. bindings should take care of
        // this 
    }
}

-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    // TODO: bindings should facilitate this nicely
    if (returnCode == NSAlertDefaultReturn)
        //[self poolDelete: [pList selectedRow]];
        [sheet close];
}

- (IBAction)pDuplicate:(id)sender;
{
    // TODO: there may be an easier way to do this
    /* NSString *sourcePool = [pools objectAtIndex: [pList selectedRow]];
     NSString *dstPool = [NSString stringWithFormat: @"%@ %@", sourcePool, COPY];
     
     [pools addObject: dstPool];
     
     NSEnumerator *e = [g_logs objectEnumerator];
     GTLog *tempLog;
     while (tempLog = [e nextObject])
     {
     if ([tempLog isInPool: sourcePool])
     [tempLog setEnabled: YES forPool: dstPool];
     }
     [pList reloadData];
     int myRow = [pools indexOfObject: dstPool];
     [pList selectRow: myRow byExtendingSelection:NO];
     [pList editColumn:0
     row: myRow
     withEvent: nil select: YES];
     [self savePrefs];
     */
}

- (IBAction)pClose:(id)sender
{
    // TODO: no clue
    /*[pList deselectAll: self];
     [NSApp stopModal];
     [self initPoolsMenu];
     [self initCurrentPoolMenu];
     guiPool = [[gPoolsMenu titleOfSelectedItem] retain];
     [gLogsList reloadData];
     */
}

-(IBAction)gChooseFont:(id)sender
{
    // TODO: bindings maybe?
    /*
     switch ([self logType])
     {
     case 0:
     [[[self mainView] window] makeFirstResponder: cf1FontTextField];
     break;
     case 1:
     [[[self mainView] window] makeFirstResponder: cf2FontTextField];
     break;
     }
     [[NSFontManager sharedFontManager] orderFrontFontPanel: self];
     */
}

- (IBAction)selectedGroupChanged:(id)sender;
{
    // TODO: bindings should be able to do this
    [self applyChanges];
    if ([sender selectedItem] == [sender lastItem])
        [self showPoolsCustomization];
    else
    {
        [self setSelectedPool: [sender titleOfSelectedItem]];
    }
    [self notifHilight];
}

- (IBAction)currentGroupChanged:(id)sender;
{
    // TODO: bindings
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
    [self notifHilight];
}

-(IBAction)defaultImages:(id)sender
{
    /*
     NSImage *defaultSuccess = [[NSImage alloc] initWithContentsOfFile:
     [[self bundle] pathForResource:@"defaultSuccess" ofType: @"png"]];
     NSImage *defaultFailure = [[NSImage alloc] initWithContentsOfFile:
     [[self bundle] pathForResource:@"defaultFailure" ofType: @"png"]];
     [i2ImageSuccess setImage: defaultSuccess];
     [i2ImageFailure setImage: defaultFailure];
     [defaultSuccess release];
     [defaultFailure release];
     [self applyChanges];
     [self savePrefs];
     [self updateWindows];
     */
}

- (IBAction)deleteImageSuccess:(id)sender;
{
    /*
     [i2ImageSuccess setImage: nil];
     [self gApply: self];
     */
}
- (IBAction)deleteImageFailure:(id)sender;
{
    /*
     [i2ImageFailure setImage: nil];
     [self gApply: self];
     */
}

#pragma mark -
#pragma mark Group Management
- (void)showGroupsCustomization;
{
    /*
     [pList reloadData];
     [NSApp beginSheet: pSheet
     modalForWindow: [[self mainView] window]
     modalDelegate: nil
     didEndSelector: nil
     contextInfo: nil];
     [NSApp runModalForWindow: [[self mainView] window]];
     // Sheet is up here.
     [NSApp endSheet: pSheet];
     [pSheet orderOut: self];
     */
}

- (BOOL)groupExists:(NSString*)myGroupName;
{
    return [groups containsObject:myGroupName];
}

- (NSString*)addGroup:(NSString*)myGroupName;
{
    NSString *newGroupName = [NSString stringWithString: myGroupName];
    if ([self groupExists: myGroupName])
    {
        int i = 2;
        while ([self groupExists: [NSString stringWithFormat: @"%@ %i", myGroupName,i]])
            i++;
        [groups addObject: [NSString stringWithFormat: @"%@ %i", myGroupName,i]];
        newGroupName = [NSString stringWithFormat: @"%@ %i", myGroupName,i];
    }
    [groups addObject: newGroupName];
    return newGroupName;
}

- (void)setSelectedGroup:(NSString*)myGroupName;
{
    /*
     [guiGroup release];
     [gLogsList reloadData];
     guiGroup = [[gGroupsMenu titleOfSelectedItem] retain];
     [self updatePanel];
     */
}
- (NSString*)currentGroupMenu;
{
    /*
     return [gGroupsMenu titleOfSelectedItem];
     */
}
- (int)numberOfGroups
{
    return [groups count];
}
- (void)renameGroup:(NSString*)oldName to:(NSString*)newName
{
    NSString *activeGroupPrefs = (NSString*)CFPreferencesCopyAppValue(CFSTR("currentGroup"), appID);
    
    int index = [groups indexOfObject: oldName];
    [groups removeObjectAtIndex: index];
    [groups insertObject: newName atIndex: index];
    
    NSEnumerator *e = [g_logs objectEnumerator];
    GTLog *currentLog;
    while (currentLog = [e nextObject])
        [currentLog renameGroup:oldName to:newName];
    if ([oldName isEqualTo: activeGroupPrefs])
        CFPreferencesSetAppValue(CFSTR("currentGroup"), newName, appID);
}

- (void)groupDelete:(int)line
{
    /*
     NSString *groupName = [groups objectAtIndex: line];
     NSString *activeGroupPrefs = [userDefaults stringForKey:"currentGroup"];
     
     [groups removeObject: groupName];
     NSEnumerator *e = [g_logs objectEnumerator];
     GTLog *currentLog;
     while (currentLog = [e nextObject])
     [currentLog setEnabled: NO forGroup: groupName];
     
     if ([groupName isEqualTo: activeGroupPrefs])
     [gActiveGroup selectItemWithTitle: [groups objectAtIndex: 0]];
     //     CFPreferencesSetAppValue( CFSTR("currentGroup"), [[self orderedGroupNames] objectAtIndex: 0], appID );
     //  CFPreferencesAppSynchronize( appID );
     [self savePrefs];
     [self updateWindows];
     */
}

#pragma mark -
#pragma mark Log management

- (GTLog*)currentLog
{
    /*
     if ([gLogsList selectedRow] == -1)
     return nil;
     return [g_logs objectAtIndex: [gLogsList selectedRow]];
     */
}
- (IBAction) duplicateLog:(id)sender
{
    /*
     // TODO: look for built in functions for this
     GTLog *newLog = [[g_logs objectAtIndex: [gLogsList selectedRow]] copy];
     [newLog setName: [NSString stringWithFormat: @"%@ copie", [newLog name]]];
     [g_logs addObject: newLog];
     [newLog release];
     [gLogsList reloadData];
     [self applyChanges];
     [self savePrefs];
     [self updateWindows];
     */
}

#pragma mark -
#pragma mark Daemon interaction
- (void)didSelect
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTPrefsLaunched"
                                                                   object: @"GeekToolPrefs"
                                                                 userInfo: nil
                                                       deliverImmediately: YES];
    
}
- (void)geekToolWindowChanged:(NSNotification*)aNotification
{
    /*
     [[NSDistributedNotificationCenter defaultCenter] setSuspended : YES];
     NSDictionary *infos = [aNotification userInfo];
     // if ([[infos objectForKey: @"logFile"] isEqualTo: [[[g_logs objectAtIndex: [gLogsList selectedRow]] objectForKey: @"logEntry"] objectForKey: @"file"]])
     //{
     [sX setIntValue: [[infos objectForKey: @"x"] intValue]];
     [sY setIntValue: [[infos objectForKey: @"y"] intValue]];
     [sW setIntValue: [[infos objectForKey: @"w"] intValue]];
     [sH setIntValue: [[infos objectForKey: @"h"] intValue]];
     [[NSDistributedNotificationCenter defaultCenter] setSuspended : NO];
     // }
     */
}

- (void)geekToolLaunched:(NSNotification*)aNotification;
{
    /*
     [gEnable setState: YES];
     [self notifHilight];
     */
}

- (void)geekToolQuit:(NSNotification*)aNotification;
{
    /*
     [gEnable setState: NO];
     */
}

- (IBAction)toggleEnable:(id)sender
{
    NSMutableArray *loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef)@"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow",
                                                                          kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *myLoginItem = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: NO],
                                 @"Hide",
                                 [[self bundle] pathForResource:@"GeekTool" ofType: @"app"],@"Path",
                                 nil];
    loginItems = [[loginItems autorelease] mutableCopy];
    [loginItems removeObject: myLoginItem];
    
    if ([sender state] == NO)
    {
        CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems,
                              (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser,
                                 kCFPreferencesAnyHost);
        [loginItems release];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTQuit"
                                                                       object: @"GeekToolPrefs"
                                                                     userInfo: nil
                                                           deliverImmediately: YES];
        // [gEnable setState: NSOnState];
        //[RemoteGeekTool deactivate];
    }
    else
    {
        [loginItems addObject: myLoginItem];
        CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems,
                              (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser,
                                 kCFPreferencesAnyHost);
        [loginItems release];
        //[gEnable setState: NSMixedState];
        NSString *myPath = [[[[[self bundle] pathForResource:@"GeekTool" ofType: @"app"]
                              stringByAppendingPathComponent: @"Contents"]
                             stringByAppendingPathComponent: @"MacOS"]
                            stringByAppendingPathComponent: @"GeekTool"];
        [NSTask launchedTaskWithLaunchPath: myPath arguments: [NSArray array]];
    }
    
}
- (void)updateWindows
{
    //[RemoteGeekTool updateWindows];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTUpdateWindows"
                                                                   object: @"GeekToolPrefs"
                                                                 userInfo: nil
                                                       deliverImmediately: YES];
    //    [self notifHilight];    
}
- (void)notifHilight
{
    /*
     int j=0;
     int i=0;
     if (! [[gActivePool titleOfSelectedItem] isEqual: [gPoolsMenu titleOfSelectedItem]])
     j=-1;
     if ([gLogsList selectedRow] == -1)
     j=-1;
     else if (! [[g_logs objectAtIndex: [gLogsList selectedRow]] isInPool: [gActivePool titleOfSelectedItem]])
     j=-1;
     else
     {
     for (i=0;i<[gLogsList selectedRow];i++)
     {
     if ([[g_logs objectAtIndex: i] isInPool: [gActivePool titleOfSelectedItem]])
     j++;
     }
     }
     NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
     [gActivePool titleOfSelectedItem], @"poolName",
     [NSNumber numberWithInt: j], @"index",
     nil];
     [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTHilightWindow"
     object: @"GeekToolPrefs"
     userInfo: userInfo
     deliverImmediately: YES];    
     */
}
- (void)applyNotification:(NSNotification*)aNotification
{
    //[self applyChanges];
    //[self savePrefs];
    //[self updateWindows];
}
- (void)applyAndNotifyNotification:(NSNotification*)aNotification
{
    //[self applyChanges];
    //[self savePrefs];
    //[self updateWindows];
}

- (void)reorder:(int)from to:(int)to
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTReorder"
                                                                   object: @"GeekToolPrefs"
                                                                 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                            [NSNumber numberWithInt: from], @"from",
                                                                            [NSNumber numberWithInt: to], @"to",
                                                                            nil]
                                                       deliverImmediately: YES];
    
}

#pragma mark -
#pragma mark Preferences handling
- (IBAction)gApply:(id)sender
{
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
}

- (void)savePrefs
{
    // TODO: should be able to rip straight from logManager
    NSMutableArray *logsArray = [NSMutableArray array];
     NSEnumerator *e = [[logManager content] objectEnumerator];
     GTLog *gtl;
    
     while (gtl = [e nextObject])
     {
         [logsArray addObject: [gtl dictionary]];
     }
    
    CFPreferencesSetAppValue( CFSTR("currentGroup"), [currentGroup titleOfSelectedItem], appID );
    CFPreferencesSetAppValue( CFSTR("logs"), logsArray, appID );
    CFPreferencesAppSynchronize( appID );
}
- (void)applyChanges
{
    /*
     if (lastSelected == -1)
     return;
     GTLog *currentLog = [g_logs objectAtIndex: lastSelected];
     
     [currentLog setFile: [f1FilePath stringValue]];
     
     [currentLog setCommand: [c2Command stringValue]];
     [currentLog setHide: [c2Hide state]];
     
     [currentLog setShowIcon: [i2ShowIcon state]];
     [currentLog setForceTitle: [i2Title stringValue]];
     [currentLog setForce: [i2Force state]];
     
     [currentLog setImageURL: [s3URL stringValue]];
     [currentLog setTransparency: [t3transparency floatValue]];
     [currentLog setImageFit: [t3Fit indexOfSelectedItem]];
     [currentLog setPictureAlignment: [self pictureAlignment]];
     
     switch ([self logType])
     {   
     // TODO: change these to reflect the setup we have
     case 0 : // File type
     [currentLog setTextColor: [[cf1TextColor color] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace" ]];
     [currentLog setBackgroundColor: [[cf1BackgroundColor color] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"]];
     [currentLog setFontName: [[cf1FontTextField font] fontName]];
     [currentLog setFontSize: [[cf1FontTextField font] pointSize]];
     [currentLog setShadowText: [t1ShadowText state]];
     [currentLog setShadowWindow: [cf1ShadowWindow state]];
     [currentLog setAlignment: [self alignment]];
     [currentLog setFrameType: [cf1FrameType indexOfSelectedItem]];
     [currentLog setWrap: [t1TextWrap state]];
     break;
     case 1 : // Command type
     [currentLog setTextColor: [[cf2TextColor color] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace" ]];
     [currentLog setBackgroundColor: [[cf2BackgroundColor color] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"]];
     [currentLog setFontName: [[cf2FontTextField font] fontName]];
     [currentLog setFontSize: [[cf2FontTextField font] pointSize]];
     [currentLog setShadowText: [t2ShadowText state]];
     [currentLog setShadowWindow: [cf2ShadowWindow state]];
     [currentLog setAlignment: [self alignment]];
     [currentLog setRefresh: [c2Refresh intValue]];
     [currentLog setFrameType: [cf2FrameType indexOfSelectedItem]];
     [currentLog setWrap: [t2TextWrap state]];
     //if ([i2ImageSuccess image])
     [currentLog setImageSuccess: [i2ImageSuccess image]];
     //if ([i2ImageFailure image])
     [currentLog setImageFailure: [i2ImageFailure image]];
     break;
     case 2 :
     [currentLog setRefresh: [s3Refresh intValue]];
     [currentLog setFrameType: [t3FrameType indexOfSelectedItem]];
     break;
     }
     
     [currentLog setType: [self logType]];
     
     // Image type
     
     // Generic
     [currentLog setRect: NSMakeRect([sX intValue],
     [sY intValue],
     [sW intValue],
     [sH intValue])];
     
     if ([kot state])
     [currentLog setWindowLevel: NSStatusWindowLevel];
     else
     [currentLog setWindowLevel: kCGDesktopWindowLevel];
     */
}

- (IBAction)menuCheckBoxChanged:(id)sender
{
    if ([sender state])
    {
        CFPreferencesSetAppValue(CFSTR("enableMenu"), [NSNumber numberWithBool: YES], appID);
        [self loadMenu];
    }
    else
    {
        CFPreferencesSetAppValue(CFSTR("enableMenu"), [NSNumber numberWithBool: NO], appID);
        [self unloadMenu];
    }
}
- (void)loadMenu
{
    NSString *menuExtraPath;
    CFURLRef url;
    unsigned int outExtra;
    
    menuExtraPath = [[NSBundle bundleWithPath: [[self bundle] pathForResource:@"GeekToolMenu" ofType: @"menu"]
                      ] pathForResource:@"MenuCracker" ofType: @"menu"];
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraPath, kCFURLPOSIXPathStyle, NO);
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    
    menuExtraPath = [[self bundle] pathForResource:@"GeekToolMenu" ofType: @"menu"];
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraPath, kCFURLPOSIXPathStyle, NO);
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
}
- (void)unloadMenu
{
    typedef struct OpaqueMenuExtraRef *MenuExtraRef;
    unsigned int outExtra;
    
    CFPreferencesSetAppValue(CFSTR("enableMenu"), [NSNumber numberWithBool: NO], appID);
    NSString *identifier=@"org.tynsoe.geektool";
    MenuExtraRef *menuExtra = nil;
    CoreMenuExtraGetMenuExtra((CFStringRef)identifier, &menuExtra);
    if (menuExtra != nil)
        CoreMenuExtraRemoveMenuExtra( menuExtra, &outExtra );    
}
#pragma mark -
#pragma mark Misc

- (NSRect)screenRect:(NSRect)oldRect
{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    int screenY = screenSize.size.height - oldRect.origin.y - oldRect.size.height;
    return NSMakeRect(oldRect.origin.x, screenY, oldRect.size.width, oldRect.size.height);
}

- (void)didUnselect
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTPrefsQuit"
                                                                   object: @"GeekToolPrefs"
                                                                 userInfo: nil
                                                       deliverImmediately: YES];
    [[[NSFontManager sharedFontManager] fontPanel: NO] close];
}
@end
