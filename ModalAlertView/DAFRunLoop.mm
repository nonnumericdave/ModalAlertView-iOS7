//
//  DAFRunLoop.mm
//
//  Created by David Flores on 2/25/14.
//  Copyright (c) 2014 David Flores. All rights reserved.
//

#include "DAFRunLoop.h"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// CFInternal.h
//
// Copyright (c) 2013 Apple Inc. All rights reserved.
//
#if defined(__BIG_ENDIAN__)
#define __CF_BIG_ENDIAN__ 1
#define __CF_LITTLE_ENDIAN__ 0
#endif

#if defined(__LITTLE_ENDIAN__)
#define __CF_LITTLE_ENDIAN__ 1
#define __CF_BIG_ENDIAN__ 0
#endif

#define CF_INFO_BITS (!!(__CF_BIG_ENDIAN__) * 3)

#define __CFBitfieldMask(N1, N2)        ((((UInt32)~0UL) << (31UL - (N1) + (N2))) >> (31UL - N1))
#define __CFBitfieldGetValue(V, N1, N2) (((V) & __CFBitfieldMask(N1, N2)) >> (N2))
#define __CFBitfieldSetValue(V, N1, N2, X)      ((V) = ((V) & ~__CFBitfieldMask(N1, N2)) | (((X) << (N2)) & __CFBitfieldMask(N1, N2)))

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// CFRuntime.h
//
// Copyright (c) 2013 Apple Inc. All rights reserved.
//
typedef struct __CFRuntimeBase {
    uintptr_t _cfisa;
    uint8_t _cfinfo[4];
#if __LP64__
    uint32_t _rc;
#endif
} CFRuntimeBase;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// CFRunLoop.c
//
// Copyright (c) 2013 Apple Inc. All rights reserved.
//
CF_INLINE Boolean __CFRunLoopObserverIsFiring(CFRunLoopObserverRef rlo) {
    return (Boolean)__CFBitfieldGetValue(((const CFRuntimeBase *)rlo)->_cfinfo[CF_INFO_BITS], 0, 0);
}

CF_INLINE void __CFRunLoopObserverSetFiring(CFRunLoopObserverRef rlo) {
    __CFBitfieldSetValue(((CFRuntimeBase *)rlo)->_cfinfo[CF_INFO_BITS], 0, 0, 1);
}

CF_INLINE void __CFRunLoopObserverUnsetFiring(CFRunLoopObserverRef rlo) {
    __CFBitfieldSetValue(((CFRuntimeBase *)rlo)->_cfinfo[CF_INFO_BITS], 0, 0, 0);
}

typedef mach_port_t __CFPortSet;

struct __CFRunLoopMode {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;      /* must have the run loop locked before locking this */
    CFStringRef _name;
    Boolean _stopped;
    char _padding[3];
    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
    CFMutableDictionaryRef _portToV1SourceMap;
    __CFPortSet _portSet;
    CFIndex _observerMask;
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    dispatch_source_t _timerSource;
    dispatch_queue_t _queue;
    Boolean _timerFired; // set to true by the source when a timer has fired
    Boolean _dispatchTimerArmed;
#endif
#if USE_MK_TIMER_TOO
    mach_port_t _timerPort;
    Boolean _mkTimerArmed;
#endif
#if DEPLOYMENT_TARGET_WINDOWS
    DWORD _msgQMask;
    void (*_msgPump)(void);
#endif
    uint64_t _timerSoftDeadline; /* TSR */
    uint64_t _timerHardDeadline; /* TSR */
};

typedef struct _per_run_data {
    uint32_t a;
    uint32_t b;
    uint32_t stopped;
    uint32_t ignoreWakeUps;
} _per_run_data;

typedef mach_port_t __CFPort;

typedef struct __CFRunLoopMode *CFRunLoopModeRef;

struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;                      /* locked for accessing mode list */
    __CFPort _wakeUpPort;                       // used for CFRunLoopWakeUp
    Boolean _unused;
    volatile _per_run_data *_perRunData;              // reset for runs of the run loop
    pthread_t _pthread;
    uint32_t _winthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes;
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFTypeRef _counterpart;
};

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
	NSRunLoop* pCurrentRunLoop = [NSRunLoop currentRunLoop];
	CFRunLoopRef refCurrentRunLoop = [pCurrentRunLoop getCFRunLoop];
	
	std::list<CFRunLoopObserverRef> listRunLoopObservers;
	if ( refCurrentRunLoop != NULL &&
		 refCurrentRunLoop->_currentMode != NULL &&
		 refCurrentRunLoop->_currentMode->_observers != NULL )
	{
		CFArrayRef refRunLoopObserverArray = refCurrentRunLoop->_currentMode->_observers;
		CFIndex indexRunLoopObserverCount = ::CFArrayGetCount(refRunLoopObserverArray);
		for (CFIndex index = 0; index < indexRunLoopObserverCount; index++)
		{
			CFRunLoopObserverRef refCurrentRunLoopObserver =
				static_cast<CFRunLoopObserverRef>(const_cast<void*>(::CFArrayGetValueAtIndex(refRunLoopObserverArray, index)));
			
			if ( __CFRunLoopObserverIsFiring(refCurrentRunLoopObserver) )
			{
				::CFRetain(refCurrentRunLoopObserver);
				listRunLoopObservers.push_back(refCurrentRunLoopObserver);
				__CFRunLoopObserverUnsetFiring(refCurrentRunLoopObserver);
			}
		}
	}
	
	BOOL boolRunLoopResult = [m_pRunLoop runMode:pModeString beforeDate:pLimitDate];
	
	for (CFRunLoopObserverRef refCurrentRunLoopObserver : listRunLoopObservers)
	{
		__CFRunLoopObserverSetFiring(refCurrentRunLoopObserver);
		::CFRelease(refCurrentRunLoopObserver);
	}
	
	return boolRunLoopResult;
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
