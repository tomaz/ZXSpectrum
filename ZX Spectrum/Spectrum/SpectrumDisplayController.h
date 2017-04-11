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
@property (assign, nonatomic, nullable) id<SpectrumDisplayHandler> handler;

@end

#pragma mark - 

/**
 Requirements for display handler.
 */
@protocol SpectrumDisplayHandler

/**
 Initializes screen for the given size.
 
 @param controller Controller that requested initialization.
 @param size Size of the screen to initialize.
 */
- (BOOL)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller
						 initSize:(CGSize)size;

/**
 Called when single pixels needs to be drawn at the gixen coordinate.
 
 If scale is 2, 2 pixels need to be drawn where each bit represent a pair of screen pixels. If scale is 1, single pixel needs drawing.

 Typically drawing happens on offscreen surface.
 
 @param controller Controller that requested drawing.
 @param point Coordinate of the pixel
 @param scale Computer scale (either 1 or 2).
 @param color Color index within current palette.
 */
- (void)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller
					  drawPixelAt:(CGPoint)point
							scale:(CGFloat)scale
							color:(NSInteger)color;

/**
 Called when 8 pixels need to be drawn starting at the gixen coordinate.
 
 If scale is 2, 16 pixels need to be drawn where each bit represent a pair of screen pixels. If scale is 1, 8 consequtive pixels need drawing.
 
 Typically drawing happens on offscreen surface.
 
 @param controller Controller that requested drawing.
 @param point Coordinate of the pixel
 @param scale Computer scale (either 1 or 2).
 @param data Each bit in low byte is either 0 if given paper or 1 if given ink color should be drawn for corresponding pixel.
 @param ink Ink color index within current palette.
 @param paper Paper color index within current palette.
 */
- (void)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller
					draw8PixelsAt:(CGPoint)point
							scale:(CGFloat)scale
							 data:(NSInteger)data
							  ink:(NSInteger)ink
							paper:(NSInteger)paper;

/**
 Called when single 16 pixels need to be drawn starting at the gixen coordinate.
 
 Typically drawing happens on offscreen surface.
 
 @param controller Controller that requested drawing.
 @param point Coordinate of the pixel
 @param scale Computer scale (either 1 or 2).
 @param data Each bit in low word is either 0 if given paper or 1 if given ink color should be drawn for corresponding pixel.
 @param ink Ink color index within current palette.
 @param paper Paper color index within current palette.
 */
- (void)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller
				   draw16PixelsAt:(CGPoint)point
							scale:(CGFloat)scale
							 data:(NSInteger)data
							  ink:(NSInteger)ink
							paper:(NSInteger)paper;

/**
 Called when display needs to be refreshed for the given rect.
 
 Typically this is where display is marked for drawing. It's called after drawing methods.

 @param controller Controller that requested update.
 @param rect Rectangle that needs redraw.
 */
- (void)spectrumDisplayController:(SpectrumDisplayController * _Nonnull)controller updateDisplayAt:(CGRect)rect;

/**
 Called when graphics mode is swapped.
 
 @param controller Controller that requested graphics swap.
 */
- (void)spectrumDisplayControllerSwapGraphicsMode:(SpectrumDisplayController * _Nonnull)controller;

/**
 Called when frame ends.
 
 @param controller Controller that informed us about frame end.
 */
- (void)spectrumDisplayControllerEndFrame:(SpectrumDisplayController * _Nonnull)controller;

/**
 Called when display handling ends.
 
 @param controller Controller that infored us about display end.
 */
- (void)spectrumDisplayControllerEndDisplay:(SpectrumDisplayController * _Nonnull)controller;

@end
