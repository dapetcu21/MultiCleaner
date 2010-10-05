//
//  MCListener.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListener.h"
#import "MultiCleaner.h"

@implementation MCListener
@synthesize menuDown;

- (id)init
{
	if (self=[super init])
	{
		if (![[LAActivator sharedInstance] hasSeenListenerWithName:@"com.dapetcu21.MultiCleaner"])
			[[LAActivator sharedInstance] assignEvent:[LAEvent eventWithName:LAEventNameMenuHoldShort mode:LAEventModeApplication] toListenerWithName:@"com.dapetcu21.MultiCleaner"];
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner"];
	}
	return self;
}

-(void)activationConfirmed
{
	menuDown=NO;
	if (alert)
	{
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		alert=nil;
	}
	quitForegroundApp();
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	CGPoint center = alertView.center;
	CGRect frame = alertView.frame;
	frame.size.height = 60;
	alertView.frame = frame;
	alertView.center = center;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	alert = [[UIAlertView alloc] init];
	alert.title = @"Quit app";
	alert.delegate = self;
	[alert show];
	[alert release];
	if ([event.name isEqual:LAEventNameMenuHoldShort])
	{
		menuDown= YES;
	} else {
		[self activationConfirmed];
	}
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	menuDown = NO;
	if (alert)
	{
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		alert=nil;
	}
}

-(void) activator:(LAActivator *)activator didChangeToEventMode:(NSString *)eventMode
{
	//NSLog(@"MultiCleaner: %@",eventMode);
}

+(MCListener*) sharedInstance
{
	static MCListener * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListener alloc] init];
	}
	return singleton;
}


@end
