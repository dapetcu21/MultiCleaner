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
#include <SpringBoard/SBAwayController.h>

static BOOL MCfirstRun = NO;

DefineObjCHook(void,SBAC_unlock___,SBAwayController * self, SEL _cmd, BOOL sound, id alertDisplay, BOOL autoUnlock)
{
	Original(SBAC_unlock___)(self,_cmd,sound,alertDisplay,autoUnlock);
	if (MCfirstRun)
	{
		[[MCSettingsController sharedInstance] showWelcomeScreen];
		MCfirstRun = NO;
	}
}

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

-(id)init
{
	if (self=[super init])
	{
		prefsPath = @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist";
		defaultsPath = @"/Applications/MultiCleaner.app/defaults.plist";
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

	}
	return self;
}

-(void)dealloc
{
	[center release];
	[super dealloc];
}
			   
-(BOOL)loadSettings
{
	NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	if (!dict)
	{
		NSLog(@"MultiCleaner: Can't load settings, loading defaults");
		dict = [[NSDictionary alloc] initWithContentsOfFile:defaultsPath];
		if (!dict)
		{
			NSLog(@"MultiCleaner: Can't load default settings");
			return NO;
		} else {
			[dict writeToFile:prefsPath atomically:NO];
			MCfirstRun = YES;
			Class _SBAwayController=objc_getClass("SBAwayController");
			InstallObjCInstanceHook(_SBAwayController,@selector(unlockWithSound:alertDisplay:isAutoUnlock:),SBAC_unlock___);
			//[self showWelcomeScreen];
		}
	}
	[[MCSettings sharedInstance] loadFromDict:dict];	
	[settings release];
	settings = [dict objectForKey:@"Apps"];
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
	return YES;
}

-(void)showWelcomeScreen
{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"MultiCleaner"
													 message:loc(@"WelcomeDialog",@"Welcome to MultiCleaner! You can quit apps by holding the home button (as opposed to just minimizing them), and also the multitasking bar will show only the apps that are running. Also, try reordering the icons in the bar while in edit (wriggle) mode. You can customize these settings and much more in the MultiCleaner settings app")
													delegate:nil 
										   cancelButtonTitle:loc(@"OK",@"OK")
										   otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(MCIndividualSettings*)settingsForBundleID:(NSString*)bundleID
{
	MCIndividualSettings * sett = [settings objectForKey:bundleID];
	if (![sett isKindOfClass:[MCIndividualSettings class]])
		sett = [settings objectForKey:@"_global"];
	if ((sett!=nil)&&![sett isKindOfClass:[MCIndividualSettings class]])
		sett = nil;
	return sett;
}
@end