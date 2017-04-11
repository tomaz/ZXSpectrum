//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "BridgingHeader.h"
#import "SpectrumInputController.h"

@implementation SpectrumInputController

- (void)inject:(char)key {
	input_key simulated = key;
	
	switch (key) {
		case '\n': simulated = INPUT_KEY_Return; break;
	}
	
	// First key press.
	input_event_t event;
	event.type = INPUT_EVENT_KEYPRESS;
	event.types.key.spectrum_key = simulated;
	input_event(&event);
	
	// Then key release.
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		input_event_t release;
		release.type = INPUT_EVENT_KEYRELEASE;
		release.types.key.spectrum_key = simulated;
		input_event(&release);
	});
}

@end
