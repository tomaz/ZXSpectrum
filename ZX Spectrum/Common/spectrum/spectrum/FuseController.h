//
//  FuseController.h
//  spectrum
//
//  Created by Tomaz Kragelj on 6.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libspectrum.h"
#include "tape.h"
#include "ui.h"

@interface FuseController : NSObject

/// The singleton instance.
+ (instancetype _Nonnull)sharedInstance;

/// Called after emulation speed updates.
@property (copy, nonatomic, nullable) void(^emulationSpeedDidUpdate)(float speed);

/// Called when status bar needs updating.
@property (copy, nonatomic, nullable) void(^statusBarDidUpdate)(ui_statusbar_item item, ui_statusbar_state state);

/// Called when tape browser needs updating.
@property (copy, nonatomic, nullable) void(^tapeBrowserDidUpdate)(ui_tape_browser_update_type type, libspectrum_tape_block * _Nullable block);

/// Called when tape status changes.
@property (copy, nonatomic, nullable) void(^tapeBlockStateDidChange)(float remainingRatio);

@end
