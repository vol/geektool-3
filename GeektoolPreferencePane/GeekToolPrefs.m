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
    // we are probably going to loose some binding stuff as a result
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
    
    // so we don't jump out of groups when we add items
    // Unfortunately, this option screws things up, so we have to leave it on
    // and work around it. sigh...
    //[logManager setClearsFilterPredicateOnInsertion:FALSE];
    [self refreshLogsArray];
    [self refreshGroupsArray];
    
    // Yes, we need transparency
    [[NSColorPanel sharedColorPanel] setShowsAlpha: YES];
    
    NSNumber *en = (NSNumber*)CFPreferencesCopyAppValue(CFSTR("enableMenu"), appID);
    if ([en boolValue]) [self loadMenu];    

    [self initGroupsMenu];
    [self saveNotifications];
    //[self updatePanel];
}

- (void)refreshLogsArray
{
    // load all log dictionaries into logsArray (dicts come from preferences
    // using these dictionaries, create the actual GTLog objects into g_logs
    g_logs = [NSMutableArray array];
    NSArray *logsArray = (NSArray*)CFPreferencesCopyAppValue(CFSTR("logs"), appID);
    
    NSEnumerator *e = [logsArray objectEnumerator];
    NSDictionary *gtDict = nil;
    
    while (gtDict = [e nextObject])
    {
        [g_logs addObject: [[GTLog alloc]initWithDictionary:gtDict]];
    }
    
    // have bindings do the heavy lifting for us
    // TODO: do some NSPredicate filtering here to reflect currently selected group
    [logManager setContent:g_logs];
}    

- (void)refreshGroupsArray
{
    // load groups from our preferences
    NSArray *savedGroups = (NSArray*)CFPreferencesCopyAppValue(CFSTR("groups"), appID);
    
    // because we want to be able to do some fancy bindings for our table, we
    // need to store our groups as a dictionary of one value.
    // crude, i know, but working with NSStrings and NSArrays was simply not
    // working
    groups = [NSMutableArray array];
    NSEnumerator *e = [savedGroups objectEnumerator];
    NSString *tmpString = nil;
    
    // every item in the user preferences, make it a dictionary and pop it in the array
    // make sure it's mutable so we can rename it later on if we have to
    while (tmpString = [e nextObject])
    {
        [groups addObject:[NSMutableDictionary dictionaryWithObject:tmpString forKey:@"group"]];
    }
    
    // now we have the user's groups, time to put in necessary groups (ie groups
    // that the logs use, but may not have been saved in the preferences for
    // some reason)
    e = [g_logs objectEnumerator];
    GTLog *log = nil;
    NSMutableDictionary *tmpDict = nil;
    
    while (log = [e nextObject])
    {
        tmpDict = [NSMutableDictionary dictionaryWithObject:[log group] forKey:@"group"];
        if(![groups containsObject:tmpDict]) [groups addObject:tmpDict];
    }
    
    // if we have no groups at all, put in a default one for our lonely user
    // localize
    if ([groups count] <= 0) [groups addObject:[NSMutableDictionary dictionaryWithObject:@"Default" forKey:@"group"]];
    
    // let the binding magic begin
    [groupManager setContent:groups];    
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

#pragma mark -
#pragma mark UI management

- (IBAction)fileChoose:(id)sender
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

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode == NSAlertDefaultReturn)
        [sheet close];
}

- (IBAction)groupsSheetClose:(id)sender
{
    // close the sheet and refresh our menu
    // note that -initGroupsMenu takes care of the "customize groups..." selection
    [NSApp stopModal];
    [self initGroupsMenu];
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

- (IBAction)selectedGroupChanged:(id)sender
{
    [logManager setFilterPredicate:[NSPredicate predicateWithFormat:@"group = %@",[groupSelection titleOfSelectedItem]]];
    [logManager rearrangeObjects];
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
- (void)initGroupsMenu
{    
    /*
     Empty menu will look like this
     ____________________________
     |--------------------------| 0 Separator
     | Customize Groups...      | 1 Customize Groups item
     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
     */
    
    // groupSelection and currentGroup are IB outlets to their respective elements
    // clear out everything that is there
    [groupSelection removeAllItems];
    [currentGroup removeAllItems];
    
    // make up our special static menu items via a menu (cant do it via NSPopUpButton)
    NSMenu *standardMenu = [[[NSMenu alloc] initWithTitle:@"StandardMenu"]autorelease];
    [standardMenu addItem:[NSMenuItem separatorItem]];
    // localize
    [standardMenu addItemWithTitle:@"Customize Groups..." action:nil keyEquivalent:@""];
    
    // refer to diagram above to see why this is at index 1
    // make the button do stuff. we couldn't combine it with the call above for
    // some reason (had to set target i think)
    NSMenuItem *customizeGroupsItem = [standardMenu itemAtIndex:1];
    [customizeGroupsItem setEnabled:TRUE];
    [customizeGroupsItem setAction:@selector(showGroupsCustomization)];
    [customizeGroupsItem setTarget:self]; 
    
    // commit our menu to the button
    [groupSelection setMenu:standardMenu];
    
    // put the groups into the popup buttons
    NSEnumerator *e = [groups reverseObjectEnumerator];
    NSDictionary *nextDict = nil;
    NSString *groupString = nil;
    
    // notice that we are inserting at index 0, giving stack-like (FILO) input
    // not really important, but remember if you want this sorted, you would have
    // to put it in reverse sorted (notice reverseObjectEnumerator was used
    // to give things a consistant feel of menus)
    while (nextDict = [e nextObject])
    {
        groupString = [nextDict valueForKey:@"group"];
        [groupSelection insertItemWithTitle:groupString atIndex:0];
        [currentGroup insertItemWithTitle:groupString atIndex:0];
    }
    
    // get everything selected right (don't want nil selections)
    NSString *currentGroupString = (NSString*)CFPreferencesCopyAppValue(CFSTR("currentGroup"), appID);
    [currentGroup selectItemWithTitle:currentGroupString];
    [groupSelection selectItemAtIndex:0];
    
    // select something, you fool!
    if ([currentGroup selectedItem] == nil) [currentGroup selectItemAtIndex:0];
    
    // display items only in this group
    [logManager setFilterPredicate:[NSPredicate predicateWithFormat:@"group = %@",[groupSelection titleOfSelectedItem]]];
}

- (void)showGroupsCustomization
{
    [NSApp beginSheet: groupsSheet
       modalForWindow: [[self mainView] window]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow: [[self mainView] window]];
    // Sheet is up here.
    [NSApp endSheet: groupsSheet];
    [groupsSheet orderOut: self];
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

- (void)geekToolLaunched:(NSNotification*)aNotification
{
    /*
     [gEnable setState: YES];
     */
     [self notifyHighlight];

}

- (void)geekToolQuit:(NSNotification*)aNotification
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

- (void)notifyHighlight
{
    int j = 0;
    int i = 0;
    
    // if the active and selected groups are not the same, we would not be able to highlight
    // any of the logs because they wouldn't be active
    if (![[currentGroup titleOfSelectedItem] isEqual: [groupSelection titleOfSelectedItem]])
        j = -1;
    
    // if nothing is selected, be sure to reflect that
    if ([logManager selectionIndex] == NSNotFound) 
        j = -1;
    
    // else, if something is selected, but it's group is not that of the active group
    else if (![[[[logManager selectedObjects]objectAtIndex:0]group] isEqual: [currentGroup titleOfSelectedItem]])
        j = -1;
    
    // finally, loop through and get the index of something? not quite sure
    else
    {
        for (i = 0; i < [logManager selectionIndex]; i++)
        {
            if ([[[g_logs objectAtIndex: i]group] isEqual: [currentGroup titleOfSelectedItem]])
                j++;
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [currentGroup titleOfSelectedItem], @"groupName",
                              [NSNumber numberWithInt: j], @"index",
                              nil];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"GTHighlightWindow"
                                                                   object: @"GeekToolPrefs"
                                                                 userInfo: userInfo
                                                       deliverImmediately: YES];    
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
    NSMutableArray *logsArray = [NSMutableArray array];
    NSEnumerator *e = [g_logs objectEnumerator];
    GTLog *gtl = nil;
    
    while (gtl = [e nextObject])
    {
        [logsArray addObject: [gtl dictionary]];
    }
    
    NSMutableArray *groupsArray = [NSMutableArray array];
    e = [groups objectEnumerator];
    NSDictionary *tmpDict = nil;
    
    while (tmpDict = [e nextObject])
    {
        [groupsArray addObject: [tmpDict valueForKey:@"group"]];
    }
    
    CFPreferencesSetAppValue(CFSTR("currentGroup"), [currentGroup titleOfSelectedItem], appID);
    CFPreferencesSetAppValue(CFSTR("logs"), logsArray, appID);
    CFPreferencesSetAppValue(CFSTR("groups"), groupsArray, appID);
    CFPreferencesAppSynchronize(appID);
    
    [self updateWindows];
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
