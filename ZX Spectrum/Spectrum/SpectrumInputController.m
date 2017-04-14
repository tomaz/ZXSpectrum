//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "BridgingHeader.h"
#import "SpectrumInputController.h"

@implementation SpectrumInputController

- (void)inject:(input_key)key pressed:(BOOL)pressed {
	input_event_t event;
	event.type = pressed ? INPUT_EVENT_KEYPRESS : INPUT_EVENT_KEYRELEASE;
	event.types.key.spectrum_key = key;
	input_event(&event);
}

@end
