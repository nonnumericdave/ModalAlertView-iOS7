//
//  DAFViewController.mm
//
//  Created by David Flores on 2/24/14.
//  Copyright (c) 2014 David Flores. All rights reserved.
//

#include "DAFViewController.h"

#include "DAFRunLoop.h"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFViewController () <UIAlertViewDelegate>

// UIAlertViewDelegate
- (void)alertView:(UIAlertView*)pAlertView didDismissWithButtonIndex:(NSInteger)iButtonIndex;

// DAFViewController
- (void)raiseModalAlertViewWithNSRunLoop;
- (void)raiseModalAlertViewWithDAFRunLoop;

@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFViewController
{
    BOOL m_boolAlertViewHasBeenDismissed;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)tableView:(UITableView*)pTableView didSelectRowAtIndexPath:(NSIndexPath*)pIndexPath
{
    assert( pIndexPath.section == 0 );
    assert( pIndexPath.row >= 0 && pIndexPath.row < 2 );
    
    if ( pIndexPath.section == 0 )
    {
        if ( pIndexPath.row == 0 )
        {
            [self raiseModalAlertViewWithNSRunLoop];
        }
        else if ( pIndexPath.row == 1 )
        {
            [self raiseModalAlertViewWithDAFRunLoop];
        }
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)alertView:(UIAlertView*)pAlertView didDismissWithButtonIndex:(NSInteger)iButtonIndex
{
    m_boolAlertViewHasBeenDismissed = YES;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)raiseModalAlertViewWithNSRunLoop
{
    UIAlertView* pAlertView = [[UIAlertView alloc] initWithTitle:@"Hanging"
                                                         message:@"Sorry"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    
    m_boolAlertViewHasBeenDismissed = NO;
    
    [pAlertView show];
    
    while ( ! m_boolAlertViewHasBeenDismissed )
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)raiseModalAlertViewWithDAFRunLoop
{
    UIAlertView* pAlertView = [[UIAlertView alloc] initWithTitle:@"Not Hanging"
                                                         message:@"Awesome"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    
    m_boolAlertViewHasBeenDismissed = NO;
    
    [pAlertView show];
    
    while ( ! m_boolAlertViewHasBeenDismissed )
        [[DAFRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                  beforeDate:[NSDate distantFuture]];
}

@end
