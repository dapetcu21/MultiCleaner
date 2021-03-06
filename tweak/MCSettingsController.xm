//
//  MCSettingsController.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCSettingsController.h"
#import "MultiCleaner.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>
#include <substrate.h>
#include <substrate2.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <SpringBoard/SBAwayController.h>

static BOOL MCshouldHook = NO;

%hook SBAwayController

%group unlockType
-(void)unlockWithSound:(BOOL)sound alertDisplay:(id)display isAutoUnlock:(BOOL)unlock unlockType:(int)type
{
	%orig;
	if (MCshouldHook)
	{
		[[MCSettingsController sharedInstance] showWelcomeScreen];
		MCshouldHook = NO;
	}
} 
%end

%group notUnlockType
-(void)unlockWithSound:(BOOL)sound alertDisplay:(id)display isAutoUnlock:(BOOL)unlock
{
	%orig;
	if (MCshouldHook)
	{
		[[MCSettingsController sharedInstance] showWelcomeScreen];
		MCshouldHook = NO;
	}
}
%end

%group ios5
- (void)_unlockWithSound:(BOOL)arg1 isAutoUnlock:(BOOL)arg2 unlockSource:(int)arg3
{
	%orig;
	if (MCshouldHook)
	{
		[[MCSettingsController sharedInstance] showWelcomeScreen];
		MCshouldHook = NO;
	}
}
%end

%end

@implementation MCSettingsController

+(MCSettingsController*)sharedInstance
{
	static MCSettingsController * g_settings = nil;
	if (!g_settings)
	{
		g_settings = [[MCSettingsController alloc] init];
	}
	return g_settings;
}

-(void)reloadSettings:(NSDictionary*)userData
{
	[self loadSettings];
	settingsReloaded();
}

-(void)performSettingsReloaded
{
	settingsReloaded();
}

-(void)quitAllApps:(NSDictionary*)userData
{
	
}

#define defaultsPath @"/Applications/MultiCleaner.app/defaults.plist"

-(id)init
{
	if ((self=[super init]))
	{
		order = nil;
		prefsPath = @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist";
		if (![self loadSettings])
		{
			[self release];
			return nil;
		}
		[self performSelectorOnMainThread:@selector(performSettingsReloaded) withObject:nil waitUntilDone:NO];
		Class $CPDistributedMessagingCenter = objc_getClass("CPDistributedMessagingCenter");
		center = [$CPDistributedMessagingCenter centerNamed:@"com.dapetcu21.MultiCleaner.center"];
		[center retain];
		[center runServerOnCurrentThread];
		[center registerForMessageName:@"reloadSettings" target:self selector:@selector(reloadSettings:)];
		[center registerForMessageName:@"quitAllApps" target:self selector:@selector(quitAllApps:)];

	}
	return self;
}

-(void)registerForMessage:(NSString*)name target:(id)tgt selector:(SEL)select
{
	[center registerForMessageName:name target:tgt selector:select];
}

-(void)dealloc
{
	[order release];
	[settings release];
	[center release];
	[super dealloc];
}

- (char *) platform
{
	static char * platform = NULL;
	if (!platform)
	{
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = (char*)malloc(size);
	    sysctlbyname("hw.machine", machine, &size, NULL, 0);
		platform = machine;
	}
	return platform;
}

-(BOOL)iOS5
{
	static double vv = 0;
	if (!vv)
	{
		NSDictionary * sysVersionDict = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
		NSString * version = [sysVersionDict objectForKey:@"ProductVersion"];
		if (!version)
		{
			version = [[UIDevice currentDevice] systemVersion];
			MCLog(@"Couldn't get ProductVersion from /System/Library/CoreServices/SystemVersion.plist ... Defaulting to [[UIDevice currentDevice] systemVersion]");
		}
		vv = [version floatValue];
	}
	return vv>=5.0f;
}

-(BOOL)springBoardHasApp:(NSString*)bundleID
{
	char * pl = [self platform];
	
	if ([bundleID isEqual:@"com.apple.mobilephone"])
		return (strncmp(pl,"iPhone",6)==0);
	if ([bundleID isEqual:@"com.apple.MobileSMS"])
	{
		if ([self iOS5])
			return YES;
		return (strncmp(pl,"iPhone",6)==0);
	}
	if ([bundleID isEqual:@"com.apple.Music"])
		return (strncmp(pl,"iPad",4)==0);
	if ([bundleID isEqual:@"com.apple.mobileipod-MediaPlayer"])
		return (![self iOS5])&&(strncmp(pl,"iPod",4)!=0)&&(strncmp(pl,"iPad",4)!=0);
	if ([bundleID isEqual:@"com.apple.mobileipod-AudioPlayer"])
		return (![self iOS5])&&(strncmp(pl,"iPod",4)==0);
	if ([bundleID isEqual:@"com.apple.mobileipod"])
		return [self iOS5]&&(strncmp(pl,"iPad",4)!=0);
	return YES;
}		
	   
-(BOOL)loadSettings
{
	BOOL shouldSave = NO;
	NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	if (!dict)
	{
		NSLog(@"MultiCleaner: Can't load settings, loading defaults");
		MCshouldHook = YES;
		shouldSave = YES;
		dict = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultsPath];
		if (dict)
		{
			NSMutableDictionary * apps = (NSMutableDictionary*)[dict objectForKey:@"Apps"];
			if (![apps isKindOfClass:[NSDictionary class]])
				apps = nil;
			if (apps)
				apps = [[NSMutableDictionary alloc] initWithDictionary:apps];
			
			NSMutableArray * ord = (NSMutableArray*)[dict objectForKey:@"Order"];
			if (![ord isKindOfClass:[NSArray class]])
				ord = nil;
			if (ord)
				ord = [[NSMutableArray alloc] initWithArray:ord];

			NSArray * applist = [[[apps allKeys] copy] autorelease];
			for (NSString * app in applist)
				if (![self springBoardHasApp:app])
				{
					[apps removeObjectForKey:app];
					[ord removeObject:app];
				}
			if (apps)
				[dict setValue:apps forKey:@"Apps"];
			if (ord)
				[dict setValue:ord forKey:@"Order"];
		}
	}
	if (!dict)
	{
		NSLog(@"MultiCleaner: Can't load defaults, loading scarce defaults");
		[[MCSettings sharedInstance] reloadDefaults];
		MCIndividualSettings * gsett = [[MCIndividualSettings alloc] init];
		[settings release];
		settings = [[NSMutableDictionary alloc] initWithCapacity:1];
		[settings setObject:gsett forKey:@"_global"];
		[gsett release];
		[order release];
		order = [[NSMutableArray alloc] initWithObjects:@"_global",nil];
		shouldSave = YES;
	}
	else
	{
#ifdef BETA_VERSION
		MCshouldHook = YES;
#endif
		[[MCSettings sharedInstance] loadFromDict:dict];	
		[settings release];
		settings = [dict objectForKey:@"Apps"];
		NSArray * norder = [dict objectForKey:@"Order"];
		[norder retain];
		[order release];
		order = norder;
		if (![settings isKindOfClass:[NSDictionary class]])
			settings=nil;
		NSMutableDictionary * newSettings = [[NSMutableDictionary alloc] initWithCapacity:[settings count]];
		NSArray * keys = [settings allKeys];
		for (NSString * key in keys)
		{
			NSDictionary * sett = [settings objectForKey:key];
			if (![sett isKindOfClass:[NSDictionary class]])
				sett= nil;
			MCIndividualSettings * pasett = [[MCIndividualSettings alloc] init];
			[pasett loadFromDict:sett];
			[newSettings setObject:pasett forKey:key];
			[pasett release];
		}
		settings = newSettings;
		[dict release];
	}
	if (shouldSave)
		[self saveSettings];
	return YES;
}

-(void)saveSettings
{
	NSMutableDictionary * file = [[NSMutableDictionary alloc] init];
	[[MCSettings sharedInstance] saveToDict:file];
	if (order)
		[file setObject:order forKey:@"Order"];
	NSMutableDictionary * apps = [[NSMutableDictionary alloc] init];
	NSArray * keys = [settings allKeys];
	for (NSString * key in keys)
	{
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
		MCIndividualSettings * sett = (MCIndividualSettings*)[settings objectForKey:key];
		[sett saveToDict:dict];
		[apps setObject:dict forKey:key];
		[dict release];
	}
	[file setObject:apps forKey:@"Apps"];
	[apps release];
	[file writeToFile:prefsPath atomically:YES];
	[file release];
}

-(void)showWelcomeScreen
{
	MCLog(@"Welcome to MultiCleaner");
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"MultiCleaner"
#ifdef BETA_VERSION
													 message:[NSString stringWithFormat:@"This is a demo version of MultiCleaner that expires on %@. Please don't redistribute",BETA_VERSION]
#else
													 message:loc(@"WelcomeDialog",@"Welcome to MultiCleaner! You can quit apps by holding the home button (as opposed to just minimizing them), and also the multitasking bar will show only the apps that are running. Also, try reordering the icons in the bar. You can customize these settings and much more in the MultiCleaner settings app")
#endif
													delegate:nil 
										   cancelButtonTitle:loc(@"OK",@"OK")
										   otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(MCIndividualSettings*)settingsForBundleID:(NSString*)bundleID
{
	if ([bundleID isEqual:@"com.dapetcu21.SpringBoard"])
		return [[MCSettings sharedInstance] sbIconSettings];
	MCIndividualSettings * sett = [settings objectForKey:bundleID];
	if (![sett isKindOfClass:[MCIndividualSettings class]])
		sett = [settings objectForKey:@"_global"];
	if ((sett!=nil)&&![sett isKindOfClass:[MCIndividualSettings class]])
		sett = nil;
	return sett;
}

-(MCIndividualSettings*)newSettingsForBundleID:(NSString*)bundleID
{
	if ([bundleID isEqual:@"com.dapetcu21.SpringBoard"])
		return [[MCSettings sharedInstance] sbIconSettings];
	MCIndividualSettings * sett = [settings objectForKey:bundleID];
	if (![sett isKindOfClass:[MCIndividualSettings class]])
	{
		sett = [[settings objectForKey:@"_global"] copy];
		[settings setObject:sett forKey:bundleID];
		if (![order isKindOfClass:[NSMutableArray class]])
		{
			NSMutableArray * arry = [[NSMutableArray alloc] initWithArray:order];
			[order release];
			order = arry;
		}
		[(NSMutableArray*)order addObject:bundleID];
	}
	return sett;
}

-(void)removeSettingsForBundleID:(NSString*)bundleID
{
	[settings removeObjectForKey:bundleID];
	if (![order isKindOfClass:[NSMutableArray class]])
	{
		NSMutableArray * arry = [[NSMutableArray alloc] initWithArray:order];
		[order release];
		order = arry;
	}
	[(NSMutableArray*)order removeObject:bundleID];
}

+(void)initHooks
{
	if ([objc_getClass("SBAwayController") instancesRespondToSelector:@selector(unlockWithSound:lockOwner:isAutoUnlock:unlockSource:)])
		%init(ios5);
	else
	if ([objc_getClass("SBAwayController") instancesRespondToSelector:@selector(unlockWithSound:alertDisplay:isAutoUnlock:unlockType:)])
		%init(unlockType);
	else
		%init(notUnlockType);
}

@end