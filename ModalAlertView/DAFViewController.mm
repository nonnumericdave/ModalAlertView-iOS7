//
//  DAFViewController.mm
//
//  Created by David Flores on 2/24/14.
//  Copyright (c) 2014 David Flores. All rights reserved.
//

#include "DAFViewController.h"

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface DAFViewController ()

// DAFViewController
- (void)raiseModalAlertViewWithNSRunLoop;
- (void)raiseModalAlertViewWithDAFRunLoop;

@end

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation DAFViewController

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
- (void)raiseModalAlertViewWithNSRunLoop
{
	
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)raiseModalAlertViewWithDAFRunLoop
{
	
}

@end
