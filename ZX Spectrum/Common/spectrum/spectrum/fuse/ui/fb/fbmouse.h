/* fbmouse.h: Linux mouse handling code (requires kernel input layer)
   Copyright (c) 2004 Darren Salt

   $Id: fbmouse.h 804 2016-06-01 10:46:07Z fredm $

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

   E-mail: linux@youmustbejoking.demon.co.uk

*/

#ifndef FUSE_FBMOUSE_H
#define FUSE_FBMOUSE_H

int fbmouse_init(void);
int fbmouse_end(void);
void mouse_update(void);

#endif			/* #ifndef FUSE_FBMOUSE_H */
