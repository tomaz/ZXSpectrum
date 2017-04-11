//
//  Created by Tomaz Kragelj on 10.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "BridgingHeader.h"
#import "SpectrumDisplayController.h"

int controller_display_init_function(int width, int height, void *context);
int controller_display_hotswap_gfx_mode_function(void *context);
void controller_display_putpixel_function(int x, int y, int colour, void *context);
void controller_display_plot8_function(int x, int y, libspectrum_byte data, libspectrum_byte ink, libspectrum_byte paper, void *context);
void controller_display_plot16_function(int x, int y, libspectrum_word data, libspectrum_byte ink, libspectrum_byte paper, void *context);
void controller_display_area_function(int x, int y, int width, int height, void *context);
void controller_display_frame_end_function(void *context);
void controller_display_end_function(void *context);

#pragma mark -

@implementation SpectrumDisplayController

- (void)setHandler:(id<SpectrumDisplayHandler>)handler {
	[self unhookHandler:_handler];
	_handler = handler;
	[self hookHandler:_handler];
}

- (void)hookHandler:(id<SpectrumDisplayHandler>)handler {
	if (!handler) {
		return;
	}

	set_display_init_function((__bridge void *)(self), controller_display_init_function);
	set_display_hotswap_gfx_mode_function((__bridge void *)(self), controller_display_hotswap_gfx_mode_function);
	set_display_putpixel_function((__bridge void *)(self), controller_display_putpixel_function);
	set_display_plot8_function((__bridge void *)(self), controller_display_plot8_function);
	set_display_plot16_function((__bridge void *)(self), controller_display_plot16_function);
	set_display_area_function((__bridge void *)(self), controller_display_area_function);
	set_display_frame_end_function((__bridge void *)(self), controller_display_frame_end_function);
	set_display_end_function((__bridge void *)(self), controller_display_end_function);
}

- (void)unhookHandler:(id<SpectrumDisplayHandler>)handler {
	if (!handler) {
		return;
	}
	
	set_display_init_function(nil, nil);
	set_display_hotswap_gfx_mode_function(nil, nil);
	set_display_putpixel_function(nil, nil);
	set_display_plot8_function(nil, nil);
	set_display_plot16_function(nil, nil);
	set_display_area_function(nil, nil);
	set_display_frame_end_function(nil, nil);
	set_display_end_function(nil, nil);
}

@end

#pragma mark - 

#define CONTROLLER (__bridge SpectrumDisplayController *)context
#define SCALE (machine_current->timex ? 2.0 : 1.0)

int controller_display_init_function(int width, int height, void *context) {
	SpectrumDisplayController *controller = CONTROLLER;
	return [controller.handler spectrumDisplayController:controller initSize:CGSizeMake(width, height)] ? 0 : 1;
}

int controller_display_hotswap_gfx_mode_function(void *context) {
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayControllerSwapGraphicsMode:controller];
	return 1;
}

void controller_display_putpixel_function(int x, int y, int colour, void *context) {
	CGFloat scale = SCALE;
	if (scale == 2) {
		x <<= 1;
		y <<= 1;
	}
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayController:controller drawPixelAt:CGPointMake(x, y) scale:scale color:colour];
}

void controller_display_plot8_function(int x, int y, libspectrum_byte data, libspectrum_byte ink, libspectrum_byte paper, void *context) {
	CGFloat scale = SCALE;
	if (scale == 2) {
		x <<= 4;
		y <<= 1;
	} else {
		x <<= 3;
	}
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayController:controller draw8PixelsAt:CGPointMake(x, y) scale:scale data:data ink:ink paper:paper];
}

void controller_display_plot16_function(int x, int y, libspectrum_word data, libspectrum_byte ink, libspectrum_byte paper, void *context) {
	CGFloat scale = SCALE;
	if (scale == 2) {
		x <<= 4;
		y <<= 1;
	}
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayController:controller draw16PixelsAt:CGPointMake(x, y) scale:scale data:data ink:ink paper:paper];
}

void controller_display_area_function(int x, int y, int width, int height, void *context) {
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayController:controller updateDisplayAt:CGRectMake(x, y, width, height)];
}

void controller_display_frame_end_function(void *context) {
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayControllerEndFrame:controller];
}

void controller_display_end_function(void *context) {
	SpectrumDisplayController *controller = CONTROLLER;
	[controller.handler spectrumDisplayControllerEndDisplay:controller];
}
