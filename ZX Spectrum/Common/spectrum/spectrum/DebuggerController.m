//
//  DebuggerController.m
//  spectrum
//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "libspectrum.h"
#include "z80.h"
#include "z80_macros.h"
#import "Emulator.h"
#import "DebuggerController.h"

/* The top line of the current disassembly */
static libspectrum_word disassembly_top;

/* Is the debugger window active (as opposed to the debugger itself)? */
static int debugger_active;

@implementation DebuggerController

@end

int
ui_debugger_activate( void ) {
	[[Emulator instance] debuggerActivate];
	
	return 0;
}

int
ui_debugger_deactivate( int interruptable ) {
//	[[DebuggerController singleton] debugger_deactivate:interruptable];
	
	return 0;
}

/* Update the debugger's display */
int
ui_debugger_update( void ) {
//	[[DebuggerController singleton] debugger_update:nil];
	
	return 0;
}

void
ui_breakpoints_updated( void ) {
//	[[DebuggerController singleton] debugger_update_breakpoints];
}

/* Set the disassembly to start at 'address' */
int
ui_debugger_disassemble( libspectrum_word address ) {
//	[[DebuggerController singleton] debugger_disassemble:address];
	
	return 0;
}

static int
activate_debugger( void ) {
	debugger_active = 1;
	
	disassembly_top = PC;
	ui_debugger_update();
	
	return 0;
}

static int
deactivate_debugger( void ) {
//	[NSApp stopModal];
//	debugger_active = 0;
//	[[DisplayOpenGLView instance] unpause];
	return 0;
}

static void
add_event( gpointer data, gpointer user_data ) {
//	[[DebuggerController singleton] add_event:(event_t*) data];
}
