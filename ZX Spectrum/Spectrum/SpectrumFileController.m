//
//  Created by Tomaz Kragelj on 15.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#include "libspectrum.h"
#include "tape_block.h"
#include "tape.h"
#include "utils.h"
#import "SpectrumFileController.h"

@interface SpectrumFileInfo (PrivateAPI)
- (void)addBlock:(libspectrum_tape_block)block;
@end

#pragma mark -

@implementation SpectrumFileController

- (SpectrumFileInfo *)informationForFileAtPath:(NSString *)path error:(NSError **)error {
	const char *filename = path.UTF8String;
	
	int fuse_error;
	libspectrum_error libspectrum_error;
	
	// Open file.
	utils_file file;
	fuse_error = utils_read_file(filename, &file);
	if (fuse_error) {
		if (error) *error = [self errorWithCode:-9000 description:NSLocalizedString(@"Failed reading file.", nil)];
		return nil;
	}
	
	// Get info from the file.
	libspectrum_tape *tape = libspectrum_tape_alloc();
	libspectrum_error = libspectrum_tape_read(tape, file.buffer, file.length, LIBSPECTRUM_ID_UNKNOWN, filename);
	if (libspectrum_error != LIBSPECTRUM_ERROR_NONE) {
		libspectrum_tape_free(tape);
		utils_close_file(&file);
		if (error) *error = [self errorWithCode:-9010 description:NSLocalizedString(@"Failed reading info from file.", nil)];
		return nil;
	}

	// Prepare file and determine general info.
	SpectrumFileInfo *result = [SpectrumFileInfo new];
	result.size = [self sizeForFileAtPath:path];

	// Collect all interesting info from the file.
	libspectrum_tape_iterator iterator;
	libspectrum_tape_block *block = libspectrum_tape_iterator_init(&iterator, tape);
	while (block) {
		// Get info from block.
		switch (block->type) {
			case LIBSPECTRUM_TAPE_BLOCK_ARCHIVE_INFO: {
				for (size_t i=0; i<block->types.archive_info.count; i++) {
					NSString *(^string)() = ^{ return [self stringFromCString:block->types.archive_info.strings[i]]; };
					NSArray *(^components)() = ^{ return [self componentsFromCString:block->types.archive_info.strings[i]]; };
					
					switch (block->types.archive_info.ids[i]) {
						case 0x01: result.publisher = string(); break;
						case 0x02: result.authors = components(); break;
						case 0x03: result.year = string(); break;
						case 0x04: result.language = string(); break;
						case 0x05: result.type = string(); break;
						case 0x06: result.price = string(); break;
						case 0x07: result.loader = string(); break;
						case 0x08: result.origin = string(); break;
						default: break;
					}
				}
			} break;
				
			case LIBSPECTRUM_TAPE_BLOCK_COMMENT: {
				result.comment = [self stringFromCString:block->types.comment.text];
			} break;
				
			default: {
			} break;
		}

		// Add the block.
		[result addBlock:*block];

		// Proceed with next block.
		block = libspectrum_tape_iterator_next(&iterator);
	}

	libspectrum_tape_free(tape);
	utils_close_file(&file);
	
	return result;
}

- (NSUInteger)sizeForFileAtPath:(NSString *)path {
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return [attributes[NSFileSize] unsignedIntegerValue];
}

- (NSString *)stringFromCString:(char *)string {
	NSArray *components = [self componentsFromCString:string];
	NSString *result = [components componentsJoinedByString:@", "];
	return result.length > 0 ? result : nil;
}

- (NSArray *)componentsFromCString:(char *)string {
	NSString *result = [NSString stringWithUTF8String:string];

	// Get components and trim whitespace from each one.
	NSArray *components = [result componentsSeparatedByString:@","];
	NSMutableArray *cleanComponents = [NSMutableArray arrayWithCapacity:components.count];
	for (NSString *component in components) {
		NSArray *subcomponents = [component componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		for (NSString *subcomponent in subcomponents) {
			NSString *cleanComponent = subcomponent;
			cleanComponent = [cleanComponent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			cleanComponent = [cleanComponent stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			if (cleanComponent.length > 0) {
				[cleanComponents addObject:cleanComponent];
			}
		}
	}

	// Return all components.
	return cleanComponents;
}

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
	return [NSError errorWithDomain:@"com.gentlebytes.ZXSpectrum.File" code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}

@end

#pragma mark -

@interface SpectrumFileInfo ()
@property (nonatomic, strong) NSMutableArray <SpectrumFileBlock *> *blocksValue;
@end

@implementation SpectrumFileInfo

- (void)addBlock:(libspectrum_tape_block)block {
	SpectrumFileBlock *blockObject = [SpectrumFileBlock new];
	blockObject.block = block;
	blockObject.index = self.blocksValue.count;
	[self.blocksValue addObject:blockObject];
}

- (NSArray *)blocks {
	return _blocksValue;
}

- (NSMutableArray *)blocksValue {
	if (_blocksValue) return _blocksValue;
	_blocksValue = [NSMutableArray new];
	return _blocksValue;
}

@end

#pragma mark -

@implementation SpectrumFileBlock

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %ld %@", super.description, self.index, self.localizedDescription];
 }

- (NSString *)localizedDescription {
	return [self descriptionWithHandler:^(char *buffer, int size) {
		libspectrum_tape_block_description(buffer, size, &self->_block);
	}];
}

- (NSArray *)localizedDetails {
	// Prepare text.
	NSString *text = [self descriptionWithHandler:^(char *buffer, int size) {
		tape_block_details(buffer, size, &self->_block);
	}];
	
	// Return all components.
	if (text.length > 0) {
		return [text componentsSeparatedByString:@" "];
	}
	
	// Return nil if there's no text.
	return nil;
}

- (NSString *)descriptionWithHandler:(void(^)(char *buffer, int size))handler {
	static int length = 256;
	char buffer[length];
	handler(buffer, length);
	return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}

- (BOOL)isDataBlock {
	switch (self.block.type) {
		case LIBSPECTRUM_TAPE_BLOCK_ROM:
		case LIBSPECTRUM_TAPE_BLOCK_TURBO:
		case LIBSPECTRUM_TAPE_BLOCK_PURE_TONE:
		case LIBSPECTRUM_TAPE_BLOCK_PULSES:
		case LIBSPECTRUM_TAPE_BLOCK_PURE_DATA:
		case LIBSPECTRUM_TAPE_BLOCK_RAW_DATA:
			return true;
		default:
			return false;
	}
}

@end
