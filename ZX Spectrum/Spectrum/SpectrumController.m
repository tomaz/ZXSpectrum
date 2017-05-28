//
//  Created by Tomaz Kragelj on 20.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "BridgingHeader.h"
#import "SpectrumController.h"

@implementation SpectrumController

- (void)setSelectedMachineType:(libspectrum_machine)value {
	for (int i=0; i<machine_count; i++) {
		if (machine_types[i]->machine == value) {
			machine_select_id(machine_types[i]->id);
		}
	}
}
- (libspectrum_machine)selectedMachineType {
	Machine *machine = self.selectedMachine;
	if (machine) {
		return machine.type;
	}
	return LIBSPECTRUM_MACHINE_UNKNOWN;
}

- (void)setSelectedMachine:(Machine *)value {
	for (int i=0; i<machine_count; i++) {
		if (machine_types[i]->machine == value.type) {
			machine_select_id(machine_types[i]->id);
		}
	}
}
- (Machine *)selectedMachine {
	for (int i=0; i<machine_count; i++) {
		if (strcmp(machine_types[i]->id, settings_current.start_machine) == 0) {
			return [Machine machineForType:machine_types[i]->machine];
		}
	}
	return nil;
}

- (NSString * _Nonnull)identifierForMachine:(Machine * _Nonnull)machine {
	return [self identifierForRawValue:machine_get_id(machine.type)];
}

- (NSString * _Nonnull)identifierForRawValue:(const char *)value {
	return [NSString stringWithCString:value encoding:NSASCIIStringEncoding];
}

@end
