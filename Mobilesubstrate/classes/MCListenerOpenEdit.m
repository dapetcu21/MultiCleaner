//
//  MCListenerOpenEdit.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListenerOpenEdit.h"
#import "MultiCleaner.h"
#import "MCSettingsController.h"

#import <SpringBoard/SpringBoard.h>

@implementation MCListenerOpenEdit


-(id)init
{
	if (self=[super init])
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_openEdit"];
	}
	return self;
}

-(void)activationConfirmed:(BOOL)notIgnore
{
	if (notIgnore)
	{
		inUse = YES;
		[self performSelector:@selector(activationConfirmed:) withObject:(id)NO afterDelay:0.5f];
		return;
	}
	inUse = NO;
	if (isMultitaskingOff())
		return;
	SBAwayController * controller = [objc_getClass("SBAwayController") sharedAwayController];
	if ([controller isLocked])
	{
		[controller unlockWithSound:YES];
	}
	toggleBarEdit(notIgnore);
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (inUse)
		return;
	NSArray * events = [NSArray arrayWithObjects:
					  LAEventNameStatusBarSwipeRight,
					  LAEventNameStatusBarSwipeLeft,
					  LAEventNameStatusBarSwipeDown,
					  LAEventNameStatusBarTapDouble,
					  LAEventNameStatusBarHold,
					  LAEventNameSlideInFromBottom,
					  LAEventNameSlideInFromBottomLeft,
					  LAEventNameSlideInFromBottomRight,
					  nil];
	[self activationConfirmed:[events containsObject:event.name]];
	[event setHandled:YES];
}

+(MCListenerOpenEdit*) sharedInstance
{
	static MCListenerOpenEdit * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListenerOpenEdit alloc] init];
	}
	return singleton;
}

@end
