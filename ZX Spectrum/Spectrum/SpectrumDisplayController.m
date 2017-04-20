//
//  Created by Tomaz Kragelj on 10.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "BridgingHeader.h"
#import "ZX_Spectrum-Swift.h"
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
#define BYTES_PER_COLOR 4

static uint32_t palette[16];
static uint32_t imageWidth;
static uint32_t imageHeight;
static uint8_t *imageData;

static BOOL displayUpdated;

static CGColorSpaceRef colorSpace;

int controller_display_init_function(int width, int height, void *context) {
	SpectrumPalette *pal = SpectrumPalette.colored;
	for (int i=0; i<16; i++) {
		palette[i] = [pal rawColorAtIndex:i];
	}

	imageWidth = width;
	imageHeight = height;
	
	imageData = malloc(width * height * BYTES_PER_COLOR);
	memset(imageData, 0, imageWidth * imageHeight * BYTES_PER_COLOR);
	
	displayUpdated = NO;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	return 0;
}

int controller_display_hotswap_gfx_mode_function(void *context) {
	return 1;
}

void controller_display_putpixel_function(int x, int y, int colour, void *context) {
	uint32_t raw = palette[colour];
	uint32_t *base = (uint32_t *)imageData;

	if (machine_current->timex) {
		x <<= 1;
		y <<= 1;
		
		uint32_t *buffer = &base[y * imageWidth + x];
		
		*(buffer++) = raw;
		*(buffer++) = raw;
		
	} else {
		uint32_t *buffer = &base[y * imageWidth + x];
		
		*(buffer++) = raw;
	}
}

void controller_display_plot8_function(int x, int y, libspectrum_byte data, libspectrum_byte ink, libspectrum_byte paper, void *context) {
	uint32_t inkRaw = palette[ink];
	uint32_t paperRaw = palette[paper];

	uint32_t *base = (uint32_t *)imageData;

	if (machine_current->timex) {
		x <<= 4;
		y <<= 1;
		
		uint32_t *buffer = &base[y * imageWidth + x];

		*(buffer++) = (data & 0x80) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x80) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x40) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x40) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x20) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x20) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x10) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x10) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x08) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x08) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x04) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x04) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x02) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x02) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x01) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x01) > 0 ? inkRaw : paperRaw;
	} else {
		x <<= 3;
		
		uint32_t *buffer = &base[y * imageWidth + x];

		*(buffer++) = (data & 0x80) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x40) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x20) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x10) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x08) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x04) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x02) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x01) > 0 ? inkRaw : paperRaw;
	}
}

void controller_display_plot16_function(int x, int y, libspectrum_word data, libspectrum_byte ink, libspectrum_byte paper, void *context) {
	if (machine_current->timex) {
		x <<= 4;
		y <<= 1;
	}
	
	uint32_t inkRaw = palette[ink];
	uint32_t paperRaw = palette[paper];
	
	uint32_t *base = (uint32_t *)imageData;
	uint32_t *buffer = &base[y * imageWidth + x];
	
	for (int i=0; i<2; i++) {
		*(buffer++) = (data & 0x8000) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x4000) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x2000) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x1000) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0800) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0400) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0200) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0100) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0080) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0040) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0020) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0010) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0008) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0004) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0002) > 0 ? inkRaw : paperRaw;
		*(buffer++) = (data & 0x0001) > 0 ? inkRaw : paperRaw;
	}
}

void controller_display_area_function(int x, int y, int width, int height, void *context) {
	displayUpdated = YES;
}

void controller_display_frame_end_function(void *context) {
	if (displayUpdated) {
		CGContextRef bitmapContext = CGBitmapContextCreate(
			imageData,
			imageWidth,
			imageHeight,
			8,
			imageWidth * BYTES_PER_COLOR,
			colorSpace,
			kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Little);
		
		if (context) {
			CGImageRef cgi = CGBitmapContextCreateImage(bitmapContext);
			if (cgi) {
				UIImage *image = [UIImage imageWithCGImage:cgi scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
				
				CGImageRelease(cgi);
				
				SpectrumDisplayController *controller = CONTROLLER;
				[controller.handler spectrumDisplayController:controller renderImage:image];
			}
			
			CGContextRelease(bitmapContext);
		}

		displayUpdated = NO;
	}
}

void controller_display_end_function(void *context) {
	// Nothing to do here...
}
