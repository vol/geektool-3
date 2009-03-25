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
- (IBAction)addGroup:(id)sender
{
    // localize
    NSMutableDictionary *groupToAdd = [self duplicateCheck:@"New Group"];
    [self addObject:groupToAdd];
}

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
        NSDictionary *newGroup = nil;
        NSString *newGroupString = nil;
        
        // loop for however many items in the set
        while (currentGroup = [e nextObject])
        {
            // grab the logs from g_logs
            currentGroupString = [currentGroup valueForKey:@"group"];
            
            // make our new objects for the duplicate object
            newGroup = [self duplicateCheck:currentGroupString];
            newGroupString = [newGroup valueForKey:@"group"];
            
            // all the logs we intend to duplicate
            NSMutableArray *origGroup = [[preferencesController g_logs]objectForKey:currentGroupString];
            NSEnumerator *f = [origGroup objectEnumerator];
            NSMutableArray *copyGroup = [NSMutableArray array];
            GTLog *origLog = nil;
            GTLog *copyLog = nil;

            // loop through all logs we wish to duplicate
            while (origLog = [f nextObject])
            {
                copyLog = [[GTLog alloc]initWithDictionary:[origLog dictionary]];
                [copyGroup addObject:copyLog];
            }
            
            // on that copy, change the groups of the logs
            [copyGroup makeObjectsPerformSelector:@selector(setGroup:) withObject:newGroupString];
            
            // put the array of objects back into g_logs under the duplicate name
            [[preferencesController g_logs] setObject:copyGroup forKey:newGroupString];
            
            // let us know about the new group too
            [self addObject:newGroup];
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
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)textObject
{
    // we just want to know what the group was called before editing
    groupBeforeEdit = [[self selectedObject] objectForKey:@"group"];
    return TRUE;
}

// textShouldEndEditing: wasn't working for some reason...
// this just checks to make sure 2 groups dont have the same name when the 
// group is renamed
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)textObject
{
    NSString *groupName = [textObject string];
    
    // they have the same name, dont accept the edit
    if ([self groupExists: groupName] || [groupName isEqualToString:@""])
        return FALSE;
    
    // else, the names are different and proceed with the edit
    else
    {
        // you can never be too careful...
        int selectionIndex = [self selectionIndex];       
        if (selectionIndex != NSNotFound)
        {            
            // normally, g_logs is updated for us, but since we don't play nice
            // with logController, we could accidently skip it, so just do it here
            // for saftey
            NSMutableArray *origLogs = [[preferencesController g_logs] objectForKey:groupBeforeEdit];
            
            // change our group of our logs to the new group
            [origLogs makeObjectsPerformSelector:@selector(setGroup:) withObject:groupName];
            
            // update logs and delete old ones (if needed)
            if (origLogs)
            {
                [[preferencesController g_logs] setObject:origLogs forKey:groupName];
                [[preferencesController g_logs] removeObjectForKey:groupBeforeEdit];
            }
            // otherwise, just make a blank nsmutablearray and put that in
            else
            {
                [[preferencesController g_logs] setObject:[NSMutableArray array] forKey:groupName];
            }
            
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
