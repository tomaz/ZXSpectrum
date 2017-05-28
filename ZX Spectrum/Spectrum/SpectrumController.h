//
//  Created by Tomaz Kragelj on 20.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libspectrum.h"

@class Machine;

/**
 Middleware between fuse API and Swift code.
*/
@interface SpectrumController : NSObject

/// Returns or sets currently selected machine type. If no machine is selected, or selection cannot be determined, `LIBSPECTRUM_MACHINE_UNKNOWN` is used.
@property (assign, nonatomic) libspectrum_machine selectedMachineType;

/// Returns or sets currently selected machine. If no machine is selected, or selection cannot be determined, nil is returned.
@property (weak, nonatomic, nullable) Machine *selectedMachine;

/**
 Returns the ID for the given machine.
*/
- (NSString * _Nonnull)identifierForMachine:(Machine * _Nonnull)machine;

/**
 Returns the ID for the given machine raw value.
 */
- (NSString * _Nonnull)identifierForRawValue:(const char * _Nonnull)value;

@end
