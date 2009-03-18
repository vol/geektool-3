//
//  GroupController.m
//  GeektoolPreferencePane
//
//  Created by Kevin Nygaard on 3/17/09.
//  Copyright 2009 AllocInit. All rights reserved.
//

#import "GroupController.h"

@implementation GroupController
#pragma mark Methods
- (IBAction)duplicateSelectedGroup:(id)sender
{
    // just in case this gets called with nothing selected...
    if ([self selectionIndex] != NSNotFound)
    {
        NSPredicate *origPredicate = [[logController filterPredicate]retain];
        // get our selection (potentially multiple items)
        NSArray *selectedObjects = [self selectedObjects];
        NSEnumerator *e = [selectedObjects objectEnumerator];
       
        NSPredicate *predicate = nil;
        NSArray *filteredArray = nil;
        NSDictionary *currentGroup = nil;
        NSString *currentGroupString = nil;
        NSEnumerator *f = nil;
        GTLog *origLog = nil;
        GTLog *copyLog = nil;
        
        // loop for however many items in the set
        while (currentGroup = [e nextObject])
        {
            currentGroupString = [currentGroup valueForKey:@"group"];
            predicate = [NSPredicate predicateWithFormat:@"group = %@", currentGroupString];
            filteredArray = [[logController content] filteredArrayUsingPredicate:predicate];
                    
            f = [filteredArray objectEnumerator];
            while (origLog = [f nextObject])
            {
                copyLog = [origLog copy];
                [copyLog setGroup:[[self duplicateCheck:currentGroupString]valueForKey:@"group"]];
                [logController addObject:copyLog];
            }
            
            [self addObject:[self duplicateCheck:currentGroupString]];
        }
        [logController setFilterPredicate:origPredicate];
        [origPredicate release];
    }
}

- (IBAction)removeSelectedGroup:(id)sender
{
    // just in case this gets called with nothing selected...
    if ([self selectionIndex] != NSNotFound)
    {
        // get our selection (potentially multiple items)
        NSArray *selectedObjects = [self selectedObjects];
        NSEnumerator *e = [selectedObjects objectEnumerator];
        
        NSPredicate *predicate = nil;
        NSArray *filteredArray = nil;
        NSDictionary *currentGroup = nil;
        NSString *currentGroupString = nil;
        
        // loop for however many items in the set
        while (currentGroup = [e nextObject])
        {
            currentGroupString = [currentGroup valueForKey:@"group"];
            predicate = [NSPredicate predicateWithFormat:@"group = %@", currentGroupString];
            filteredArray = [[logController content] filteredArrayUsingPredicate:predicate];
            
            [logController removeObjects:filteredArray];
            [self removeObject:currentGroup];
        }
    }
}

#pragma mark Checks
- (BOOL)groupExists:(NSString*)myGroupName
{
    return [[self content] containsObject:[NSDictionary dictionaryWithObject:myGroupName forKey:@"group"]];
}

// TODO: make more sophisticated like how finder does it
// folder -> folder copy -> folder copy 2 -> folder copy 3 -> ...
- (NSMutableDictionary*)duplicateCheck:(NSString*)myGroupName
{
    // add a new group, but don't allow duplicates
    NSString *newGroupName = [NSString stringWithString: myGroupName];
    if ([self groupExists: myGroupName])
    {
        int i = 2;
        while ([self groupExists: [NSString stringWithFormat: @"%@ %i", myGroupName,i]])
            i++;
        newGroupName = [NSString stringWithFormat: @"%@ %i", myGroupName,i];
    }
    //[[self content] addObject: [NSDictionary dictionaryWithObject:newGroupName forKey:@"group"]];
    return [NSMutableDictionary dictionaryWithObject:newGroupName forKey:@"group"];
}

#pragma mark Table Delegate Methods
// textShouldEndEditing: wasn't working for some reason...
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)textObject
{
    NSString *groupName = [textObject string];
    if ([self groupExists: groupName])
        return FALSE;
    else
    {
        // you can never be too careful...
        int selectionIndex = [self selectionIndex];       
        if (selectionIndex != NSNotFound)
        {
            NSDictionary *selectedGroup = [self selectedObject];
            NSString *selectedGroupString = [selectedGroup valueForKey:@"group"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group = %@", selectedGroupString];
            NSArray *filteredArray = [[logController content] filteredArrayUsingPredicate:predicate];
            
            [filteredArray makeObjectsPerformSelector:@selector(setGroup:) withObject:[textObject string]];
        }
        return TRUE;
    }
}

#pragma mark Convience
- (id)selectedObject
{
    int selectionIndex = [self selectionIndex];       
    if (selectionIndex != NSNotFound)
        return [[self selectedObjects] objectAtIndex:0];
    else
        return nil;
}
@end
