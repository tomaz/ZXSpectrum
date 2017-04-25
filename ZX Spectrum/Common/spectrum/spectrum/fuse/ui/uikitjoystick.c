//
//  Created by Tomaz Kragelj on 21.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "uikitjoystick.h"

joystick_init_function_type joystick_init_function = 0;
joystick_function_type joystick_poll_function = 0;

void *joystick_init_context = 0;
void *joystick_poll_context = 0;

int ui_joystick_init(void) {
  if (joystick_init_function != 0) {
    return joystick_init_function(joystick_init_context);
  }
  return 0;
}

void ui_joystick_end(void) {
}

void ui_joystick_poll(void) {
  if (joystick_poll_function != 0) {
    joystick_poll_function(joystick_poll_context);
  }
}

void set_joystick_init_function(void *context, joystick_init_function_type function) {
  joystick_init_context = context;
  joystick_init_function = function;
}

void set_joystick_poll_function(void *context, joystick_function_type function) {
  joystick_poll_context = context;
  joystick_poll_function = function;
}
