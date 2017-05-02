//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include <stdio.h>
#include "uikitjoystick.h"

joystick_init_function_type joystick_init_function = NULL;
joystick_function_type joystick_poll_function = NULL;

void *joystick_init_context = NULL;
void *joystick_poll_context = NULL;

int ui_joystick_init(void) {
  return joystick_init_function(joystick_init_context);
}

void ui_joystick_end(void) {
}

void ui_joystick_poll(void) {
  joystick_poll_function(joystick_poll_context);
}

void set_joystick_init_function(void *context, joystick_init_function_type function) {
  joystick_init_context = context;
  joystick_init_function = function;
}

void set_joystick_poll_function(void *context, joystick_function_type function) {
  joystick_poll_context = context;
  joystick_poll_function = function;
}
