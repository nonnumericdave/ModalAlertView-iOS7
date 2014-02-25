//
//  DAFRunLoop.h
//
//  Created by David Flores on 2/25/14.
//  Copyright (c) 2014 David Flores. All rights reserved.
//

#ifndef DAFRunLoop_h
#define DAFRunLoop_h

@interface DAFRunLoop : NSObject

// DAFRunLoop
+ (DAFRunLoop*)currentRunLoop;
- (BOOL)runMode:(NSString*)pModeString beforeDate:(NSDate*)pLimitDate;

@end

#endif
