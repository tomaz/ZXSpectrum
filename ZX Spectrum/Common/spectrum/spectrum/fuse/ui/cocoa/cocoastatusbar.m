/* cocoastatusbar.m: Routines for dealing with Cocoa status feedback
   Copyright (c) 2007 Fredrick Meunier

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

#include "config.h"

//#import "DisplayOpenGLView.h"
#import "FuseController.h"

#include "cocoadisplay.h"
#include "settings.h"
#include "ui.h"

/* The statusbar handling function */
int
ui_statusbar_update( ui_statusbar_item item, ui_statusbar_state state )
{
  FuseController *controller = [FuseController sharedInstance];
  if (controller.statusBarDidUpdate) {
    controller.statusBarDidUpdate(item, state);
  }
  return 0;
}
