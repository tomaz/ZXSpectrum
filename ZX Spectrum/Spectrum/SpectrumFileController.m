//
//  Created by Tomaz Kragelj on 15.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import "SpectrumFileController.h"

@interface SpectrumFileInfo (PrivateAPI)
- (void)addBlock:(libspectrum_tape_block)block;
@end

#pragma mark -

@interface SpectrumHardwareInfo (PrivateAPI)
+ (NSArray<SpectrumHardwareInfo *> *)default48KInfos;
+ (NSArray<SpectrumHardwareInfo *> *)default128KInfos;
+ (NSArray<SpectrumHardwareInfo *> *)defaultInfos;
+ (SpectrumHardwareInfo *)infoWithType:(int)type subtype:(int)subtype usage:(SpectrumHardwareUsage)usage;
+ (SpectrumHardwareInfo *)infoWithType:(int)type subtype:(int)subtype usage:(SpectrumHardwareUsage)usage identifier:(NSString *)identifier;
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
	result.file = &file;
	result.tape = tape;
	result.size = [self sizeForFileAtPath:path];
	
	// Prepare default infos.
	result.hardwareInfo = [SpectrumHardwareInfo defaultInfos];
	
	// Collect all interesting info from the file.
	libspectrum_tape_iterator iterator;
	libspectrum_tape_block *block = libspectrum_tape_iterator_init(&iterator, tape);
	while (block) {
		// Get info from block.
		switch (block->type) {
			case LIBSPECTRUM_TAPE_BLOCK_ARCHIVE_INFO: {
				libspectrum_tape_archive_info_block *info = &block->types.archive_info;
				for (size_t i=0; i<info->count; i++) {
					NSString *(^string)() = ^{ return [self stringFromCString:info->strings[i]]; };
					NSArray *(^components)() = ^{ return [self componentsFromCString:info->strings[i]]; };
					
					switch (info->ids[i]) {
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
				
			case LIBSPECTRUM_TAPE_BLOCK_HARDWARE: {
				libspectrum_tape_hardware_block *info = &block->types.hardware;
				NSMutableArray<SpectrumHardwareInfo *> *infos = [result.hardwareInfo mutableCopy];
				
				// Prepare customized hardware infos.
				NSMutableArray *defaultInfosToRemove = [NSMutableArray new];
				for (size_t i=0; i<info->count; i++) {
					int type = info->types[i];
					int subtype = info->ids[i];
					int usage = (SpectrumHardwareUsage)info->values[i];
					
					for (SpectrumHardwareInfo *defaultInfo in result.hardwareInfo) {
						if (defaultInfo.type == type && defaultInfo.subtype == type && defaultInfo.usage != usage) {
							[defaultInfosToRemove addObject:defaultInfo];
						}
					}
					
					[infos addObject:[SpectrumHardwareInfo infoWithType:type subtype:subtype usage:usage]];
				}
				
				// Remove all obsolete default infos.
				[infos removeObjectsInArray:defaultInfosToRemove];
				
				// Assign the array.
				result.hardwareInfo = [infos copy];
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
	
	NSMutableArray *hardwareInfos = [result.hardwareInfo mutableCopy];
	
	// Consolidate various 48K models into single item as long as all are present.
	[self consolidateHardwareInfosInArray:hardwareInfos with:[SpectrumHardwareInfo default48KInfos] replacement:^SpectrumHardwareInfo *{
		return [SpectrumHardwareInfo infoWithType:0x00 subtype:0x01 usage:SpectrumHardwareUsageRuns identifier:NSLocalizedString(@"ZX Spectrum 48K", nil)];
	}];
	
	// Consolidate various 128K models into single item as long as all are present.
	[self consolidateHardwareInfosInArray:hardwareInfos with:[SpectrumHardwareInfo default128KInfos] replacement:^SpectrumHardwareInfo *{
		return [SpectrumHardwareInfo infoWithType:0x00 subtype:0x03 usage:SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures identifier:NSLocalizedString(@"ZX Spectrum 128K", nil)];
	}];
	
	result.hardwareInfo = [hardwareInfos copy];
	
	return result;
}

- (void)consolidateHardwareInfosInArray:(NSMutableArray<SpectrumHardwareInfo *> *)array
								   with:(NSArray<SpectrumHardwareInfo *> *)infos
							replacement:(SpectrumHardwareInfo *(^)(void))replacement {
	// If even single info is missing from array, don't replace.
	for (SpectrumHardwareInfo *model in infos) {
		if (![array containsObject:model]) {
			return;
		}
	}
	
	// Otherwise remove all infos (remember the index of the first).
	NSUInteger index = [array indexOfObject:infos.firstObject];
	for (SpectrumHardwareInfo *model in infos) {
		[array removeObject:model];
	}
	
	// Insert replacement object.
	[array insertObject:replacement() atIndex:index];
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

- (void)dealloc {
	if (self.tape) {
		libspectrum_tape_free(self.tape);
		self.tape = NULL;
	}
}

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

@implementation SpectrumHardwareInfo

+ (SpectrumHardwareInfo *)infoWithType:(int)type subtype:(int)subtype usage:(SpectrumHardwareUsage)usage {
	return [self infoWithType:type subtype:subtype usage:usage identifier:nil];
}

+ (SpectrumHardwareInfo *)infoWithType:(int)type subtype:(int)subtype usage:(SpectrumHardwareUsage)usage identifier:(NSString *)identifier {
	SpectrumHardwareInfo *result = [SpectrumHardwareInfo new];
	result.type = type;
	result.subtype = subtype;
	result.usage = usage;
	result.identifier = identifier;
	return result;
}

- (NSString *)identifier {
	if (_identifier) return _identifier;
	_identifier = [[self class] hardwareStringWithType:self.type subtype:self.subtype];
	return _identifier;
}

- (void)setType:(int)type {
	_type = type;
	_identifier = nil;
}

- (void)setSubtype:(int)subtype {
	_subtype = subtype;
	_identifier = nil;
}

+ (NSArray<SpectrumHardwareInfo *> *)default48KInfos {
	return @[
		// Runs on ZX 48K.
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x01 usage:SpectrumHardwareUsageRuns],
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x02 usage:SpectrumHardwareUsageRuns],
	];
}

+ (NSArray<SpectrumHardwareInfo *> *)default128KInfos {
	return @[
		// Runs on but doesn't use special ZX 128K features.
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x03 usage:SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures],
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x04 usage:SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures],
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x05 usage:SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures],
		[SpectrumHardwareInfo infoWithType:0x00 subtype:0x0E usage:SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures],
	];
}

+ (NSArray<SpectrumHardwareInfo *> *)defaultInfos {
	NSMutableArray *result = [NSMutableArray new];
	
	// Doesn't run on ZX 16K.
	[result addObject:[SpectrumHardwareInfo infoWithType:0x00 subtype:0x00 usage:SpectrumHardwareUsageDoesntRun]];
		
	// Runs on ZX 48K.
	[result addObjectsFromArray:[self default48KInfos]];
	
	// Runs on but doesn't use special ZX 128K features.
	[result addObjectsFromArray:[self default128KInfos]];
	
	return [result copy];
}

+ (NSString *)hardwareStringWithType:(int)type subtype:(int)subtype {
	switch (type) {
		case 0x00:
			switch (subtype) {
				case 0x00: return @"ZX Spectrum 16K";
				case 0x01: return @"ZX Spectrum 48K, Plus";
				case 0x02: return @"ZX Spectrum 48K ISSUE 1";
				case 0x03: return @"ZX Spectrum 128K + (Sinclair)";
				case 0x04: return @"ZX Spectrum 128K +2 (grey case)";
				case 0x05: return @"ZX Spectrum 128K +2A, +3";
				case 0x06: return @"Timex Sinclair TC-2048";
				case 0x07: return @"Timex Sinclair TS-2068";
				case 0x08: return @"Pentagon 128";
				case 0x09: return @"Sam Coupe";
				case 0x0A: return @"Didaktik M";
				case 0x0B: return @"Didaktik Gama";
				case 0x0C: return @"ZX-80";
				case 0x0D: return @"ZX-81";
				case 0x0E: return @"ZX Spectrum 128K, Spanish version";
				case 0x0F: return @"ZX Spectrum, Arabic version";
				case 0x10: return @"Microdigital TK 90-X";
				case 0x11: return @"Microdigital TK 95";
				case 0x12: return @"Byte";
				case 0x13: return @"Elwro 800-3 ";
				case 0x14: return @"ZS Scorpion 256";
				case 0x15: return @"Amstrad CPC 464";
				case 0x16: return @"Amstrad CPC 664";
				case 0x17: return @"Amstrad CPC 6128";
				case 0x18: return @"Amstrad CPC 464+";
				case 0x19: return @"Amstrad CPC 6128+";
				case 0x1A: return @"Jupiter ACE";
				case 0x1B: return @"Enterprise";
				case 0x1C: return @"Commodore 64";
				case 0x1D: return @"Commodore 128";
				case 0x1E: return @"Inves Spectrum+";
				case 0x1F: return @"Profi";
				case 0x20: return @"GrandRomMax";
				case 0x21: return @"Kay 1024";
				case 0x22: return @"Ice Felix HC 91";
				case 0x23: return @"Ice Felix HC 2000";
				case 0x24: return @"Amaterske RADIO Mistrum";
				case 0x25: return @"Quorum 128";
				case 0x26: return @"MicroART ATM";
				case 0x27: return @"MicroART ATM Turbo 2";
				case 0x28: return @"Chrome";
				case 0x29: return @"ZX Badaloc";
				case 0x2A: return @"TS-1500";
				case 0x2B: return @"Lambda";
				case 0x2C: return @"TK-65";
				case 0x2D: return @"ZX-97";
				default: return @"Unknown computer";
			}
			
		case 0x01:
			switch (subtype) {
				case 0x00: return @"ZX Microdrive";
				case 0x01: return @"Opus Discovery";
				case 0x02: return @"MGT Disciple";
				case 0x03: return @"MGT Plus-D";
				case 0x04: return @"Rotronics Wafadrive";
				case 0x05: return @"TR-DOS (BetaDisk)";
				case 0x06: return @"Byte Drive";
				case 0x07: return @"Watsford";
				case 0x08: return @"FIZ";
				case 0x09: return @"Radofin";
				case 0x0A: return @"Didaktik disk drives";
				case 0x0B: return @"BS-DOS (MB-02)";
				case 0x0C: return @"ZX Spectrum +3 disk drive";
				case 0x0D: return @"JLO (Oliger) disk interface";
				case 0x0E: return @"Timex FDD3000";
				case 0x0F: return @"Zebra disk drive";
				case 0x10: return @"Ramex Millenia";
				case 0x11: return @"Larken";
				case 0x12: return @"Kempston disk interface";
				case 0x13: return @"Sandy";
				case 0x14: return @"ZX Spectrum +3e hard disk";
				case 0x15: return @"ZXATASP";
				case 0x16: return @"DivIDE";
				case 0x17: return @"ZXCF";
				default: return @"Unknown external storage";
			}
			
		case 0x02:
			switch (subtype) {
				case 0x00: return @"Sam Ram";
				case 0x01: return @"Multiface ONE";
				case 0x02: return @"Multiface 128K";
				case 0x03: return @"Multiface +3";
				case 0x04: return @"MultiPrint";
				case 0x05: return @"MB-02 ROM/RAM expansion";
				case 0x06: return @"SoftROM";
				case 0x07: return @"1K";
				case 0x08: return @"16K";
				case 0x09: return @"48K";
				case 0x0A: return @"Memory in 8-16K used";
				default: return @"Unknown RAM/ROM addon";
			}
			
		case 0x03:
			switch (subtype) {
				case 0x00: return @"Classic AY hardware (compatible with 128K ZXs)";
				case 0x01: return @"Fuller Box AY sound hardware";
				case 0x02: return @"Currah microSpeech";
				case 0x03: return @"SpecDrum";
				case 0x04: return @"AY ACB stereo (A+C=left, B+C=right); Melodik";
				case 0x05: return @"AY ABC stereo (A+B=left, B+C=right)";
				case 0x06: return @"RAM Music Machine";
				case 0x07: return @"Covox";
				case 0x08: return @"General Sound";
				case 0x09: return @"Intec Electronics Digital Interface B8001";
				case 0x0A: return @"Zon-X AY";
				case 0x0B: return @"QuickSilva AY";
				case 0x0C: return @"Jupiter ACE";
				default: return @"Unknown sound device";
			}
			
		case 0x04:
			switch (subtype) {
				case 0x00: return @"Kempston";
				case 0x01: return @"Cursor, Protek, AGF";
				case 0x02: return @"Sinclair 2 Left (12345)";
				case 0x03: return @"Sinclair 1 Right (67890)";
				case 0x04: return @"Fuller";
				default: return @"Unknown joystick";
			}
			
		case 0x05:
			switch (subtype) {
				case 0x00: return @"AMX mouse";
				case 0x01: return @"Kempston mouse";
				default: return @"Unkown mouse";
			}
			
		case 0x06:
			switch (subtype) {
				case 0x00: return @"Trickstick";
				case 0x01: return @"ZX Light Gun";
				case 0x02: return @"Zebra Graphics Tablet";
				case 0x03: return @"Defender Light Gun";
				default: return @"Unknown controller";
			}
			
		case 0x07:
			switch (subtype) {
				case 0x00: return @"ZX Interface 1";
				case 0x01: return @"ZX Spectrum 128K";
				default: return @"Unknown serial port";
			}
			
		case 0x08:
			switch (subtype) {
				case 0x00: return @"Kempston S";
				case 0x01: return @"Kempston E";
				case 0x02: return @"ZX Spectrum +3";
				case 0x03: return @"Tasman";
				case 0x04: return @"DK'Tronics";
				case 0x05: return @"Hilderbay";
				case 0x06: return @"INES Printerface";
				case 0x07: return @"ZX LPrint Interface 3";
				case 0x08: return @"MultiPrint";
				case 0x09: return @"Opus Discovery";
				case 0x0A: return @"Standard 8255 chip with ports 31,63,95";
				default: return @"Unknown parallel port";
			}
			
		case 0x09:
			switch (subtype) {
				case 0x00: return @"ZX Printer, Alphacom 32 & compatibles";
				case 0x01: return @"Generic printer";
				case 0x02: return @"EPSON compatible";
				default: return @"Unknown printer";
			}
			
		case 0x0A:
			switch (subtype) {
				case 0x00: return @"Prism VTX 5000";
				case 0x01: return @"T/S 2050 or Westridge 2050";
				default: return @"Unknown modem";
			}
			
		case 0x0B:
			switch (subtype) {
				case 0x00: return @"RD Digital Tracer";
				case 0x01: return @"DK'Tronics Light Pen";
				case 0x02: return @"British MicroGraph Pad";
				case 0x03: return @"Romantic Robot Videoface";
				default: return @"Unknown digitizer";
			}
			
		case 0x0C:
			switch (subtype) {
				case 0x00: return @"ZX Interface 1";
				default: return @"Unknown network adapter";
			}
			
		case 0x0D:
			switch (subtype) {
				case 0x00: return @"Keypad for ZX Spectrum 128K";
				default: return @"Unknown keyboard or keypad";
			}
			
		case 0x0E:
			switch (subtype) {
				case 0x00: return @"Harley Systems ADC 8.2";
				case 0x01: return @"Blackboard Electronics";
				default: return @"Unknown AD/DA converter";
			}
			
		case 0x0F:
			switch (subtype) {
				case 0x00: return @"Orme Electronics";
				default: return @"Unknown EEPROM programmer";
			}
			
		case 0x10:
			switch (subtype) {
				case 0x00: return @"WRX Hi-Res";
				case 0x01: return @"G007";
				case 0x02: return @"Memotech";
				case 0x03: return @"Lambda Colour";
				default: return @"Unknown graphics";
			}
			
		default:
			return @"Unknown hardware type";
	}
	
}

- (BOOL)isEqual:(SpectrumHardwareInfo *)object {
	if (object == self) {
		return YES;
	}
	
	if ([object isKindOfClass:[SpectrumHardwareInfo class]]) {
		return
			object.type == self.type &&
			object.subtype == self.subtype &&
			object.usage == self.usage;
	}
	
	return NO;
}

- (NSUInteger)hash {
	return [super hash] ^ self.type ^ self.subtype & self.usage;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%p %@ %@", self, NSStringFromClass([self class]), self.identifier];
}

@end

#pragma mark -

@interface SpectrumFileBlock ()
@property (strong, nonatomic, nullable) NSArray<NSString *> *localizedDetails;
@end

@implementation SpectrumFileBlock

- (void)setBlock:(libspectrum_tape_block)block {
	// When block is assigned, force `localizedDetails` calculation next time it's requested.
	_block = block;
	_localizedDetails = nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %ld %@", super.description, self.index, self.localizedDescription];
 }

- (NSString *)localizedDescription {
	return [self descriptionWithHandler:^(char *buffer, int size) {
		libspectrum_tape_block_description(buffer, size, &self->_block);
	}];
}

- (NSArray<NSString *> *)localizedDetails {
	if (_localizedDetails) return _localizedDetails;
	
	// Prepare text.
	NSString *text = [self descriptionWithHandler:^(char *buffer, int size) {
		tape_block_details(buffer, size, &self->_block);
	}];
	
	// Return all components.
	if (text.length > 0) {
		NSArray *components = [text componentsSeparatedByString:@" "];
		
		// Cleanup all components.
		NSMutableArray *result = [NSMutableArray arrayWithCapacity:components.count];
		for (NSString *component in components) {
			NSString *cleanComponent = component;
			
			if ([cleanComponent hasPrefix:@"\""]) {
				cleanComponent = [cleanComponent substringFromIndex:1];
			}
			
			if ([cleanComponent hasSuffix:@"\""]) {
				cleanComponent = [cleanComponent substringToIndex:cleanComponent.length - 1];
			}
			
			cleanComponent = [cleanComponent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			
			if (cleanComponent.length > 0) {
				[result addObject:cleanComponent];
			}
		}
		
		// If resulting array has some components removed due to trimming, check if we instead need to show more generic representation.
		if (components.count >= 2 && result.count == 1) {
			NSNumber *length = nil;
			
			switch (_block.type) {
				case LIBSPECTRUM_TAPE_BLOCK_ROM:
					length = @(_block.types.rom.length);
					break;
				case LIBSPECTRUM_TAPE_BLOCK_DATA_BLOCK:
					length = @(_block.types.data_block.length);
					break;
				default:
					break;
			}

			if (length != nil) {
				result = [@[[NSString stringWithFormat:@"%@", length], @"bytes"] mutableCopy];
			}
		}
		
		// Assign details.
		_localizedDetails = [result copy];
	}
	
	return _localizedDetails;
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
