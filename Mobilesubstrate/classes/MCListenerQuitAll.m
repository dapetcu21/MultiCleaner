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

-(void)performAction:(NSDictionary*)userinfo
{
	[self activator:nil receiveEvent:nil];
}

-(id)init
{
	if (self=[super init])
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_quitAllApps"];
		[[MCSettingsController sharedInstance] registerForMessage:@"quitAllApps" target:self selector:@selector(performAction:)];
	}
	return self;
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	MCSettings * sett = [MCSettings sharedInstance];
//	if (!(sett.quitAllEnabled))
//		return;
	if (isMultitaskingOff())
		return;
	if (!sett.hidePrompt)
		alert = [[UIAlertView alloc] init];
	else
		alert = nil;
	alert.delegate = self;
	if (sett.confirmQuit&!sett.hidePrompt)
	{
		alert.title = @"MultiCleaner";
		alert.message = loc(@"Quit all apps?",@"Quit all apps?");
		[alert addButtonWithTitle:loc(@"Yes",@"Yes")];
		[alert addButtonWithTitle:loc(@"No",@"No")];
		alert.cancelButtonIndex = 1;
		[alert show];
		[alert release];
	} else {
		alert.title = loc(@"Quit all apps",@"Quit all apps");
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
		[alert dismissAnimated:YES];
		alert=nil;
	}
}

-(void)activationConfirmed
{
	menuDown = NO;
	if (alert)
	{
		[alert dismissAnimated:YES];
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
	if (buttonIndex!=alertView.cancelButtonIndex)
	{
		alert = nil;
		[self activationConfirmed];
	}
}
@end
