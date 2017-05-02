//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpectrumJoystickHandler;

/**
 Middleware between higher level API and low level fuse input API.
 */
@interface SpectrumJoystickController : NSObject

/**
 The handler that will receive all the requests. Assign nil to stop receving events.
 */
@property (weak, nonatomic, nullable) id<SpectrumJoystickHandler> handler;

@end

#pragma mark -

/**
 Requirements for input handler.
 */
@protocol SpectrumJoystickHandler

/**
 Called when number of joysticks should be reported.
 */
- (NSInteger)numberOfJoysticksForSpectrumJoystickController:(SpectrumJoystickController * _Nonnull)controller;

/**
 Called when joystick needs to be polled.
 */
- (void)pollJoysticksForSpectrumJoystickController:(SpectrumJoystickController * _Nonnull)controller;

@end

#pragma mark - 

/**
 Reports given joystick event.
 
 @param which Joystick index.
 @param button Button or stick.
 @param press YES if pressed, NO otherwise.
 */
void controller_report_joystick(int which, input_key button, BOOL press);
