/* cocoadisplay.h: Routines for dealing with the Cocoa display
   Copyright (c) 2000-2003 Philip Kendall, Fredrick Meunier

   $Id$

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

   Author contact information:

   E-mail: philip-fuse@shadowmagic.org.uk

*/

#ifndef FUSE_COCOADISPLAY_H
#define FUSE_COCOADISPLAY_H

#import <Foundation/NSLock.h>

#include "ui.h"
#include "dirty.h"

typedef struct Cocoa_Texture {
  void *pixels;
  PIG_dirtytable *dirty;
  int full_height;
  int full_width;
  int image_height;
  int image_width;
  int image_xoffset;
  int image_yoffset;
  int pitch;
} Cocoa_Texture;

/* Screen texture */
extern Cocoa_Texture* screen;

extern NSLock *buffered_screen_lock;
extern Cocoa_Texture buffered_screen;

void copy_area( Cocoa_Texture *dest_screen, Cocoa_Texture *src_screen, PIG_rect *r );

typedef int(*display_init_function_type)(int width, int height, void *context);
typedef int(*display_hotswap_gfx_mode_function_type)(void *context);
typedef void(*display_putpixel_function_type)(int x, int y, int colour, void *context);
typedef void(*display_plot8_function_type)(int x, int y, libspectrum_byte data, libspectrum_byte ink, libspectrum_byte paper, void *context);
typedef void(*display_plot16_function_type)(int x, int y, libspectrum_word data, libspectrum_byte ink, libspectrum_byte paper, void *context);
typedef void(*display_area_function_type)(int x, int y, int width, int height, void *context);
typedef void(*display_frame_end_function_type)(void *context);
typedef void(*display_end_function_type)(void *context);

void set_display_init_function(void *context, display_init_function_type function);
void set_display_hotswap_gfx_mode_function(void *context, display_hotswap_gfx_mode_function_type function);
void set_display_putpixel_function(void *context, display_putpixel_function_type function);
void set_display_plot8_function(void *context, display_plot8_function_type function);
void set_display_plot16_function(void *context, display_plot16_function_type function);
void set_display_area_function(void *context, display_area_function_type function);
void set_display_frame_end_function(void *context, display_frame_end_function_type function);
void set_display_end_function(void *context, display_end_function_type function);

#endif			/* #ifndef FUSE_COCOADISPLAY_H */
