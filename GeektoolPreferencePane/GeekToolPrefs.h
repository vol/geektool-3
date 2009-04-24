//
//  GeekToolPrefPref.h
//  GeekToolPref
//
//  Created by Yann Bizeul on Thu Nov 21 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>

#import "GTLog.h"

#define LOGSETN [[self bundle] localizedStringForKey:@"Log Set %i" value:nil table:nil]
#define NLOGSET [[self bundle] localizedStringForKey:@"New Log Set" value:nil table:nil]
#define DGROUP [[self bundle] localizedStringForKey:@"Default Group" value:nil table:nil]
#define COPY [[self bundle] localizedStringForKey:@"copy" value:nil table:nil]

//NSMutableDictionary *g_logs;
@interface GeekToolPrefs : NSPreferencePane 
{
    CFStringRef appID;
    
    IBOutlet id logManager;
    IBOutlet id groupManager;
    IBOutlet id currentGroup;
    IBOutlet id groupSelection;
    IBOutlet id groupsSheet;
    
    NSMutableDictionary *g_logs;
    NSMutableArray *groups;
    NSString *editingGroup;
    
    BOOL allowSave;
    
    BOOL isAddingLog;
    NSString *guiPool;

    int numberOfItemsInPoolMenu;
    
    //NSConnection *theConnection;
    //id RemoteGeekTool;
}
- (id)initWithBundle:(NSBundle *)bundle;
- (void)mainViewDidLoad;
- (void)refreshLogsArray;
- (void)refreshGroupsArray;
- (void)saveNotifications;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (BOOL)allowSave;
- (void)setAllowSave:(BOOL)flag;
- (NSMutableDictionary*)g_logs;
- (void)g_logsAddLog:(GTLog*)log;
#pragma mark -
#pragma mark UI management
- (IBAction)fileChoose:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction)groupsSheetClose:(id)sender;
- (IBAction)gChooseFont:(id)sender;
- (IBAction)selectedGroupChanged:(id)sender;
- (IBAction)currentGroupChanged:(id)sender;
- (IBAction)defaultImages:(id)sender;
- (IBAction)deleteImageSuccess:(id)sender;
- (IBAction)deleteImageFailure:(id)sender;
#pragma mark -
#pragma mark Group Management
- (void)initGroupsMenu;
- (void)showGroupsCustomization;
#pragma mark -
#pragma mark Daemon interaction
- (void)didSelect;
- (void)geekToolWindowChanged:(NSNotification*)aNotification;
- (void)geekToolLaunched:(NSNotification*)aNotification;
- (void)geekToolQuit:(NSNotification*)aNotification;
- (IBAction)toggleEnable:(id)sender;
- (void)updateWindows;
- (void)logReorder:(NSDictionary*)userInfo;
- (void)notifyHighlight;
- (void)applyNotification:(NSNotification*)aNotification;
- (void)applyAndNotifyNotification:(NSNotification*)aNotification;
- (void)reorder:(int)from to:(int)to;
#pragma mark -
#pragma mark Preferences handling
- (void)g_logsUpdate;
- (void)savePrefs;
- (void)applyChanges;
- (IBAction)menuCheckBoxChanged:(id)sender;
- (void)loadMenu;
- (void)unloadMenu;
#pragma mark -
#pragma mark Misc
- (NSRect)screenRect:(NSRect)oldRect;
- (void)didUnselect;
@end
