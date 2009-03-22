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
        // get our selection (potentially multiple items)
        NSArray *selectedObjects = [self selectedObjects];
        NSEnumerator *e = [selectedObjects objectEnumerator];
       
        NSDictionary *currentGroup = nil;
        NSString *currentGroupString = nil;
        NSEnumerator *f = nil;
        GTLog *origLog = nil;
        GTLog *copyLog = nil;
        
        // loop for however many items in the set
        while (currentGroup = [e nextObject])
        {
            // grab the logs from g_logs
            currentGroupString = [currentGroup valueForKey:@"group"];   
            
            NSMutableArray *groupCopy = [[[preferencesController g_logs]objectForKey:currentGroupString] copy];
            [groupCopy makeObjectsPerformSelector:@selector(setGroup:) withObject:[[self duplicateCheck:currentGroupString]valueForKey:@"group"]];
            [[preferencesController g_logs] setObject:groupCopy forKey:[[self duplicateCheck:currentGroupString]valueForKey:@"group"]];
            
            [self addObject:[self duplicateCheck:currentGroupString]];
        }
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
        
        NSDictionary *currentGroup = nil;
        NSString *currentGroupString = nil;
        
        // loop for however many items in the set
        while (currentGroup = [e nextObject])
        {
            currentGroupString = [currentGroup valueForKey:@"group"];
            
            // remove all items from logController
            [logController removeObjects:[logController content]];
            
            // delete the key from the main g_logs
            [[preferencesController g_logs] removeObjectForKey:currentGroupString];
            
            // remove the group from ourself
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
// this just checks to make sure 2 groups dont have the same name when the 
// group is renamed
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)textObject
{
    NSString *groupName = [textObject string];
    
    // they have the same name, dont accept the edit
    if ([self groupExists: groupName])
        return FALSE;
    
    // else, the names are different and proceed with the edit
    else
    {
        // you can never be too careful...
        int selectionIndex = [self selectionIndex];       
        if (selectionIndex != NSNotFound)
        {
            NSString *groupBeforeEdit = [[[logController content] lastObject]group];
            
            // delete the old key from the main g_logs
            [[preferencesController g_logs] removeObjectForKey:groupBeforeEdit];
            
            // commit the new group to logController. g_log will be handled not by us
            [[logController content] makeObjectsPerformSelector:@selector(setGroup:) withObject:[textObject string]];
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
