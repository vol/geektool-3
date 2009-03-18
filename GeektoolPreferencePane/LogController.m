//
//  LogController.m
//  GeektoolPreferencePane
//
//  Created by Kevin Nygaard on 3/18/09.
//  Copyright 2009 AllocInit. All rights reserved.
//

#import "LogController.h"


@implementation LogController

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
@end
