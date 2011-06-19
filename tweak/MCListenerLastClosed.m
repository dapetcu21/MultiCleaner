//
//  MCListenerLastClosed.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListenerLastClosed.h"
#import "MultiCleaner.h"
#import "MCSettingsController.h"

@implementation MCListenerLastClosed


-(id)init
{
	if ((self=[super init]))
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_lastClosed"];
	}
	return self;
}

-(void)activationConfirmed
{
	if (isMultitaskingOff())
		return;
	openLastApp();
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	[self activationConfirmed];
	[event setHandled:YES];
}

+(MCListenerLastClosed*) sharedInstance
{
	static MCListenerLastClosed * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListenerLastClosed alloc] init];
	}
	return singleton;
}

@end
