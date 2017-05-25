//
//  cocoatape.c
//  spectrum
//
//  Created by Tomaz Kragelj on 24.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "cocoatape.h"

tape_feedback_function_type tape_feedback_function = NULL;
void *tape_feedback_context = NULL;

size_t previousRemainingBytes = -1;
size_t previousCompletionPercent = 0;

void set_tape_feedback_function(void *context, tape_feedback_function_type function) {
  tape_feedback_function = function;
  tape_feedback_context = context;
}

void tape_feedback_reset() {
  previousRemainingBytes = -1;
  previousCompletionPercent = 0;
}

void tape_feedback_send(libspectrum_tape_block_state *state) {
  libspectrum_tape_block *block = libspectrum_tape_iterator_current(state->current_block);
  
  size_t blockBytes = 0;
  size_t completedBytes = 0;
  
  switch (block->type) {
    case LIBSPECTRUM_TAPE_BLOCK_ROM:
      blockBytes = block->types.rom.length;
      completedBytes = state->block_state.rom.bytes_through_block;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_PURE_TONE:
      blockBytes = block->types.pure_tone.length;
      completedBytes = state->block_state.pure_tone.edge_count;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_PULSES:
      blockBytes = block->types.pulses.count;
      completedBytes = state->block_state.pulses.edge_count;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_PURE_DATA:
      blockBytes = block->types.pure_data.length;
      completedBytes = state->block_state.pure_data.bytes_through_block;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_RAW_DATA:
      blockBytes = block->types.raw_data.length;
      completedBytes = state->block_state.raw_data.bytes_through_block;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_GENERALISED_DATA:
      blockBytes = block->types.generalised_data.data_table.max_pulses;
      completedBytes = state->block_state.generalised_data.bytes_through_stream;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_RLE_PULSE:
      blockBytes = block->types.rle_pulse.length;
      completedBytes = state->block_state.rle_pulse.index;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_PULSE_SEQUENCE:
      blockBytes = block->types.pulse_sequence.count;
      completedBytes = state->block_state.pulse_sequence.pulse_count;
      break;
		case LIBSPECTRUM_TAPE_BLOCK_DATA_BLOCK:
      blockBytes = block->types.data_block.count;
      completedBytes = state->block_state.data_block.bytes_through_block;
      break;
		default:
      return;
  }
  
  // Sometimes completed bytes is negative, treat it as 0 completion.
  if ((int)completedBytes == -1) {
    completedBytes = 0;
  }
  
  // Calculate remaining bytes - don't allow negatives or dropping below previously reported value.
  size_t remainingBytes = blockBytes - completedBytes;
  if (blockBytes < completedBytes) {
    remainingBytes = 0;
  } else if (remainingBytes > previousRemainingBytes) {
    remainingBytes = previousRemainingBytes;
  } else if (remainingBytes > blockBytes) {
    remainingBytes = blockBytes;
  }
  
  // Calculate percent completed. If it doesn't change from before, ignore.
  size_t completionPercent = 100 * remainingBytes / blockBytes;
  if (completionPercent == previousCompletionPercent) {
    return;
  }
  
  // Remember and report change.
  previousRemainingBytes = remainingBytes;
  previousCompletionPercent = completionPercent;
  tape_feedback_function(1.0f - ((float)previousCompletionPercent / 100.0f), tape_feedback_context);
}
