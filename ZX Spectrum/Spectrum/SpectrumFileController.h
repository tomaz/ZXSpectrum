//
//  Created by Tomaz Kragelj on 15.05.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpectrumFileInfo;
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

/// Returns array of data blocks.
@property (nonatomic, readonly, nonnull) NSArray <SpectrumFileBlock *> *blocks;

@end

#pragma mark - 

@interface SpectrumFileBlock : NSObject

/// The underlying block
@property (nonatomic, assign) libspectrum_tape_block block;

@end
