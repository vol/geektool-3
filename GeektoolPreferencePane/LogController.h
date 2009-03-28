//
//  LogController.h
//  GeektoolPreferencePane
//
//  Created by Kevin Nygaard on 3/18/09.
//  Copyright 2009 AllocInit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTLog.h"

@interface LogController : NSArrayController {
    IBOutlet id currentActiveGroup;
    IBOutlet id tableView;
    id newObject;
    IBOutlet id preferencesController;

}
#pragma mark Methods
- (IBAction)duplicateLog:(id)sender;
- (IBAction)addLog:(id)sender;
// table view drag and drop support
- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
toPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;
// utility methods
-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet
toIndex:(unsigned int)insertIndex;
- (id)selectedObject;
@end

#pragma mark -
#pragma mark Quick helper method
@interface NSIndexSet (CountOfIndexesInRange)
-(unsigned int)countOfIndexesInRange:(NSRange)range;
@end