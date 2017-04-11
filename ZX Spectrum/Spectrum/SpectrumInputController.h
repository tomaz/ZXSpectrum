//
//  Created by Tomaz Kragelj on 11.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Middleware between higher level API and low level fuse input API.
 */
@interface SpectrumInputController : NSObject

- (void)inject:(char)key;

@end
