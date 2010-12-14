//
//  MCListenerOpenBar.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListenerOpenBar.h"
#import "MultiCleaner.h"
#import "MCSettingsController.h"

@implementation MCListenerOpenBar


-(id)init
{
	if (self=[super init])
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_openBar"];
	}
	return self;
}

-(void)activationConfirmed
{
	if (isMultitaskingOff())
		return;
	toggleBar();
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	MCLog(@"%@ %@",event.name,event.mode);
	if ([event.mode isEqual:LAEventModeLockScreen]&&![MCSettings sharedInstance].toggleInLockscreen)
		return;
	[self activationConfirmed];
	[event setHandled:YES];
}

+(MCListenerOpenBar*) sharedInstance
{
	static MCListenerOpenBar * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListenerOpenBar alloc] init];
	}
	return singleton;
}

@end
