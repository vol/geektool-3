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


@interface GeekToolPrefs : NSPreferencePane 
{
	NSUserDefaults* userDefaults;
    CFStringRef appID;
    
    IBOutlet id logManager;
    NSMutableArray *g_logs;
    BOOL isAddingLog;
    NSString *guiPool;

    int numberOfItemsInPoolMenu;
    
    NSMutableArray *pools;
    //NSConnection *theConnection;
    //id RemoteGeekTool;
}

- (id)initWithBundle:(NSBundle *)bundle;
- (void) mainViewDidLoad;

#pragma mark -
#pragma mark UI management
- (void)initPoolsMenu;
- (void)initCurrentPoolMenu;
- (void)updatePanel;
- (int)alignment;
- (void)setAlignment:(int)alignment;
- (int)pictureAlignment;
- (void)setPictureAlignment:(int)alignment;
- (IBAction)gChoose:(id)sender;
- (IBAction)changeAlignment:(id)sender;
- (void)setControlsState:(bool)state;
- (int)logType;
- (void)setLogType:(int)logType;
- (IBAction)pDelete:(id)sender;
- (IBAction)pAdd:(id)sender;
- (IBAction)pDuplicate:(id)sender;
- (IBAction)pClose:(id)sender;
- (IBAction)gChooseFont:(id)sender;
- (IBAction)poolsMenuChanged:(id)sender;
- (IBAction)activePoolChanged:(id)sender;
- (IBAction)typeChanged:(id)sender;
- (IBAction)changeImageAlignment:(id)sender;
- (IBAction)adjustTransparency:(id)sender;
- (IBAction)defaultImages:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)deleteImageSuccess:(id)sender;
- (IBAction)deleteImageFailure:(id)sender;

#pragma mark -
#pragma mark Pool Management
- (void) showPoolsCustomization;
- (BOOL) poolExists:(NSString*)myPoolName;
- (NSString*) addPool:(NSString*)myPoolName;
- (void)setSelectedPool:(NSString*)myPoolName;
- (NSString*)currentPoolMenu;
- (int)numberOfPools;
- (void)renamePool:(NSString*)oldName to:(NSString*)newName;
- (void)poolDelete:(int)line;
- (NSString*)guiPool;

#pragma mark -
#pragma mark Log management

- (GTLog*)currentLog;
- (IBAction)newLog:(id)sender;
- (IBAction) deleteLog:(id)sender;
- (IBAction) duplicateLog:(id)sender;

#pragma mark -
#pragma mark Daemon interaction
- (void)didSelect;
- (void)geekToolWindowChanged:(NSNotification*)aNotification;
- (void)geekToolLaunched:(NSNotification*)aNotification;
- (IBAction)toggleEnable:(id)sender;
- (void)updateWindows;
- (void)notifHilight;
- (void)reorder:(int)from to:(int)to;

#pragma mark -
#pragma mark Preferences handling
- (IBAction)gApply:(id)sender;
- (void)savePrefs;
- (void)applyChanges;
- (IBAction)menuCheckBoxChanged:(id)sender;
- (void)loadMenu;
- (void)unloadMenu;

#pragma mark -
#pragma mark Misc

- (NSRect)screenRect:(NSRect)oldRect;
@end
