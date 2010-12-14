//
//  MCIndividualSettings.m
//  MultiCleaner
//
//  Created by Marius Petcu on 10/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCIndividualSettings.h"


@implementation MCIndividualSettings
@synthesize autoclose;
@synthesize hidden;
@synthesize dimClosed;
@synthesize alwaysDim;
@synthesize runningBadge;
@synthesize showCurrent;
@synthesize quitException;
@synthesize quitSingleException; 
@synthesize moveBack;
@synthesize dontMoveToFront;
@synthesize launchType;
@synthesize quitType;
@synthesize swipeType;
@synthesize autolaunch;
@synthesize pinned;
@synthesize badgePinned;

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
	pinned = NO;
	autoclose = YES;
	hidden = NO;
	dimClosed = NO;
	alwaysDim = NO;
	runningBadge = NO;
	showCurrent = NO;
	quitException = NO;
	moveBack = NO;
	dontMoveToFront = NO;
	quitSingleException = NO;
	autolaunch = YES;
	launchType = kLTFront;
	quitType = kQTAppAndIcon;
	badgePinned = YES;
}

-(void)loadFromDict:(NSDictionary*)dict
{
	[self reloadDefaults];
	
	NSNumber * num;
	
	num = [dict objectForKey:@"Pinned"];
	if ([num isKindOfClass:[NSNumber class]])
		pinned = [num boolValue];
	
	num = [dict objectForKey:@"Autoclose"];
	if ([num isKindOfClass:[NSNumber class]])
		autoclose = [num boolValue];
	
	num = [dict objectForKey:@"Hidden"];
	if ([num isKindOfClass:[NSNumber class]])
		hidden = [num boolValue];
	
	num = [dict objectForKey:@"DimClosed"];
	if ([num isKindOfClass:[NSNumber class]])
		dimClosed = [num boolValue];
	
	num = [dict objectForKey:@"AlwaysDim"];
	if ([num isKindOfClass:[NSNumber class]])
		alwaysDim = [num boolValue];
	
	num = [dict objectForKey:@"RunningBadge"];
	if ([num isKindOfClass:[NSNumber class]])
		runningBadge = [num boolValue];
	
	num = [dict objectForKey:@"ShowCurrentApp"];
	if ([num isKindOfClass:[NSNumber class]])
		showCurrent = [num boolValue];
	
	num = [dict objectForKey:@"QuitException"];
	if ([num isKindOfClass:[NSNumber class]])
		quitException = [num boolValue];
	
	num = [dict objectForKey:@"QuitSingleException"];
	if ([num isKindOfClass:[NSNumber class]])
		quitSingleException = [num boolValue];
	
	num = [dict objectForKey:@"MoveBack"];
	if ([num isKindOfClass:[NSNumber class]])
		moveBack = [num boolValue];
	
	num = [dict objectForKey:@"DontMoveToFront"];
	if ([num isKindOfClass:[NSNumber class]])
		dontMoveToFront = [num boolValue];
	
	num = [dict objectForKey:@"AutoLaunch"];
	if ([num isKindOfClass:[NSNumber class]])
		autolaunch = [num boolValue];
	
	num = [dict objectForKey:@"PinnedBadge"];
	if ([num isKindOfClass:[NSNumber class]])
		badgePinned = [num boolValue];
	
	num = [dict objectForKey:@"SwipeType"];
	if ([num isKindOfClass:[NSNumber class]])
		swipeType = [num intValue];
	
	num = [dict objectForKey:@"LaunchType"];
	if ([num isKindOfClass:[NSNumber class]])
		launchType = [num intValue];
	
	num = [dict objectForKey:@"QuitType"];
	if ([num isKindOfClass:[NSNumber class]])
		quitType = [num intValue];
	
	if ((swipeType>=NUMSWIPETYPES)||(swipeType<0))
		swipeType = kSTAppAndIcon;
	
	if ((launchType>=NUMLAUNCHTYPES)||(launchType<0))
		launchType = kLTFront;
	
	if ((quitType>=NUMQUITTYPES)||(quitType<0))
		quitType = kQTAppAndIcon;
	
	num = [dict objectForKey:@"SwipeNoQuit"];
	if ([num isKindOfClass:[NSNumber class]]&&[num boolValue])
		swipeType = kSTIcon;
	
}

-(void)saveToDict:(NSMutableDictionary*)dict
{
	[dict setObject:[NSNumber numberWithBool:pinned] forKey:@"Pinned"];
	[dict setObject:[NSNumber numberWithBool:autoclose] forKey:@"Autoclose"];
	[dict setObject:[NSNumber numberWithBool:hidden] forKey:@"Hidden"];
	[dict setObject:[NSNumber numberWithBool:dimClosed] forKey:@"DimClosed"];
	[dict setObject:[NSNumber numberWithBool:alwaysDim] forKey:@"AlwaysDim"];
	[dict setObject:[NSNumber numberWithBool:runningBadge] forKey:@"RunningBadge"];
	[dict setObject:[NSNumber numberWithBool:showCurrent] forKey:@"ShowCurrentApp"];
	[dict setObject:[NSNumber numberWithBool:quitException] forKey:@"QuitException"];
	[dict setObject:[NSNumber numberWithBool:quitSingleException] forKey:@"QuitSingleException"];
	[dict setObject:[NSNumber numberWithBool:moveBack] forKey:@"MoveBack"];
	[dict setObject:[NSNumber numberWithBool:dontMoveToFront] forKey:@"DontMoveToFront"];
	[dict setObject:[NSNumber numberWithBool:autolaunch] forKey:@"AutoLaunch"];
	[dict setObject:[NSNumber numberWithInt:launchType] forKey:@"LaunchType"];
	[dict setObject:[NSNumber numberWithInt:quitType] forKey:@"QuitType"];
	[dict setObject:[NSNumber numberWithInt:swipeType] forKey:@"SwipeType"];	
	[dict setObject:[NSNumber numberWithBool:badgePinned] forKey:@"PinnedBadge"];
}


-(id)copyWithZone:(NSZone *)zone
{
	MCIndividualSettings * cp = [[MCIndividualSettings allocWithZone:zone] init];
	cp.autoclose=autoclose;
	cp.hidden=hidden;
	cp.dimClosed=dimClosed;
	cp.alwaysDim=alwaysDim;
	cp.runningBadge=runningBadge;
	cp.showCurrent=showCurrent;
	cp.quitException=quitException;
	cp.moveBack=moveBack;
	cp.swipeType=kSTAppAndIcon;
	cp.launchType=launchType;
	cp.quitType=quitType;
	cp.swipeType=swipeType;
	cp.quitSingleException=quitSingleException;
	cp.autolaunch = autolaunch;
	cp.pinned = pinned;
	cp.badgePinned=badgePinned;
	return cp;
}

-(BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[self class]])
		return NO;
	MCIndividualSettings * ot = (MCIndividualSettings*)object;
	if (ot.autoclose!=autoclose) return NO;
	if (ot.hidden!=hidden) return NO;
	if (ot.dimClosed!=dimClosed) return NO;
	if (ot.alwaysDim!=alwaysDim) return NO;
	if (ot.runningBadge!=runningBadge) return NO;
	if (ot.showCurrent!=showCurrent) return NO;
	if (ot.quitException!=quitException) return NO;
	if (ot.moveBack!=moveBack) return NO;
	if (ot.swipeType!=swipeType) return NO;
	if (ot.launchType!=launchType) return NO;
	if (ot.quitType!=quitType) return NO;
	if (ot.quitSingleException!=quitSingleException) return NO;
	if (ot.autolaunch!=autolaunch) return NO;
	if (ot.pinned!=pinned) return NO;
	if (ot.badgePinned!=badgePinned) return NO;
	return YES;
}

@end
