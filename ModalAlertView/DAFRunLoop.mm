//
//  DAFRunLoop.mm
//
//  Created by David Flores on 2/25/14.
//  Copyright (c) 2014 David Flores. All rights reserved.
//

#include "DAFRunLoop.h"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFRunLoop ()

// DAFRunLoop
- (id)initWithRunLoop:(NSRunLoop*)pRunLoop;

@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFRunLoop
{
	NSRunLoop* m_pRunLoop;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ (DAFRunLoop*)currentRunLoop
{
	return [[DAFRunLoop alloc] initWithRunLoop:[NSRunLoop currentRunLoop]];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)runMode:(NSString*)pModeString beforeDate:(NSDate*)pLimitDate
{
	return [m_pRunLoop runMode:pModeString beforeDate:pLimitDate];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (id)initWithRunLoop:(NSRunLoop*)pRunLoop
{
	self = [super init];
	
	if ( self != nil )
		m_pRunLoop = pRunLoop;
	
	return self;
}

@end
