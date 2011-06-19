//
//  SettingsView.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "SettingsView.h"
#import "SwitchCell.h"
#import "MCIndividualSettings.h"
#import "MultiLineCell.h"
#import "Common.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation SettingsView

#pragma mark -
#pragma mark Initialization

-(void)pinnedChanged:(TableCellSwitch*)sender
{
	NSArray * tmp = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:sender.on] forKey:bundleID];
	NSDictionary * dict = [NSDictionary dictionaryWithObject:tmp forKey:@"PinnedApps"];
	CPDistributedMessagingCenter * center = [CPDistributedMessagingCenter centerNamed:@"com.dapetcu21.MultiCleaner.center"];
	[center sendMessageName:@"pinnedChanged" userInfo:dict];
}

-(TableModel*)generateModel
{
	TableModel * _model = [[[TableModel alloc] init] autorelease];
	
	TableGroup * kPinnedSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kAutoquitSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kOptionsSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kAdditionalSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kRearrangeSec = [[[TableGroup alloc] init] autorelease];
	
	
	TableCellSwitch * kPinnedCell = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellSwitch * kAutoquitCell = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellSwitch * kRunningBadgeCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kPinnedBadgeCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kDimClosedCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kAlwaysDimCell = [[[TableCellSwitch alloc] init] autorelease];
	
	
	TableCellSwitch * kShowCurrCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellChoice * kQuitTypeCell = [[[TableCellChoice alloc] init] autorelease];
	TableCellChoice * kSwipeTypeCell = [[[TableCellChoice alloc] init] autorelease];
	TableCellSwitch * kAutostartCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kHiddenCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kQuitAppRemoveCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kExceptionCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSingleExceptionCell = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellSwitch * kMoveBackCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kNoMoveFrontCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellChoice * kLaunchTypeCell = [[[TableCellChoice alloc] init] autorelease];
	
	
	//kPinnedSec
	kPinnedCell.text = loc(@"Pinned");
	kPinnedCell.on = settings.pinned;
	[kPinnedCell addTarget:settings andBOOLPropertySetter:@selector(setPinned:)];
	[kPinnedCell addTarget:self andSelector:@selector(pinnedChanged:)];
	[kPinnedCell addTarget:kAutoquitSec andBOOLPropertySetter:@selector(setHidden:)];
	[kPinnedCell addTarget:kShowCurrCell andBOOLPropertySetter:@selector(setHidden:)];
	[kPinnedCell addTarget:kQuitTypeCell andBOOLPropertySetter:@selector(setHidden:)];
	//[kPinnedCell addTarget:kSwipeTypeCell andBOOLPropertySetter:@selector(setHidden:)];
	[kPinnedCell addTarget:kQuitAppRemoveCell andBOOLPropertySetter:@selector(setHidden:)];
	[kPinnedCell addTarget:kHiddenCell andBOOLPropertySetter:@selector(setHidden:)];
	[kPinnedCell addTarget:kRearrangeSec andBOOLPropertySetter:@selector(setHidden:)];
	
	kPinnedSec.footer = loc(@"PinnedFooter");
	[kPinnedSec addCell:kPinnedCell];
	
	
	//kAutoquitSec
	kAutoquitCell.text = global?loc(@"RemoveClosed"):loc(@"RemoveClosedIndiv");
	kAutoquitCell.on = settings.autoclose;
	[kAutoquitCell addTarget:settings andBOOLPropertySetter:@selector(setAutoclose:)];
	
	kAutoquitSec.footer=global?loc(@"RemoveClosedFooter"):loc(@"RemoveClosedFooterIndiv");
	kAutoquitSec.hidden  = settings.pinned;
	[kAutoquitSec addCell:kAutoquitCell];
	
	
	//kOptionsSec
	kRunningBadgeCell.text = global?loc(@"Badge"):loc(@"BadgeIndiv");
	kRunningBadgeCell.on = settings.runningBadge;
	[kRunningBadgeCell addTarget:settings andBOOLPropertySetter:@selector(setRunningBadge:)];
	
	kPinnedBadgeCell.text = global?loc(@"BadgePinned"):loc(@"BadgePinnedIndiv");
	kPinnedBadgeCell.on = settings.badgePinned;
	[kPinnedBadgeCell addTarget:settings andBOOLPropertySetter:@selector(setBadgePinned:)];
	
	kDimClosedCell.text = global?loc(@"Dim"):loc(@"DimIndiv");
	kDimClosedCell.on = settings.dimClosed;
	[kDimClosedCell addTarget:settings andBOOLPropertySetter:@selector(setDimClosed:)];
	[kDimClosedCell addTarget:kAlwaysDimCell andReverseBOOLPropertySetter:@selector(setHidden:)];
	
	kAlwaysDimCell.text = global?loc(@"AlwaysDim"):loc(@"AlwaysDimIndiv");
	kAlwaysDimCell.on = settings.alwaysDim;
	[kAlwaysDimCell addTarget:settings andBOOLPropertySetter:@selector(setAlwaysDim:)];
	kAlwaysDimCell.hidden = !settings.dimClosed;
	
	[kOptionsSec addCell:kRunningBadgeCell];
	[kOptionsSec addCell:kPinnedBadgeCell];
	[kOptionsSec addCell:kDimClosedCell];
	[kOptionsSec addCell:kAlwaysDimCell];
	
	
	//kAdditionalSec
	kShowCurrCell.text = global?loc(@"ShowCurrent"):loc(@"ShowCurrentIndiv");
	kShowCurrCell.on = settings.showCurrent;
	kShowCurrCell.hidden =settings.pinned;
	[kShowCurrCell addTarget:settings andBOOLPropertySetter:@selector(setShowCurrent:)];
	
	kQuitTypeCell.text = loc(@"QuitType");
	kQuitTypeCell.title = loc(@"QTtitle");
	kQuitTypeCell.choices = [NSArray arrayWithObjects:loc(@"QTappicon"),loc(@"QTapp"),loc(@"QTicon"),loc(@"QT2tap"),nil];
	kQuitTypeCell.detailChoices = [NSArray arrayWithObjects:loc(@"QTappiconDetail"),loc(@"QTappDetail"),loc(@"QTiconDetail"),loc(@"QT2tapDetail"),nil]; 
	kQuitTypeCell.state = settings.quitType;
	kQuitTypeCell.hidden = settings.pinned;
	[kQuitTypeCell addTarget:settings andIntPropertySetter:@selector(setQuitType:)];
	
	kSwipeTypeCell.text = loc(@"SwipeType");
	kSwipeTypeCell.title = loc(@"STtitle");
	kSwipeTypeCell.choices = [NSArray arrayWithObjects:loc(@"STapp"),loc(@"STicon"),loc(@"STonlyapp"),loc(@"STnothing"),nil];
	kSwipeTypeCell.detailChoices = [NSArray arrayWithObjects:loc(@"STappDetail"),loc(@"STiconDetail"),loc(@"STonlyappDetail"),loc(@"STnothingDetail"),nil];
	kSwipeTypeCell.state = settings.swipeType;
	//kSwipeTypeCell.hidden = settings.pinned;
	[kSwipeTypeCell addTarget:settings andIntPropertySetter:@selector(setSwipeType:)];
	
	kAutostartCell.text = global?loc(@"Autostart"):loc(@"AutostartIndiv");
	kAutostartCell.on = settings.autolaunch;
	[kAutostartCell addTarget:settings andBOOLPropertySetter:@selector(setAutolaunch:)];
	
	kHiddenCell.text = loc(@"Hide");
	kHiddenCell.on = settings.hidden;
	[kHiddenCell addTarget:settings andBOOLPropertySetter:@selector(setHidden:)];
	kHiddenCell.hidden = settings.pinned;
	
	kQuitAppRemoveCell.text = global?loc(@"QuitAppRemovesIcon"):loc(@"QuitAppRemovesIconIndiv");
	kQuitAppRemoveCell.on = settings.removeOnQuitApp;
	[kQuitAppRemoveCell addTarget:settings andBOOLPropertySetter:@selector(setRemoveOnQuitApp:)];
	kQuitAppRemoveCell.hidden = settings.pinned;
	
	kExceptionCell.text = loc(@"AllException");
	kExceptionCell.on = settings.quitException;
	[kExceptionCell addTarget:settings andBOOLPropertySetter:@selector(setQuitException:)];
	
	kSingleExceptionCell.text = loc(@"SingleException");
	kSingleExceptionCell.on = settings.quitSingleException;
	[kSingleExceptionCell addTarget:settings andBOOLPropertySetter:@selector(setQuitSingleException:)];
	
	[kAdditionalSec addCell:kShowCurrCell];
	[kAdditionalSec addCell:kQuitTypeCell];
	[kAdditionalSec addCell:kSwipeTypeCell];
	[kAdditionalSec addCell:kAutostartCell];
	[kAdditionalSec addCell:kQuitAppRemoveCell];
	if (!global)
	{
		[kAdditionalSec addCell:kHiddenCell];
		[kAdditionalSec addCell:kExceptionCell];
		[kAdditionalSec addCell:kSingleExceptionCell];
	}
	
	
	//kRearrangeSec
	kMoveBackCell.text = global?loc(@"MoveBack"):loc(@"MoveBackIndiv"); 
	kMoveBackCell.on = settings.moveBack;
	[kMoveBackCell addTarget:settings andBOOLPropertySetter:@selector(setMoveBack:)];
	
	kNoMoveFrontCell.text = loc(@"NoMoveFront");
	kNoMoveFrontCell.on = settings.dontMoveToFront;
	[kNoMoveFrontCell addTarget:settings andBOOLPropertySetter:@selector(setDontMoveToFront:)];
	
	kLaunchTypeCell.text = global?loc(@"LaunchPos"):loc(@"LaunchPosIndiv");
	kLaunchTypeCell.title = loc(@"LPtitle");
	kLaunchTypeCell.choices = [NSArray arrayWithObjects:loc(@"LPfront"),loc(@"LPback"),loc(@"LPbeforeclosed"),nil];
	kLaunchTypeCell.detailChoices = [NSArray arrayWithObjects:loc(@"LPfrontDetail"),loc(@"LPbackDetail"),loc(@"LPbeforeclosedDetail"),nil];
	kLaunchTypeCell.state = settings.launchType;
	[kLaunchTypeCell addTarget:settings andIntPropertySetter:@selector(setLaunchType:)];
	
	kRearrangeSec.hidden = settings.pinned;
	[kRearrangeSec addCell:kMoveBackCell];
	[kRearrangeSec addCell:kNoMoveFrontCell];
	[kRearrangeSec addCell:kLaunchTypeCell];
	
	
	//adding groups to model
	if (!global)
		[_model addGroup:kPinnedSec];
	[_model addGroup:kAutoquitSec];
	[_model addGroup:kOptionsSec];
	[_model addGroup:kAdditionalSec];
	[_model addGroup:kRearrangeSec];
	return _model;
}

- (id)initWithSettings:(MCIndividualSettings*)settings_ bundleID:(NSString*)bundleID_ andName:(NSString*) name_
{
	if ((self=[super initWithStyle:UITableViewStyleGrouped]))
	{
		settings=settings_;
		bundleID=bundleID_;
		self.title = name_;
		global=[bundleID isEqual:@"_global"];
		[settings retain];
		[bundleID retain];
		self.model = [self generateModel];
	}
	return self;
}

- (void)dealloc {
	[settings release];
	[bundleID release];
    [super dealloc];
}

@end

