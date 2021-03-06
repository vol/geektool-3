//
//  GroupController.h
//  GeektoolPreferencePane
//
//  Created by Kevin Nygaard on 3/17/09.
//  Copyright 2009 AllocInit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTLog.h"
#import "GeekToolPrefs.h"

@interface GroupController : NSArrayController {
    IBOutlet id logController;
    IBOutlet id preferencesController;
    
    NSString *groupBeforeEdit;
}
#pragma mark Methods
- (IBAction)addGroup:(id)sender;
- (IBAction)duplicateSelectedGroup:(id)sender;
- (IBAction)removeSelectedGroup:(id)sender;
#pragma mark Checks
- (BOOL)groupExists:(NSString*)myGroupName;
- (NSMutableDictionary*)duplicateCheck:(NSString*)myGroupName;
#pragma mark Table Delegate Methods
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)textObject;
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)textObject;
#pragma mark Convience
- (id)selectedObject;
@end
