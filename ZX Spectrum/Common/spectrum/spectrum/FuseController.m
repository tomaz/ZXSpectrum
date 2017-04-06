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

#import "FuseController.h"

@implementation FuseController

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
//	return cocoaui_openpanel_get_filename( @"Load Snapshot", snapFileTypes );
}

/* Function to (de)activate specific menu items */
int
ui_menu_activate( ui_menu_item item, int active ) {
//	BOOL value = active ? YES : NO;
//	NSNumber* activeBool = @(value);
//	SEL method = nil;
//	
//	switch (item) {
//		case UI_MENU_ITEM_MEDIA_CARTRIDGE:
//			method = @selector(ui_menu_activate_media_cartridge:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_CARTRIDGE_DOCK:
//			method = @selector(ui_menu_activate_media_cartridge_dock:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_CARTRIDGE_DOCK_EJECT:
//			method = @selector(ui_menu_activate_media_cartridge_dock_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_CARTRIDGE_IF2:
//			method = @selector(ui_menu_activate_media_cartridge_if2:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_CARTRIDGE_IF2_EJECT:
//			method = @selector(ui_menu_activate_media_cartridge_if2_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK:
//			method = @selector(ui_menu_activate_media_disk:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_A_EJECT:
//			method = @selector(ui_menu_activate_media_disk_plus3_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_A_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_plus3_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_A_WP_SET:
//			method = @selector(ui_menu_activate_media_disk_plus3_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_B:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_B_EJECT:
//			method = @selector(ui_menu_activate_media_disk_plus3_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_B_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_plus3_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUS3_B_WP_SET:
//			method = @selector(ui_menu_activate_media_disk_plus3_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA:
//			method = @selector(ui_menu_activate_media_disk_beta:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_A:
//			method = @selector(ui_menu_activate_media_disk_beta_a:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_A_EJECT:
//			method = @selector(ui_menu_activate_media_disk_beta_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_A_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_beta_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_A_WP_SET:
//			method = @selector(ui_menu_activate_media_disk_beta_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_B:
//			method = @selector(ui_menu_activate_media_disk_beta_b:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_B_EJECT:
//			method = @selector(ui_menu_activate_media_disk_beta_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_B_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_beta_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_B_WP_SET:
//			method = @selector(ui_menu_activate_media_disk_beta_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_C:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_C_EJECT:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_C_FLIP_SET:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_C_WP_SET:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_D:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_D_EJECT:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_D_FLIP_SET:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_BETA_D_WP_SET:
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS:
//			method = @selector(ui_menu_activate_media_disk_opus:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_1:
//			method = @selector(ui_menu_activate_media_disk_opus_a:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_1_EJECT:
//			method = @selector(ui_menu_activate_media_disk_opus_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_1_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_opus_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_1_WP_SET:
//			method = @selector(ui_menu_activate_media_opus_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_2:
//			method = @selector(ui_menu_activate_media_disk_opus_b:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_2_EJECT:
//			method = @selector(ui_menu_activate_media_disk_opus_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_2_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_opus_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_OPUS_2_WP_SET:
//			method = @selector(ui_menu_activate_media_opus_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD:
//			method = @selector(ui_menu_activate_media_disk_plusd:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_1:
//			method = @selector(ui_menu_activate_media_disk_plusd_a:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_1_EJECT:
//			method = @selector(ui_menu_activate_media_disk_plusd_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_1_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_plusd_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_1_WP_SET:
//			method = @selector(ui_menu_activate_media_plusd_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_2:
//			method = @selector(ui_menu_activate_media_disk_plusd_b:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_2_EJECT:
//			method = @selector(ui_menu_activate_media_disk_plusd_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_2_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_plusd_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_PLUSD_2_WP_SET:
//			method = @selector(ui_menu_activate_media_plusd_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE:
//			method = @selector(ui_menu_activate_media_disk_disciple:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_1:
//			method = @selector(ui_menu_activate_media_disk_disciple_a:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_1_EJECT:
//			method = @selector(ui_menu_activate_media_disk_disciple_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_1_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_disciple_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_1_WP_SET:
//			method = @selector(ui_menu_activate_media_disciple_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_2:
//			method = @selector(ui_menu_activate_media_disk_disciple_b:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_2_EJECT:
//			method = @selector(ui_menu_activate_media_disk_disciple_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_2_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_disciple_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DISCIPLE_2_WP_SET:
//			method = @selector(ui_menu_activate_media_disciple_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK:
//			method = @selector(ui_menu_activate_media_disk_didaktik:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_A:
//			method = @selector(ui_menu_activate_media_disk_didaktik_a:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_A_EJECT:
//			method = @selector(ui_menu_activate_media_disk_didaktik_a_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_A_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_didaktik_a_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_A_WP_SET:
//			method = @selector(ui_menu_activate_media_didaktik_a_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_B:
//			method = @selector(ui_menu_activate_media_disk_didaktik_b:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_B_EJECT:
//			method = @selector(ui_menu_activate_media_disk_didaktik_b_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_B_FLIP_SET:
//			method = @selector(ui_menu_activate_media_disk_didaktik_b_flip:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_DISK_DIDAKTIK_B_WP_SET:
//			method = @selector(ui_menu_activate_media_didaktik_b_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_RECORDING:
//			method = @selector(ui_menu_activate_recording:);
//			break;
//			
//		case UI_MENU_ITEM_FILE_MOVIE_RECORDING:
//			method = @selector(ui_menu_activate_movie_recording:);
//			break;
//			
//		case UI_MENU_ITEM_FILE_MOVIE_PAUSE:
//			method = @selector(ui_menu_activate_movie_pause:);
//			break;
//			
//		case UI_MENU_ITEM_RECORDING_ROLLBACK:
//			method = @selector(ui_menu_activate_recording_rollback:);
//			break;
//			
//		case UI_MENU_ITEM_AY_LOGGING:
//			method = @selector(ui_menu_activate_ay_logging:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE:
//			method = @selector(ui_menu_activate_media_ide:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_SIMPLE8BIT:
//			method = @selector(ui_menu_activate_media_ide_simple8bit:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_SIMPLE8BIT_MASTER_EJECT:
//			method = @selector(ui_menu_activate_media_ide_simple8bit_master_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_SIMPLE8BIT_SLAVE_EJECT:
//			method = @selector(ui_menu_activate_media_ide_simple8bit_slave_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_ZXATASP:
//			method = @selector(ui_menu_activate_media_ide_zxatasp:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_ZXATASP_MASTER_EJECT:
//			method = @selector(ui_menu_activate_media_ide_zxatasp_master_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_ZXATASP_SLAVE_EJECT:
//			method = @selector(ui_menu_activate_media_ide_zxatasp_slave_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_ZXCF:
//			method = @selector(ui_menu_activate_media_ide_zxcf:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_ZXCF_EJECT:
//			method = @selector(ui_menu_activate_media_ide_zxcf_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1:
//			method = @selector(ui_menu_activate_media_if1:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M1_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m1_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M1_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m1_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M2_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m2_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M2_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m2_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M3_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m3_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M3_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m3_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M4_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m4_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M4_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m4_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M5_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m5_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M5_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m5_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M6_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m6_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M6_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m6_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M7_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m7_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M7_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m7_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M8_EJECT:
//			method = @selector(ui_menu_activate_media_if1_m8_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_M8_WP_SET:
//			method = @selector(ui_menu_activate_media_if1_m8_wp_set:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IF1_RS232_UNPLUG_R:
//		case UI_MENU_ITEM_MEDIA_IF1_RS232_UNPLUG_T:
//		case UI_MENU_ITEM_MEDIA_IF1_SNET_UNPLUG:
//			break;
//			
//		case UI_MENU_ITEM_MACHINE_PROFILER:
//			method = @selector(ui_menu_activate_machine_profiler:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_DIVIDE:
//			method = @selector(ui_menu_activate_media_ide_divide:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_DIVIDE_MASTER_EJECT:
//			method = @selector(ui_menu_activate_media_ide_divide_master_eject:);
//			break;
//			
//		case UI_MENU_ITEM_MEDIA_IDE_DIVIDE_SLAVE_EJECT:
//			method = @selector(ui_menu_activate_media_ide_divide_slave_eject:);
//			break;
//			
//		case UI_MENU_ITEM_TAPE_RECORDING:
//			method = @selector(ui_menu_activate_tape_record:);
//			break;
//			
//		case UI_MENU_ITEM_FILE_SVG_CAPTURE:
//			break;
//			
//		case UI_MENU_ITEM_MACHINE_DIDAKTIK80_SNAP:
//			method = @selector(ui_menu_activate_didaktik80_snap:);
//			break;
//			
//		default:
//			ui_error( UI_ERROR_ERROR, "Attempt to activate unknown menu item %d", item );
//			return 1;
//			
//	}
//	
//	if (method) {
//		[[FuseController singleton]
//		 performSelectorOnMainThread:method
//		 withObject:activeBool
//		 waitUntilDone:NO
//		 ];
//	}
	
	return 0;
}

int
ui_tape_browser_update( ui_tape_browser_update_type change, libspectrum_tape_block *block ) {
//	int error;
//	TapeBrowserController* tapeBrowserController;
//	
//	if( !dialog_created ) return 0;
//	
//	fuse_emulation_pause();
//	
//	tapeBrowserController = [TapeBrowserController singleton];
//	
//	if( change == UI_TAPE_BROWSER_NEW_TAPE ) {
//		[tapeBrowserController
//		 performSelectorOnMainThread:@selector(clearContents)
//		 withObject:nil
//		 waitUntilDone:NO
//		 ];
//		
//		[tapeBrowserController
//		 performSelectorOnMainThread:@selector(setInitialising:)
//		 withObject:@(YES)
//		 waitUntilDone:NO
//		 ];
//		error = tape_foreach( add_block_details, tapeBrowserController );
//		[tapeBrowserController
//		 performSelectorOnMainThread:@selector(setInitialising:)
//		 withObject:@(NO)
//		 waitUntilDone:NO
//		 ];
//		if( error ) return error;
//	}
//	
//	if( change == UI_TAPE_BROWSER_SELECT_BLOCK ||
//    change == UI_TAPE_BROWSER_NEW_TAPE ) {
//		int current_block = tape_get_current_block();
//		if(current_block >= 0) {
//			[tapeBrowserController
//			 performSelectorOnMainThread:@selector(setTapeIndex:)
//			 withObject:@((unsigned int)current_block)
//			 waitUntilDone:NO
//			 ];
//		}
//	}
//	
//	if( change == UI_TAPE_BROWSER_NEW_BLOCK && block ) {
//		add_block_details( block, tapeBrowserController );
//	}
//	
//	if( tape_modified ) {
//		[[tapeBrowserController window] setDocumentEdited:YES];
//	} else {
//		[[tapeBrowserController window] setDocumentEdited:NO];
//	}
//	
//	fuse_emulation_unpause();
	
	return 0;
}
