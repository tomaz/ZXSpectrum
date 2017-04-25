//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpectrumInputHandler;

/**
 Middleware between higher level API and low level fuse input API.
 */
@interface SpectrumInputController : NSObject

/**
 The handler that will receive all the requests. Assign nil to stop receving events.
 */
@property (assign, nonatomic, nullable) id<SpectrumInputHandler> handler;

@end

#pragma mark -

/**
 Requirements for input handler.
 */
@protocol SpectrumInputHandler

/**
 Called when number of joysticks should be reported.
 */
- (NSInteger)numberOfJoysticksForSpectrumInputController:(SpectrumInputController * _Nonnull)controller;

/**
 Called when joystick needs to be polled.
 */
- (void)pollJoysticksForSpectrumInputController:(SpectrumInputController * _Nonnull)controller;

@end
