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

}
#pragma mark Methods
- (IBAction)duplicateLog:(id)sender;
- (IBAction)addLog:(id)sender;
@end
