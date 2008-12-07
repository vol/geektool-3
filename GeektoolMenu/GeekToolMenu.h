//
//  GeekToolMenu.h
//  GeekTool
//
//  Created by Yann Bizeul on Thu Apr 24 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "SystemUIPlugin.h"
#import "GeekToolMenuView.h"

#define ENABLE [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Enable GeekTool" value:nil table:nil]
#define DISABLE [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Disable GeekTool" value:nil table:nil]
#define PREFS [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Open GeekTool preferences..." value:nil table:nil]
#define GROUPS [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Groups" value:nil table:nil]
#define NOGROUPS [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No groups" value:nil table:nil]
#define UPDATE [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Force refresh" value:nil table:nil]

@interface GeekToolMenu : NSMenuExtra {
    CFStringRef appID;
    NSImage*		icon;
    NSImage*		altIcon;
    NSMenu*		menu;
    GeekToolMenuView* view;

    NSString *prefsPath;
}
- (NSString*)searchPrefsPath;
- (void)refreshMenu;
- (void)openPrefs:(id)sender;
- (void)choice:(id)sender;
@end
