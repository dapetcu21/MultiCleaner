//
//  MCListenerJustMin.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCListenerJustMin.h"
#import "MultiCleaner.h"
#import "MCSettingsController.h"

@implementation MCListenerJustMin

@synthesize menuDown;

-(void)performAction:(NSDictionary*)userinfo
{
	[self activator:nil receiveEvent:nil];
}

-(id)init
{
	if ((self=[super init]))
	{
		[[LAActivator sharedInstance] registerListener:self forName:@"com.dapetcu21.MultiCleaner_justMin"];
	}
	return self;
}

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	MCSettings * sett = [MCSettings sharedInstance];
	if (isMultitaskingOff())
		return;
	if (!sett.hidePromptMin)
		alert = [[UIAlertView alloc] init];
	else
		alert = nil;
	alert.delegate = self;
	alert.title = loc(@"Minimize App",@"Minimize app");
	[alert show];
	[alert release];
	if ([event.name isEqual:LAEventNameMenuHoldShort])
		menuDown = YES;
	else
		[self activationConfirmed];
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
	if (isMultitaskingOff())
		return;
	minimizeForegroundApp();
}

+(MCListenerJustMin*) sharedInstance
{
	static MCListenerJustMin * singleton = nil;
	if (!singleton)
	{
		singleton = [[MCListenerJustMin alloc] init];
	}
	return singleton;
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
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
