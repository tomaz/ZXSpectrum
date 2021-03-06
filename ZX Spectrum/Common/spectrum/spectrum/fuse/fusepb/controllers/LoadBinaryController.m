/* LoadBinaryController.m: Routines for dealing with the Load Binary Panel
   Copyright (c) 2003 Fredrick Meunier

   $Id: LoadBinaryController.m,v 1.1 2005/04/18 02:55:20 fred Exp $

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

   Author contact information:

   E-mail: pak21-fuse@srcf.ucam.org
   Postal address: 15 Crescent Road, Wokingham, Berks, RG40 2DB, England

*/

#include <config.h>

#import "LoadBinaryController.h"
#import "DisplayOpenGLView.h"
#import "NumberFormatter.h"

#include "memory.h"
#include "spectrum.h"
#include <libspectrum.h>
#include "ui/ui.h"
#include "utils.h"

static utils_file u_file;

@implementation LoadBinaryController

- (id)init
{
  self = [super initWithWindowNibName:@"LoadBinary"];

  [self setWindowFrameAutosaveName:@"LoadBinaryWindow"];

  return self;
}

- (void)awakeFromNib
{
  NumberFormatter *startFormatter = [[NumberFormatter alloc] init];
  NumberFormatter *lengthFormatter = [[NumberFormatter alloc] init];
  
  [startFormatter setMinimum:[NSDecimalNumber zero]];
  [startFormatter setFormat:@"0"];
  [start setFormatter:startFormatter];
  
  [lengthFormatter setMinimum:[NSDecimalNumber one]];
  [lengthFormatter setFormat:@"0"];
  [length setFormatter:lengthFormatter];
  
  // The formatter is retained by the text field
  [startFormatter release];
  [lengthFormatter release];
}

- (IBAction)apply:(id)sender
{
  libspectrum_word s, len; size_t i;

  len = [length intValue];

  if( len > u_file.length ) {
    ui_error( UI_ERROR_ERROR,
              "'%s' contains only %lu bytes",
              [[file stringValue] UTF8String], (unsigned long)u_file.length );
    return;
  }

  s = [start intValue];

  for( i = 0; i < len; i++ )
    writebyte( s + i, u_file.buffer[ i ] );

  [self cancel:self];
}

- (IBAction)cancel:(id)sender
{
  [NSApp stopModal];
  [[self window] close];
  
  [[DisplayOpenGLView instance] unpause];
}

- (void)showWindow:(id)sender
{
  [[DisplayOpenGLView instance] pause];
  
  [super showWindow:sender];

  [file setStringValue:@""];
  [start setStringValue:@""];
  [length setStringValue:@""];
  
  [apply setEnabled:NO];

  [NSApp runModalForWindow:[self window]];
}

- (IBAction)chooseFile:(id)sender
{
  int result;
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];

  [oPanel setAllowedFileTypes:nil];

  result = [oPanel runModal];
  if (result == NSOKButton) {
    char buffer[PATH_MAX+1];
    int error;
    NSString *oFile = [[oPanel URL] path];

    utils_file new_file;

    [oFile getFileSystemRepresentation:buffer maxLength:PATH_MAX];

    error = utils_read_file( buffer, &new_file );
    if( error ) { return; }

    utils_close_file( &u_file );

    u_file = new_file;

    [file setStringValue:@(buffer)];

    [start setIntValue:0];
    [length setIntValue:new_file.length];
    
    [apply setEnabled:YES];
  }
}

- (void)controlTextDidChange:(NSNotification *)notification
{
  if (([[file stringValue] length] == 0) ||
      ([[start stringValue] length] == 0) ||
      ([[length stringValue] length] == 0)) {
    [apply setEnabled:NO];
    return;
  }
  
  if (([start intValue] < 0 || [start intValue] > 65535) ||
       ([length intValue] < 1 || [length intValue] > 65536)) {
    [apply setEnabled:NO];
    return;
  }

  [apply setEnabled:YES];
}

@end
