//
//  MCListenerQuitAll.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListenerQuitAll.h"
#import "MultiCleaner.h"
#import "MCSettingsController.h"

@implementation MCListenerQuitAll

@synthesize menuDown;

-(id)init
{
	if (self=[super init])
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_quitAllApps"];
	}
	return self;
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	alert = [[UIAlertView alloc] init];
	alert.delegate = self;
	if ([MCSettings sharedInstance].confirmQuit)
	{
		alert.title = @"MultiCleaner";
		alert.message = @"Quit all apps?";
		[alert addButtonWithTitle:@"No"];
		[alert addButtonWithTitle:@"Yes"];
		alert.cancelButtonIndex = 0;
		[alert show];
		[alert release];
	} else {
		alert.title = @"Quit all apps";
		[alert show];
		[alert release];
		if ([event.name isEqual:LAEventNameMenuHoldShort])
		{
			menuDown = YES;
		} else {
			[self activationConfirmed];
		}
	}
	[event setHandled:YES];
}

-(void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	menuDown = NO;
	if (alert)
	{
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		alert=nil;
	}
}

-(void)activationConfirmed
{
	menuDown = NO;
	if (alert)
	{
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		alert=nil;
	}	
	quitAllApps();
}

+(MCListenerQuitAll*) sharedInstance
{
	static MCListenerQuitAll * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListenerQuitAll alloc] init];
	}
	return singleton;
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	if ([MCSettings sharedInstance].confirmQuit) return;
	CGPoint center = alertView.center;
	CGRect frame = alertView.frame;
	frame.size.height = 60;
	alertView.frame = frame;
	alertView.center = center;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==1)
	{
		alert = nil;
		[self activationConfirmed];
	}
}
@end
