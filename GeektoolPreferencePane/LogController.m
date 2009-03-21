//
//  LogController.m
//  GeektoolPreferencePane
//
//  Created by Kevin Nygaard on 3/18/09.
//  Copyright 2009 AllocInit. All rights reserved.
//

#import "LogController.h"

NSString *MovedRowsType = @"GTLog_Moved_Item";
NSString *CopiedRowsType = @"GTLog_Copied_Item";


@implementation LogController

- (void)awakeFromNib
{
    // register for drag and drop
    
	[tableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
	[tableView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationMove) forLocal:YES];
	
	[tableView registerForDraggedTypes:
     [NSArray arrayWithObjects:CopiedRowsType, MovedRowsType, nil]];
    [tableView setAllowsMultipleSelection:YES];
	
	[super awakeFromNib];
}

// thank you mr mmalc, you fixed my setClearsFilterPredicateOnInsertion: problem
- (NSArray *)arrangeObjects:(NSArray *)objects
{
	/*
	 Create array of objects that match search string.
	 Also add any newly-created object unconditionally:
	 (a) You'll get an error if a newly-added object isn't added to arrangedObjects.
	 (b) The user will see newly-added objects even if they don't match the search term.
	 */
    
    NSMutableArray *matchedObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    
	NSEnumerator *oEnum = [objects objectEnumerator];
    id item;	
    while (item = [oEnum nextObject])
	{
		// if the item has just been created, add it unconditionally
		if (item == newObject)
		{
            [matchedObjects addObject:item];
			newObject = nil;
		}
		else
		{
			//  Use of local autorelease pool here is probably overkill, but may be useful in a larger-scale application.
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSString *groupName = [item valueForKeyPath:@"group"];
			if ([[currentActiveGroup titleOfSelectedItem] isEqualToString:groupName])
			{
				[matchedObjects addObject:item];
			}
			[pool release];
		}
    }
    return [super arrangeObjects:matchedObjects];
}

- (id)newObject
{
    newObject = [super newObject];
    return newObject;
}

#pragma mark Methods
- (IBAction)duplicateLog:(id)sender
{
    // just in case this gets called with nothing selected...
    if ([self selectionIndex] != NSNotFound)
    {
        // get our selection (potentially multiple items)
        NSArray *selectedObjects = [self selectedObjects];
        NSEnumerator *e = [selectedObjects objectEnumerator];
        
        GTLog *currentLog = nil;
        GTLog *copyLog = nil;
        
        // loop for however many items in the set
        while (currentLog = [e nextObject])
        {
            copyLog = [currentLog copy];
            // localize
            [copyLog setName:[NSString stringWithFormat: @"%@ %@", [copyLog name],@"copy"]];
            [self addObject:copyLog];
            [copyLog release];
        }
    }
}

- (IBAction)addLog:(id)sender
{
    NSString *currentGroupString = [currentActiveGroup titleOfSelectedItem];
    GTLog *toAdd = [[GTLog alloc]init];
    [toAdd setGroup:currentGroupString];
    [self addObject:toAdd];
    [toAdd release];
}

#pragma mark Drag n' Drop Stuff
// thanks to mmalc for figuring most of this stuff out for me (and just being amazing)
- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
	 toPasteboard:(NSPasteboard *)pboard
{
	// declare our own pasteboard types
    NSArray *typesArray = [NSArray arrayWithObjects:MovedRowsType, nil];
		
    [pboard declareTypes:typesArray owner:self];
	
    // add rows array for local move
	NSData *rowIndexesArchive = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard setData:rowIndexesArchive forType:MovedRowsType];
	
	// create new array of selected rows for remote drop
    // could do deferred provision, but keep it direct for clarity
	NSMutableArray *rowCopies = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	
    unsigned int currentIndex = [rowIndexes firstIndex];
    while (currentIndex != NSNotFound)
    {
		[rowCopies addObject:[[self arrangedObjects] objectAtIndex:currentIndex]];
        currentIndex = [rowIndexes indexGreaterThanIndex: currentIndex];
    }
	
	// setPropertyList works here because we're using dictionaries, strings,
	// and dates; otherwise, archive collection to NSData...
	[pboard setPropertyList:rowCopies forType:CopiedRowsType];
	
    return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
    
    NSDragOperation dragOp = NSDragOperationCopy;
    
    // if drag source is self, it's a move unless the Option key is pressed
    if ([info draggingSource] == tableView) {
			dragOp =  NSDragOperationMove;
    }
    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn) 
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}

- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
    if (row < 0) {
		row = 0;
	}
	// if drag source is self, it's a move unless the Option key is pressed
    if ([info draggingSource] == tableView) {
			
			NSData *rowsData = [[info draggingPasteboard] dataForType:MovedRowsType];
			NSIndexSet *indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:rowsData];
			
			NSIndexSet *destinationIndexes = [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
			// set selected rows to those that were just moved
			[self setSelectionIndexes:destinationIndexes];
			
			return YES;
    }
    return NO;
}



-(NSIndexSet *) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)fromIndexSet
												toIndex:(unsigned int)insertIndex
{	
	// If any of the removed objects come before the insertion index,
	// we need to decrement the index appropriately
	unsigned int adjustedInsertIndex =
	insertIndex - [fromIndexSet countOfIndexesInRange:(NSRange){0, insertIndex}];
	NSRange destinationRange = NSMakeRange(adjustedInsertIndex, [fromIndexSet count]);
	NSIndexSet *destinationIndexes = [NSIndexSet indexSetWithIndexesInRange:destinationRange];
	
	NSArray *objectsToMove = [[self arrangedObjects] objectsAtIndexes:fromIndexSet];
	[self removeObjectsAtArrangedObjectIndexes:fromIndexSet];	
	[self insertObjects:objectsToMove atArrangedObjectIndexes:destinationIndexes];
	
	return destinationIndexes;
}

@end

#pragma mark -
#pragma mark Quick helper method
/*
 Implementation of NSIndexSet utility category
 */
@implementation NSIndexSet (CountOfIndexesInRange)

-(unsigned int)countOfIndexesInRange:(NSRange)range
{
	unsigned int start, end, count;
	
	if ((start == 0) && (range.length == 0))
	{
		return 0;	
	}
	
	start	= range.location;
	end		= start + range.length;
	count	= 0;
	
	unsigned int currentIndex = [self indexGreaterThanOrEqualToIndex:start];
	
	while ((currentIndex != NSNotFound) && (currentIndex < end))
	{
		count++;
		currentIndex = [self indexGreaterThanIndex:currentIndex];
	}
	
	return count;
}

@end
