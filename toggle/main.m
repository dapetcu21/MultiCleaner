//
//  MultiCleaner.mm
//  MultiCleaner
//
//  Created by Marius Petcu on 9/6/10.
//  Copyright Home 2010. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//

#import <AppSupport/CPDistributedMessagingCenter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <unistd.h>

#define appName MultiCleaner
#define prefsPath @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist"
#define visible __attribute__((visibility("default")))
BOOL MCToggleState = YES;
BOOL MCToggleType = 0;

@protocol SBSettingsWindowProtocol
-(void)closeButtonPressed;
@end

UIWindow<SBSettingsWindowProtocol> * getAppWindow()
{
	UIWindow* theWindow = nil;
	UIApplication* app = [UIApplication sharedApplication];
	NSArray* windows = [app windows];
	int i;
	for(i = 0; i < [windows count]; i++)
	{
		theWindow = [windows objectAtIndex:i];
		if([theWindow respondsToSelector:@selector(getCurrentTheme)])
		{
			break;
		}
	}
	
	if(i == [windows count])
	{
		theWindow = [app keyWindow];
	}
	
	return theWindow;
}

visible
BOOL isCapable()
{
	return YES;
}

visible
BOOL getStateFast()
{
	return MCToggleState;
}

void MCToggleReloadSettings()
{
	NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	NSNumber * num = [dict objectForKey:@"QuitAllEnabled"];
	if ([num isKindOfClass:[NSNumber class]])
		MCToggleState = [num boolValue];
	num = [dict objectForKey:@"ToggleType"];
	if ([num isKindOfClass:[NSNumber class]])
	{
		MCToggleType = [num intValue];
		if ((MCToggleType<0)||(MCToggleType>=2))
			MCToggleType = 0;
	}
	if (MCToggleType)
		MCToggleState = YES;
	[dict release];
}

visible
BOOL isEnabled()
{
	MCToggleReloadSettings();
	return MCToggleState;
}

visible
void setState(BOOL state)
{
	CPDistributedMessagingCenter * center = [CPDistributedMessagingCenter centerNamed:@"com.dapetcu21.MultiCleaner.center"];
	if (MCToggleType)
	{
		[center sendMessageName:@"quitAllApps" userInfo:nil];
		UIWindow<SBSettingsWindowProtocol> * window = getAppWindow();
		if ([window respondsToSelector:@selector(closeButtonPressed)])
			[window closeButtonPressed];
	}
	else
	{
		MCToggleState = state;
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
		[dict setObject:[NSNumber numberWithBool:MCToggleState] forKey:@"QuitAllEnabled"];
		[dict writeToFile:prefsPath atomically:YES];
		[dict release];
		[center sendMessageName:@"reloadSettings" userInfo:nil];
	}
}

visible
float getDelayTime()
{
	if (MCToggleType)
		return 1.0f;
	return 0.1f;
}