//
//  MCListener.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListener.h"
#import "MCSettings.h"
#import "MCSettingsController.h"
#import "MultiCleaner.h"

@implementation MCListener
@synthesize menuDown;

- (id)init
{
	if ((self=[super init]))
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
		[alert dismissAnimated:YES];
		alert=nil;
	}
	quitForegroundApp(YES);
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	if ([MCSettings sharedInstance].confirmQuitSingle) return;
	CGPoint center = alertView.center;
	CGRect frame = alertView.frame;
	frame.size.height = 60;
	alertView.frame = frame;
	alertView.center = center;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{	
	if ([[MCSettingsController sharedInstance] settingsForBundleID:foregroundAppDisplayIdentifier()].quitSingleException)
		return;
	MCSettings * sett = [MCSettings sharedInstance];
	if (!sett.hidePromptSingle)
		alert = [[UIAlertView alloc] init];
	else
		alert = nil;
	alert.delegate = self;
	if (sett.confirmQuitSingle&&!sett.hidePromptSingle)
	{
		alert.title = @"MultiCleaner";
		alert.message = loc(@"Quit app?",@"Quit app?");
		[alert addButtonWithTitle:loc(@"Yes",@"Yes")];
		[alert addButtonWithTitle:loc(@"No",@"No")];
		alert.cancelButtonIndex = 1;
		[alert show];
		[alert release];
	} else {
		alert.title = loc(@"Quit app",@"Quit app");
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

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	menuDown = NO;
	if (alert)
	{
		[alert dismissAnimated:YES];
		alert=nil;
	}
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex!=alertView.cancelButtonIndex)
	{
		alert = nil;
		[self activationConfirmed];
	}
}

@end
