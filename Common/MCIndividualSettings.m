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
@synthesize moveBack;
@synthesize dontMoveToFront;
@synthesize launchType;

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
	autoclose = YES;
	hidden = NO;
	dimClosed = NO;
	alwaysDim = NO;
	runningBadge = NO;
	showCurrent = NO;
	quitException = NO;
	moveBack = NO;
	dontMoveToFront = NO;
	launchType = kLTFront;
}

-(void)loadFromDict:(NSDictionary*)dict
{
	[self reloadDefaults];
	
	NSNumber * num;
	
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
	
	num = [dict objectForKey:@"MoveBack"];
	if ([num isKindOfClass:[NSNumber class]])
		moveBack = [num boolValue];
	
	num = [dict objectForKey:@"DontMoveToFront"];
	if ([num isKindOfClass:[NSNumber class]])
		dontMoveToFront = [num boolValue];
	
	num = [dict objectForKey:@"LaunchType"];
	if ([num isKindOfClass:[NSNumber class]])
		launchType = [num intValue];
	
	if ((launchType>=NUMLAUNCHTYPES)||(launchType<0))
		launchType = kLTFront;
	
}

-(void)saveToDict:(NSMutableDictionary*)dict
{
	[dict setObject:[NSNumber numberWithBool:autoclose] forKey:@"Autoclose"];
	[dict setObject:[NSNumber numberWithBool:hidden] forKey:@"Hidden"];
	[dict setObject:[NSNumber numberWithBool:dimClosed] forKey:@"DimClosed"];
	[dict setObject:[NSNumber numberWithBool:runningBadge] forKey:@"RunningBadge"];
	[dict setObject:[NSNumber numberWithBool:showCurrent] forKey:@"ShowCurrentApp"];
	[dict setObject:[NSNumber numberWithBool:quitException] forKey:@"QuitException"];
	[dict setObject:[NSNumber numberWithBool:moveBack] forKey:@"MoveBack"];
	[dict setObject:[NSNumber numberWithBool:dontMoveToFront] forKey:@"DontMoveToFront"];
	[dict setObject:[NSNumber numberWithInt:launchType] forKey:@"LaunchType"];
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
	cp.dontMoveToFront=dontMoveToFront;
	cp.launchType=launchType;
	return cp;
}

@end