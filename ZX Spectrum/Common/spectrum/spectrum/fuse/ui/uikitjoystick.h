#ifndef FUSE_UIKITJOYSTICK_H
#define FUSE_UIKITJOYSTICK_H

typedef int(*joystick_init_function_type)(void *context);
typedef void(*joystick_function_type)(void *context);

void set_joystick_init_function(void *context, joystick_init_function_type function);
void set_joystick_poll_function(void *context, joystick_function_type function);

#endif
