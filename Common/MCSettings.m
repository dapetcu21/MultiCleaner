//
//  MCSettings.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCSettings.h"


@implementation MCSettings
@synthesize startupiPod;
@synthesize startupEdit;
@synthesize badgeCorner;
@synthesize quitCurrentApp;
@synthesize quitMode;
@synthesize dontWriggle;
@synthesize allowTap;
@synthesize reorderEdit;
@synthesize reorderNonEdit;
@synthesize swipeQuit;
@synthesize onlyWhenPlaying;
@synthesize noEditMode;
@synthesize fastExit;
@synthesize confirmQuit;
@synthesize confirmQuitSingle;
@synthesize hidePrompt;
@synthesize hidePromptSingle;

+(MCSettings*)sharedInstance
{
	static MCSettings * singleton = nil;
	if (!singleton)
		singleton = [[MCSettings alloc] init];
	return singleton;
}

-(id)init
{
	if (self=[super init])
	{
		[self reloadDefaults];
	}
	return self;
}

-(void)reloadDefaults
{
	reorderEdit = YES;
	reorderNonEdit = NO;
	swipeQuit = YES;
	startupEdit = NO;
	startupiPod = NO;
	quitCurrentApp = NO;
	dontWriggle = NO;
	allowTap = NO;
	onlyWhenPlaying = NO;
	noEditMode = NO;
	fastExit = NO;
	confirmQuit = NO;
	confirmQuitSingle = NO;
	hidePrompt = NO;
	hidePromptSingle = NO;
	quitMode = kQuitModeRemoveIcons;
	badgeCorner = 0;
}

-(void)loadFromDict:(NSDictionary *)def
{
	[self reloadDefaults];
	NSNumber * num;
	
	num = [def objectForKey:@"StartupiPod"];
	if ([num isKindOfClass:[NSNumber class]])
		startupiPod = [num boolValue];
	
	num = [def objectForKey:@"StartupEdit"];
	if ([num isKindOfClass:[NSNumber class]])
		startupEdit = [num boolValue];
	
	num = [def objectForKey:@"QuitCurrentApp"];
	if ([num isKindOfClass:[NSNumber class]])
		quitCurrentApp = [num boolValue];
	
	num = [def objectForKey:@"AllowTapEditing"];
	if ([num isKindOfClass:[NSNumber class]])
		allowTap = [num boolValue];
	
	num = [def objectForKey:@"DontWriggle"];
	if ([num isKindOfClass:[NSNumber class]])
		dontWriggle = [num boolValue];
	
	num = [def objectForKey:@"ReorderEdit"];
	if ([num isKindOfClass:[NSNumber class]])
		reorderEdit = [num boolValue];
	
	num = [def objectForKey:@"ReorderNonEdit"];
	if ([num isKindOfClass:[NSNumber class]])
		reorderNonEdit = [num boolValue];
	
	num = [def objectForKey:@"iPodOnlyWhenPlaying"];
	if ([num isKindOfClass:[NSNumber class]])
		onlyWhenPlaying = [num boolValue];
	
	num = [def objectForKey:@"NoEditMode"];
	if ([num isKindOfClass:[NSNumber class]])
		noEditMode = [num boolValue];
	
	num = [def objectForKey:@"FastExit"];
	if ([num isKindOfClass:[NSNumber class]])
		fastExit = [num boolValue];
	
	num = [def objectForKey:@"SwipeToQuit"];
	if ([num isKindOfClass:[NSNumber class]])
		swipeQuit = [num boolValue];
	
	num = [def objectForKey:@"ConfirmQuit"];
	if ([num isKindOfClass:[NSNumber class]])
		confirmQuit = [num boolValue];
	
	num = [def objectForKey:@"ConfirmQuitSingle"];
	if ([num isKindOfClass:[NSNumber class]])
		confirmQuitSingle = [num boolValue];
	
	num = [def objectForKey:@"HidePrompt"];
	if ([num isKindOfClass:[NSNumber class]])
		hidePrompt = [num boolValue];
	
	num = [def objectForKey:@"HidePromptSingle"];
	if ([num isKindOfClass:[NSNumber class]])
		hidePromptSingle = [num boolValue];
	
	num = [def objectForKey:@"QuitMode"];
	if ([num isKindOfClass:[NSNumber class]])
		quitMode = [num intValue];
	
	num = [def objectForKey:@"BadgeCorner"];
	if ([num isKindOfClass:[NSNumber class]])
		badgeCorner = [num intValue];
	
	//NSLog(@"loading common settings: %@",def);
	
	if ((badgeCorner>=4)||(badgeCorner<0))
		badgeCorner = 0;
	if ((quitMode>=NUMQUITMODES)||(quitMode<0))
		quitMode = kQuitModeRemoveIcons;
}

-(void)saveToDict:(NSMutableDictionary *)def
{
	[def setObject:[NSNumber numberWithBool:startupiPod] forKey:@"StartupiPod"];
	[def setObject:[NSNumber numberWithBool:startupEdit] forKey:@"StartupEdit"];
	[def setObject:[NSNumber numberWithBool:quitCurrentApp] forKey:@"QuitCurrentApp"];
	[def setObject:[NSNumber numberWithBool:dontWriggle] forKey:@"DontWriggle"];
	[def setObject:[NSNumber numberWithInt:quitMode] forKey:@"QuitMode"];
	[def setObject:[NSNumber numberWithInt:badgeCorner] forKey:@"BadgeCorner"];
	[def setObject:[NSNumber numberWithBool:allowTap]  forKey:@"AllowTapEditing"];
	[def setObject:[NSNumber numberWithBool:reorderEdit] forKey:@"ReorderEdit"];
	[def setObject:[NSNumber numberWithBool:reorderNonEdit] forKey:@"ReorderNonEdit"];
	[def setObject:[NSNumber numberWithBool:swipeQuit] forKey:@"SwipeToQuit"];;
	[def setObject:[NSNumber numberWithBool:onlyWhenPlaying] forKey:@"iPodOnlyWhenPlaying"];
	[def setObject:[NSNumber numberWithBool:noEditMode] forKey:@"NoEditMode"];
	[def setObject:[NSNumber numberWithBool:fastExit] forKey:@"FastExit"];
	[def setObject:[NSNumber numberWithBool:confirmQuit] forKey:@"ConfirmQuit"];
	[def setObject:[NSNumber numberWithBool:confirmQuitSingle] forKey:@"ConfirmQuitSingle"];
	[def setObject:[NSNumber numberWithBool:hidePrompt] forKey:@"HidePrompt"];
	[def setObject:[NSNumber numberWithBool:hidePromptSingle] forKey:@"HidePromptSingle"];
	//NSLog(@"saving common settings: %@",def);
}
@end
