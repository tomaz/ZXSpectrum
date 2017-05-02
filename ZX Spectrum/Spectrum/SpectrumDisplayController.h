//
//  Created by Tomaz Kragelj on 10.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpectrumDisplayHandler;

/**
 Middleware between underlying display C API and higher level Objective-C and especially Swift APIs.
 
 The main reasoning behind this class is to simplify Swift implementation which can be quite messy with unsafe pointer calls. Objective-C can access C APIs without any complications on the other hand.
 
 Note: there can only be single handler at the time for simplicity and performance reasons.
 */
@interface SpectrumDisplayController : NSObject

/**
 The handler that will receive all the requests. Assign nil to stop receving events.
 */
@property (weak, nonatomic, nullable) id<SpectrumDisplayHandler> handler;

@end

#pragma mark - 

/**
 Requirements for display handler.
 */
@protocol SpectrumDisplayHandler

/**
 Called when new image is prepared and should be rendered to screen.
 */
- (void)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller renderImage:(UIImage * _Nonnull)image;

@end
