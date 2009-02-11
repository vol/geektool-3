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
    if ((self = [super initWithBundle:bundle]) != nil)
        appID = CFSTR("org.tynsoe.geektool");
    return self;
}

- (void) mainViewDidLoad
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
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
    NSMutableArray *manager = [NSMutableArray array];
    NSArray *logsArray = [userDefaults arrayForKey:@"logs"];
    
    NSEnumerator *e = [logsArray objectEnumerator];
    NSDictionary *gtDict;
    
    while (gtDict = [e nextObject])
    {
        [manager addObject: [[GTLog alloc]initWithDictionary:gtDict]];
    }

    [logManager setContent:manager];
    // TODO: add all GTLogs to g_logs
    
    // Yes, we need transparency
    [[NSColorPanel sharedColorPanel] setShowsAlpha: YES];
    
    if ([userDefaults boolForKey:@"enableMenu"]) [self loadMenu];
    [self initCurrentPoolMenu];
    [self initPoolsMenu];
    [self updatePanel];
}

- (IBAction)save:(id)sender
{
    [self savePrefs];
}

#pragma mark -
#pragma mark UI management
- (void)initPoolsMenu
{
    // TODO: create a menu of our groups (pools)
}
- (void)initCurrentPoolMenu
{
    // TODO: put our group selection into our pool (table)
    // NSString *activePoolPrefs = [userDefaults stringForKey:@"currentPool"];
}
- (void)updatePanel
{
    [self initPoolsMenu];
    [self initCurrentPoolMenu];
    
    // set the log type to what was selected last as the tab
    
    // TODO: setup our new item
}

-(IBAction)gChoose:(id)sender
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

- (int)logType
{
    // TODO: integrate this with the GTLog object
    // grab this from the GTLog object
    /*
     if ([tTypeFile state] == YES)
     return GTTypeFile;
     else
     return GTTypeCommand;
     */
}

- (void)setLogType:(int)logType
{
    // TODO: bindings should take care of this
}

- (IBAction)pDelete:(id)sender;
{
    // TODO: array controller should handle this
}

- (IBAction)pAdd:(id)sender;
{
    // TODO: array controller should handle this
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

- (IBAction)poolsMenuChanged:(id)sender;
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

- (IBAction)activePoolChanged:(id)sender;
{
    // TODO: bindings
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
    [self notifHilight];
}

- (IBAction)typeChanged:(id)sender;
{
    // TODO: bindings
    //[tTab selectTabViewItemAtIndex: [sender indexOfSelectedItem]];
    
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
}

- (IBAction)changeImageAlignment:(id)sender;
{
    // TODO: bindings
    [self setPictureAlignment: [sender tag]];
    
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
}

- (IBAction)adjustTransparency:(id)sender
{
    /*
     [[g_logs objectAtIndex: lastSelected] setTransparency: [sender floatValue]];
     [t3transparencyValue setStringValue: [NSString stringWithFormat: @"%i%%", [sender intValue]]];
     [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTTransparency"
     object: @"GeekToolPrefs"
     userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat: [sender floatValue] / 100],@"transparency",
     nil]
     deliverImmediately: YES];
     [self applyChanges];
     [self savePrefs];
     */
    
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

- (IBAction)showHelp:(id)sender;
{
    NSString *path = [[self bundle] pathForResource: @"index" ofType:@"html" inDirectory:@"GeekTool Help"];
    AHGotoPage(NULL,(CFStringRef)[NSString stringWithFormat: @"file://%@", path],NULL);
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
#pragma mark Pool Management
- (void)showPoolsCustomization;
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

- (BOOL) poolExists:(NSString*)myPoolName;
{
    return [pools containsObject: myPoolName];
}

- (NSString*) addPool:(NSString*)myPoolName;
{
    NSString *newPoolName = [NSString stringWithString: myPoolName];
    if ([self poolExists: myPoolName])
    {
        int i = 2;
        while ([self poolExists: [NSString stringWithFormat: @"%@ %i", myPoolName,i]])
            i++;
        [pools addObject: [NSString stringWithFormat: @"%@ %i", myPoolName,i]];
        newPoolName = [NSString stringWithFormat: @"%@ %i", myPoolName,i];
    }
    [pools addObject: newPoolName];
    return newPoolName;
}

- (void)setSelectedPool:(NSString*)myPoolName;
{
    /*
     [guiPool release];
     [gLogsList reloadData];
     guiPool = [[gPoolsMenu titleOfSelectedItem] retain];
     [self updatePanel];
     */
}
- (NSString*)currentPoolMenu;
{
    /*
     return [gPoolsMenu titleOfSelectedItem];
     */
}
- (int)numberOfPools
{
    return [pools count];
}
- (void)renamePool:(NSString*)oldName to:(NSString*)newName
{
    NSString *activePoolPrefs = [userDefaults stringForKey:"currentPool"];
    
    int index = [pools indexOfObject: oldName];
    [pools removeObjectAtIndex: index];
    [pools insertObject: newName atIndex: index];
    
    NSEnumerator *e = [g_logs objectEnumerator];
    GTLog *currentLog;
    while (currentLog = [e nextObject])
        [currentLog renameGroup: oldName to:newName];
    if ([oldName isEqualTo: activePoolPrefs])
        [userDefaults setString:newName forKey:"currentPool"];
}

- (void)poolDelete:(int)line
{
    /*
     NSString *poolName = [pools objectAtIndex: line];
     NSString *activePoolPrefs = [userDefaults stringForKey:"currentPool"];
     
     [pools removeObject: poolName];
     NSEnumerator *e = [g_logs objectEnumerator];
     GTLog *currentLog;
     while (currentLog = [e nextObject])
     [currentLog setEnabled: NO forPool: poolName];
     
     if ([poolName isEqualTo: activePoolPrefs])
     [gActivePool selectItemWithTitle: [pools objectAtIndex: 0]];
     //     CFPreferencesSetAppValue( CFSTR("currentPool"), [[self orderedPoolNames] objectAtIndex: 0], appID );
     //  CFPreferencesAppSynchronize( appID );
     [self savePrefs];
     [self updateWindows];
     */
}
- (NSString*)guiPool
{
    return guiPool;
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
    [self applyChanges];
    [self savePrefs];
    //[self updateWindows];
}
- (void)applyAndNotifyNotification:(NSNotification*)aNotification
{
    [self applyChanges];
    [self savePrefs];
    [self updateWindows];
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
    NSArray *tmp = [logManager content];
     NSEnumerator *e = [[logManager content] objectEnumerator];
     GTLog *gtl;
    
     while (gtl = [e nextObject])
     {
         [logsArray addObject: [gtl dictionary]];
     }
    
     [userDefaults setObject: logsArray forKey:@"logs"];
    [userDefaults synchronize];
    // [userDefaults setString: [gActivePool titleOfSelectedItem] forKey:"activeGroup"];
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
        
        [userDefaults setString: [NSNumber numberWithBool: YES] forKey:"enableMenu"];
        [self loadMenu];
    }
    else
    {
        [userDefaults setString: [NSNumber numberWithBool: NO] forKey:"enableMenu"];
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
    
    [userDefaults setString: [NSNumber numberWithBool: NO] forKey:"enableMenu"];
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
