//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "uikitjoystick.h"
#import "BridgingHeader.h"
#import "SpectrumJoystickController.h"

int controller_joystick_init_function(void *context);
void controller_joystick_poll_function(void *context);

@implementation SpectrumJoystickController

- (void)setHandler:(id<SpectrumJoystickHandler>)handler {
	[self unhookHandler:_handler];
	_handler = handler;
	[self hookHandler:_handler];
}

- (void)hookHandler:(id<SpectrumJoystickHandler>)handler {
	if (!handler) {
		return;
	}
	
	set_joystick_init_function((__bridge void *)(self), controller_joystick_init_function);
	set_joystick_poll_function((__bridge void *)(self), controller_joystick_poll_function);
}

- (void)unhookHandler:(id<SpectrumJoystickHandler>)handler {
	if (!handler) {
		return;
	}
	
	set_joystick_init_function(nil, nil);
	set_joystick_poll_function(nil, nil);
}

@end

#define CONTROLLER (__bridge SpectrumJoystickController *)context

int controller_joystick_init_function(void *context) {
	SpectrumJoystickController *controller = CONTROLLER;
	return (int)[controller.handler numberOfJoysticksForSpectrumJoystickController:controller];
}

void controller_joystick_poll_function(void *context) {
	SpectrumJoystickController *controller = CONTROLLER;
	[controller.handler pollJoysticksForSpectrumJoystickController:controller];
}

void controller_report_joystick(int which, input_key button, BOOL press) {
	input_event_t event;
	event.type = press ? INPUT_EVENT_JOYSTICK_PRESS : INPUT_EVENT_JOYSTICK_RELEASE;
	event.types.joystick.which = which;
	event.types.joystick.button = button;
	input_event(&event);
}
