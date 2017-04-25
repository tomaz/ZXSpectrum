//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "uikitjoystick.h"
#import "BridgingHeader.h"
#import "SpectrumInputController.h"

int joystick_init_function(void *context);
void joystick_poll_function(void *context);

@implementation SpectrumInputController

- (void)setHandler:(id<SpectrumInputHandler>)handler {
	[self unhookHandler:_handler];
	_handler = handler;
	[self hookHandler:_handler];
}

- (void)hookHandler:(id<SpectrumInputHandler>)handler {
	if (!handler) {
		return;
	}
	
	set_joystick_init_function((__bridge void *)(self), joystick_init_function);
	set_joystick_poll_function((__bridge void *)(self), joystick_poll_function);
}

- (void)unhookHandler:(id<SpectrumInputHandler>)handler {
	if (!handler) {
		return;
	}
	
	set_joystick_init_function(nil, nil);
	set_joystick_poll_function(nil, nil);
}

@end

#define CONTROLLER (__bridge SpectrumInputController *)context

int joystick_init_function(void *context) {
	SpectrumInputController *controller = CONTROLLER;
	return (int)[controller.handler numberOfJoysticksForSpectrumInputController:controller];
}

void joystick_poll_function(void *context) {
	SpectrumInputController *controller = CONTROLLER;
	[controller.handler pollJoysticksForSpectrumInputController:controller];
}
