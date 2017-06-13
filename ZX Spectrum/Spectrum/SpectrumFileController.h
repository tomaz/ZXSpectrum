//
//  Created by Tomaz Kragelj on 15.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "libspectrum.h"
#include "tape_block.h"
#include "tape.h"
#include "utils.h"

@class SpectrumFileInfo;
@class SpectrumHardwareInfo;
@class SpectrumFileBlock;

/**
 Provides information about a file.
 */
@interface SpectrumFileController : NSObject

/**
 Reads information about the given file.
 */
- (SpectrumFileInfo * _Nullable)informationForFileAtPath:(NSString * _Nonnull)path error:(NSError * _Nullable * _Nullable)error;

@end

#pragma mark - 

/**
 Information about the file.
 */
@interface SpectrumFileInfo : NSObject

/// Underlying file.
@property (nonatomic, assign) utils_file  * _Nullable file;

/// Underlying tape.
@property (nonatomic, assign) libspectrum_tape * _Nullable tape;

/// Size of the file in bytes.
@property (assign, nonatomic) NSInteger size;

/// File author(s).
@property (strong, nonatomic, nullable) NSArray <NSString *> *authors;

/// File software house / publisher.
@property (copy, nonatomic, nullable) NSString *publisher;

/// File release year.
@property (copy, nonatomic, nullable) NSString *year;

/// File language.
@property (copy, nonatomic, nullable) NSString *language;

/// File type.
@property (copy, nonatomic, nullable) NSString *type;

/// File original price.
@property (copy, nonatomic, nullable) NSString *price;

/// File protection scheme / loader.
@property (copy, nonatomic, nullable) NSString *loader;

/// File origin.
@property (copy, nonatomic, nullable) NSString *origin;

/// File comment.
@property (copy, nonatomic, nullable) NSString *comment;

/// Hardware info.
@property (strong, nonatomic, nonnull) NSArray<SpectrumHardwareInfo *> *hardwareInfo;

/// Returns array of data blocks.
@property (nonatomic, readonly, nonnull) NSArray<SpectrumFileBlock *> *blocks;

@end

#pragma mark -

typedef NS_ENUM(NSUInteger, SpectrumHardwareUsage) {
	SpectrumHardwareUsageRuns,
	SpectrumHardwareUsageUsesSpecialFeatures,
	SpectrumHardwareUsageRunsButDoesntUseSpecialFeatures,
	SpectrumHardwareUsageDoesntRun,
};

@interface SpectrumHardwareInfo : NSObject

/// Underlying hardware type.
@property (assign, nonatomic) int type;

/// Underyling hardware subtype.
@property (assign, nonatomic) int subtype;

/// Hardware usage info.
@property (assign, nonatomic) SpectrumHardwareUsage usage;

/// Hardware identifier string.
@property (copy, nonatomic, nonnull) NSString *identifier;

@end

#pragma mark - 

@interface SpectrumFileBlock : NSObject

/// Block index within the tape.
@property (assign, nonatomic) NSInteger index;

/// The underlying block
@property (assign, nonatomic) libspectrum_tape_block block;

/// Specifies whether the block is data block or not.
@property (readonly, nonatomic) BOOL isDataBlock;

/// Description suitable for displaying to the user.
@property (readonly, nonatomic, nonnull) NSString *localizedDescription;

/// Details suitable for displaying to the user.
@property (readonly, nonatomic, nullable) NSArray<NSString *> *localizedDetails;

@end

