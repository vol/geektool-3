//
//  LogTextField.h
//  GeekTool
//
//  Created by Yann Bizeul on Sun Feb 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface LogTextField : NSTextView {
    void *shadowValues;
    bool shadowText;
}
//Shadows
// This method will enlarge the view's frame by offset in all directions,
// thus preventing the shadow from being clipped by the view's bounding
//rect.
// The offset variable should be roughly the sum of height and radius
//passed to the next method.
// Drawing should be offset by this amount. (Perhaps a coordinate
//transform would be in order?)
- (void) enlargeFrame: (int) offset;

    // Causes all drawing to be done using a drop shadow.
    // Each call to this method must be followed by a call to hideShadow.
- (void) showShadowHeight: (int) height // the offset of the drop shadow from what is drawn
                   radius: (int) radius // how much the shadow is blurred
                  azimuth: (int) azimuth // the angle that the light appears to come from
                       ka: (float) ka; // 0.0 is a black shadow, 1.0 is no shadow

    // Turns off the drop shadow.
    // Must be called after calling the above method.
- (void) hideShadow;
- (BOOL)acceptsFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (void)setShadowText:(bool)shadow;
@end
