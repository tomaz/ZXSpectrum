//
//  FuseController.m
//  spectrum
//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "config.h"
#include <limits.h>
#include <string.h>
#include <ctype.h>

#include "debugger.h"
#include "event.h"
#include "fuse.h"
#include "if1.h"
#include "libspectrum.h"
#include "movie.h"
#include "rzx.h"
#include "psg.h"
#include "settings.h"
#include "settings_cocoa.h"
#include "snapshot.h"
#include "tape.h"
#include "timer.h"
#include "ui.h"
#include "uimedia.h"
#include "uidisplay.h"
#include "utils.h"
#include "tape_block.h"
#include "cocoatape.h"

#import "FuseController.h"

void tape_feedback_handler(float completionRatio, void *context);

@implementation FuseController

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FuseController *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    set_tape_feedback_function((__bridge void *)(instance), tape_feedback_handler);
  });
  return instance;
}

@end

int yyparse(void) {
	return 0;
}

int yywrap(void) {
	return 0;
}

/* Runs in Emulator object context */
char *
ui_get_open_filename( const char *title ) {
	return "";
}

/* Function to (de)activate specific menu items */
int
ui_menu_activate( ui_menu_item item, int active ) {
	return 0;
}

int
ui_tape_browser_update( ui_tape_browser_update_type change, libspectrum_tape_block *block ) {
  FuseController *controller = [FuseController sharedInstance];
  
  // Make sure current block gets completed, many times we only reach 0.9 or similar, not 1...
  if (change == UI_TAPE_BROWSER_SELECT_BLOCK) {
    tape_feedback_handler(1, (__bridge void *)controller);
    tape_feedback_reset();
  }

  // Report new block.
  if (controller.tapeBrowserDidUpdate) {
    controller.tapeBrowserDidUpdate(change, block);
  }
  
  // Change initial progress to 0.
  if (change == UI_TAPE_BROWSER_SELECT_BLOCK) {
    tape_feedback_handler(0, (__bridge void *)controller);
  }
  
	return 0;
}

void
tape_feedback_handler(float completionRatio, void *context) {
  FuseController *controller = (__bridge FuseController *)context;
  if (controller.tapeBlockStateDidChange) {
    controller.tapeBlockStateDidChange(completionRatio);
  }
}
