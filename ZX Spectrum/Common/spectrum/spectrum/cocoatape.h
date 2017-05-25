//
//  cocoatape.h
//  spectrum
//
//  Created by Tomaz Kragelj on 24.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#ifndef cocoatape_h
#define cocoatape_h

#include <stdio.h>
#include "tape.h"
#include "tape_block.h"

typedef void(*tape_feedback_function_type)(float completionRatio, void *context);

extern void set_tape_feedback_function(void *context, tape_feedback_function_type function);

extern void tape_feedback_reset();

extern void tape_feedback_send(libspectrum_tape_block_state *state);

#endif /* cocoatape_h */
