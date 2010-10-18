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

#define appName MultiCleaner
#define prefsPath @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist"
#define visible __attribute__((visibility("default")))
BOOL MCQuitAllEnabled = YES;

visible
BOOL isCapable()
{
	return YES;
}

visible
BOOL getStateFast()
{
	return MCQuitAllEnabled;
}

visible
BOOL isEnabled()
{
	NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	NSNumber * num = [dict objectForKey:@"QuitAllEnabled"];
	if ([num isKindOfClass:[NSNumber class]])
		MCQuitAllEnabled = [num boolValue];
	[dict release];
	return MCQuitAllEnabled;
}

visible
void setState(BOOL state)
{
	MCQuitAllEnabled = state;
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
	[dict setObject:[NSNumber numberWithBool:MCQuitAllEnabled] forKey:@"QuitAllEnabled"];
	[dict writeToFile:prefsPath atomically:YES];
	[dict release];
	CPDistributedMessagingCenter * center = [CPDistributedMessagingCenter centerNamed:@"com.dapetcu21.MultiCleaner.center"];
	[center sendMessageName:@"reloadSettings" userInfo:nil];
}

visible
float getDelayTime()
{
	return 0.1f;
}