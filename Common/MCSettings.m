//
//  MCSettings.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCSettings.h"
#import "MCIndividualSettings.h"

@implementation MCSettings
@synthesize startupiPod;
@synthesize startupEdit;
@synthesize startupPinned;
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
//@synthesize quitAllEnabled;
@synthesize sbIcon;
@synthesize legacyMode;
@synthesize toggleType;
@synthesize sbIconSettings;
@synthesize onlyWhenEmpty;
@synthesize pinnedOnlyWhenEmpty;
@synthesize hidePromptMin;
@synthesize bypassPhone;
@synthesize unlessMusic;

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
		sbIconSettings = [[MCIndividualSettings alloc] init];
		[self reloadDefaults];
	}
	return self;
}

-(void)dealloc
{
	[sbIconSettings release];
	[super dealloc];
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
//	quitAllEnabled = YES;
	sbIcon = NO;
	legacyMode = NO;
	onlyWhenEmpty = NO;
	startupPinned = NO;
	pinnedOnlyWhenEmpty = NO;

	hidePromptMin = YES;
	bypassPhone = YES;
	unlessMusic = NO;
	toggleType = kToggleTypeToggle;
	
	[sbIconSettings reloadDefaults];
	sbIconSettings.hidden = YES;
	sbIconSettings.quitException = YES;
	sbIconSettings.quitSingleException = YES;
	sbIconSettings.swipeType = kSTNothing;
}

#define loadBOOL(x,y) \
num = [def objectForKey:(y)]; \
if ([num isKindOfClass:[NSNumber class]])\
(x) = [num boolValue]

#define loadInt(x,y) \
num = [def objectForKey:(y)]; \
if ([num isKindOfClass:[NSNumber class]])\
(x) = [num intValue]

-(void)loadFromDict:(NSDictionary *)def
{
	[self reloadDefaults];
	NSNumber * num;
	
	loadBOOL(startupiPod,@"StartupiPod");
	loadBOOL(startupEdit,@"StartupEdit");
	loadBOOL(quitCurrentApp,@"QuitCurrentApp");
	loadBOOL(allowTap,@"AllowTapEditing");
	loadBOOL(dontWriggle,@"DontWriggle");
	loadBOOL(reorderEdit,@"ReorderEdit");
	loadBOOL(reorderNonEdit,@"ReorderNonEdit");
	loadBOOL(onlyWhenPlaying,@"iPodOnlyWhenPlaying");
	loadBOOL(unlessMusic,@"UnlessMusic");
	loadBOOL(noEditMode,@"NoEditMode");
	loadBOOL(fastExit,@"FastExit");
	loadBOOL(swipeQuit,@"SwipeToQuit");
	loadBOOL(confirmQuit,@"ConfirmQuit");
	loadBOOL(confirmQuitSingle,@"ConfirmQuitSingle");
	loadBOOL(hidePrompt,@"HidePrompt");
	loadBOOL(hidePromptSingle,@"HidePromptSingle");
//	loadBOOL(quitAllEnabled,@"QuitAllEnabled");
	loadBOOL(legacyMode,@"LegacyMode");
	loadBOOL(sbIcon,@"SBIcon");
	loadBOOL(onlyWhenEmpty,@"iPodOnlyWhenEmpty");
	loadBOOL(startupPinned,@"StartupPinned");
	loadBOOL(pinnedOnlyWhenEmpty,@"PinnedOnlyWhenEmpty");
	loadInt(quitMode,@"QuitMode");
	loadInt(badgeCorner,@"BadgeCorner");
	loadInt(toggleType,@"ToggleType");
	loadBOOL(hidePromptMin,@"HidePromptMinimize");
	loadBOOL(bypassPhone,@"BypassPhone");
	
	if ((toggleType>=NUMTOGGLETYPES)||(toggleType<0))
		toggleType = kToggleTypeToggle;
	if ((badgeCorner>=4)||(badgeCorner<0))
		badgeCorner = 0;
	if ((quitMode>=NUMQUITMODES)||(quitMode<0))
		quitMode = kQuitModeRemoveIcons;
	
	NSDictionary * dict = [def objectForKey:@"SBIconSettings"];
	if ([dict isKindOfClass:[NSDictionary class]])
		[sbIconSettings loadFromDict:dict];
}

#define saveBOOL(x,y) [def setObject:[NSNumber numberWithBool:(x)] forKey:(y)];
#define saveInt(x,y) [def setObject:[NSNumber numberWithInt:(x)] forKey:(y)];

-(void)saveToDict:(NSMutableDictionary *)def
{
	saveBOOL(startupiPod,@"StartupiPod");
	saveBOOL(startupEdit,@"StartupEdit");
	saveBOOL(quitCurrentApp,@"QuitCurrentApp");
	saveBOOL(allowTap,@"AllowTapEditing");
	saveBOOL(dontWriggle,@"DontWriggle");
	saveBOOL(reorderEdit,@"ReorderEdit");
	saveBOOL(reorderNonEdit,@"ReorderNonEdit");
	saveBOOL(swipeQuit,@"SwipeToQuit");
	saveBOOL(onlyWhenPlaying,@"iPodOnlyWhenPlaying");
	saveBOOL(onlyWhenEmpty,@"iPodOnlyWhenEmpty");
	saveBOOL(unlessMusic,@"UnlessMusic");
	saveBOOL(noEditMode,@"NoEditMode");
	saveBOOL(fastExit,@"FastExit");
	saveBOOL(confirmQuit,@"ConfirmQuit");
	saveBOOL(confirmQuitSingle,@"ConfirmQuitSingle");
	saveBOOL(hidePrompt,@"HidePrompt");
	saveBOOL(hidePromptSingle,@"HidePromptSingle");
//	saveBOOL(quitAllEnabled,@"QuitAllEnabled");
	saveBOOL(sbIcon,@"SBIcon");
	saveBOOL(legacyMode,@"LegacyMode");
	saveBOOL(startupPinned,@"StartupPinned");
	saveBOOL(pinnedOnlyWhenEmpty,@"PinnedOnlyWhenEmpty");
	saveInt(quitMode,@"QuitMode");
	saveInt(badgeCorner,@"BadgeCorner");
	saveInt(toggleType,@"ToggleType");
	saveBOOL(hidePromptMin,@"HidePromptMinimize");
	saveBOOL(bypassPhone,@"BypassPhone");
	
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
	[sbIconSettings saveToDict:dict];
	[def setObject:dict forKey:@"SBIconSettings"];
	[dict release];
	//NSLog(@"saving common settings: %@",def);
}
@end
