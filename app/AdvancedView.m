//
//  AdvancedView.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "AdvancedView.h"
#import "MCSettings.h"
#import "MCIndividualSettings.h"
#import "SwitchCell.h"
#import "MultiLineCell.h"
#import "Common.h"
#import <libactivator/libactivator.h>

@implementation AdvancedView

-(TableModel*)generateModel
{
	MCSettings * settings = [MCSettings sharedInstance];
	TableModel * _model = [[[TableModel alloc] init] autorelease];
	
	TableGroup * kStartupSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kMiscSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kReorderSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kIconSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kSBIconSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kLegacySec = [[[TableGroup alloc] init] autorelease];

	
	TableCellSwitch * kSUEditMode = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUPinned = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUPinnedOnlyEmpty = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUiPod = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUiPodOnlyPlaying = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUiPodOnlyEmpty = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSUiPodUnlessMusic = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellChoice * kMSCBadgePos = [[[TableCellChoice alloc] init] autorelease];
	TableCellSwitch * kMSCDontWriggle = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kMSCAllowTap = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kMSCNoEdit = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kMSCFastQuit = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kMSCBypassPhone = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellSwitch * kROInEditMode = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kROOutsideEditMode = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kROSwipeQuit = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellSwitch * kIconCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellChoice * kSBSettingsCell = [[[TableCellChoice alloc] init] autorelease];

	TableCellSwitch * kSBIEnable = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kSBIShow = [[[TableCellSwitch alloc] init] autorelease];
	TableCellChoice * kSBIPosition = [[[TableCellChoice alloc] init] autorelease];
	
	TableCellSwitch * kLegacyCell = [[[TableCellSwitch alloc] init] autorelease];
	
	
	//kStartupSec
	kSUEditMode.text = loc(@"StartEdit"); 
	kSUEditMode.on = settings.startupEdit;
	[kSUEditMode addTarget:settings andBOOLPropertySetter:@selector(setStartupEdit:)];
	
	kSUPinned.text = loc(@"StartPinned");
	kSUPinned.on = settings.startupPinned;
	[kSUPinned addTarget:settings andBOOLPropertySetter:@selector(setStartupPinned:)];
	[kSUPinned addTarget:kSUPinnedOnlyEmpty andReverseBOOLPropertySetter:@selector(setHidden:)];
	 
	kSUPinnedOnlyEmpty.text = loc(@"StartPinnedOnlyEmpty");
	kSUPinnedOnlyEmpty.on = settings.pinnedOnlyWhenEmpty;
	[kSUPinnedOnlyEmpty addTarget:settings andBOOLPropertySetter:@selector(setPinnedOnlyWhenEmpty:)];
	kSUPinnedOnlyEmpty.hidden = !settings.startupPinned;
	
	kSUiPod.text = loc(@"StartiPod");
	kSUiPod.on = settings.startupiPod;
	[kSUiPod addTarget:settings andBOOLPropertySetter:@selector(setStartupiPod:)];
	[kSUiPod addTarget:kSUiPodOnlyPlaying andReverseBOOLPropertySetter:@selector(setHidden:)];
	[kSUiPod addTarget:kSUiPodOnlyEmpty andReverseBOOLPropertySetter:@selector(setHidden:)];
	[kSUiPod addTarget:kSUiPodUnlessMusic andReverseBOOLPropertySetter:@selector(setHidden:)];
	
	kSUiPodOnlyPlaying.text = loc(@"StartiPodOnlyPlaying");
	kSUiPodOnlyPlaying.on = settings.onlyWhenPlaying;
	[kSUiPodOnlyPlaying addTarget:settings andBOOLPropertySetter:@selector(setOnlyWhenPlaying:)];
	kSUiPodOnlyPlaying.hidden = !settings.startupiPod;
	
	kSUiPodOnlyEmpty.text = loc(@"StartiPodOnlyEmpty");
	kSUiPodOnlyEmpty.on = settings.onlyWhenEmpty;
	[kSUiPodOnlyEmpty addTarget:settings andBOOLPropertySetter:@selector(setOnlyWhenEmpty:)];
	kSUiPodOnlyEmpty.hidden = !settings.startupiPod;
	
	kSUiPodUnlessMusic.text = loc(@"UnlessMusic");
	kSUiPodUnlessMusic.on = settings.unlessMusic;
	[kSUiPodUnlessMusic addTarget:settings andBOOLPropertySetter:@selector(setUnlessMusic:)];
	kSUiPodUnlessMusic.hidden = !settings.startupiPod;
	
	[kStartupSec addCell:kSUEditMode];
	[kStartupSec addCell:kSUPinned];
	[kStartupSec addCell:kSUPinnedOnlyEmpty];
	[kStartupSec addCell:kSUiPod];
	[kStartupSec addCell:kSUiPodOnlyPlaying];
	[kStartupSec addCell:kSUiPodOnlyEmpty];
	[kStartupSec addCell:kSUiPodUnlessMusic];
	
	
	//kMiscSec
	kMSCBadgePos.text = loc(@"BadgeCorner");
	kMSCBadgePos.title = loc(@"BCtitle");
	kMSCBadgePos.choices = [NSArray arrayWithObjects:loc(@"BCtopleft"),loc(@"BCtopright"),loc(@"BCbottomright"),loc(@"BCbottomleft"),nil];
	kMSCBadgePos.detailChoices = [NSArray arrayWithObjects:loc(@"BCtopleftDetail"),loc(@"BCtoprightDetail"),loc(@"BCbottomrightDetail"),loc(@"BCbottomleftDetail"),nil]; 
	kMSCBadgePos.state = settings.badgeCorner;
	[kMSCBadgePos addTarget:settings andIntPropertySetter:@selector(setBadgeCorner:)];
	
	kMSCDontWriggle.text = loc(@"DontWriggle");
	kMSCDontWriggle.on = settings.dontWriggle;
	[kMSCDontWriggle addTarget:settings andBOOLPropertySetter:@selector(setDontWriggle:)];
	
	kMSCAllowTap.text = loc(@"LaunchFromEdit");
	kMSCAllowTap.on = settings.allowTap;
	[kMSCAllowTap addTarget:settings andBOOLPropertySetter:@selector(setAllowTap:)];
	
	kMSCNoEdit.text = loc(@"NoEditMode");
	kMSCNoEdit.on = settings.noEditMode;
	[kMSCNoEdit addTarget:settings andBOOLPropertySetter:@selector(setNoEditMode:)];
	
	kMSCFastQuit.text = loc(@"FastExit");
	kMSCFastQuit.on = settings.fastExit;
	[kMSCFastQuit addTarget:settings andBOOLPropertySetter:@selector(setFastExit:)];
	
	kMSCBypassPhone.text = loc(@"BypassPhone");
	kMSCBypassPhone.on = settings.bypassPhone;
	[kMSCBypassPhone addTarget:settings andBOOLPropertySetter:@selector(setBypassPhone:)];
	
	[kMiscSec addCell:kMSCBadgePos];
	[kMiscSec addCell:kMSCDontWriggle];
	[kMiscSec addCell:kMSCAllowTap];
	[kMiscSec addCell:kMSCNoEdit];
	[kMiscSec addCell:kMSCFastQuit];
	if ([[UIDevice currentDevice].model isEqual:@"iPhone"])
		[kMiscSec addCell:kMSCBypassPhone];
	
	//kReorderSec
	kROInEditMode.text = loc(@"ReorderEdit");
	kROInEditMode.on = settings.reorderEdit;
	[kROInEditMode addTarget:settings andBOOLPropertySetter:@selector(setReorderEdit:)];
	
	kROOutsideEditMode.text = loc(@"ReorderNonEdit");
	kROOutsideEditMode.on = settings.reorderNonEdit;
	[kROOutsideEditMode addTarget:settings andBOOLPropertySetter:@selector(setReorderNonEdit:)];
	
	kROSwipeQuit.text = loc(@"SwipeToQuit");
	kROSwipeQuit.on = settings.swipeQuit;
	[kROSwipeQuit addTarget:settings andBOOLPropertySetter:@selector(setSwipeQuit:)];
	
	[kReorderSec addCell:kROInEditMode];
	[kReorderSec addCell:kROOutsideEditMode];
	[kReorderSec addCell:kROSwipeQuit];
	kReorderSec.footer = loc(@"SwipeToQuitFooter");
	
	
	//kIconSec
	kIconCell.text = loc(@"SBIcon");
	kIconCell.on = settings.sbIcon;
	[kIconCell addTarget:settings andBOOLPropertySetter:@selector(setSbIcon:)];

	kSBSettingsCell.text = loc(@"SBSettingsType");
	kSBSettingsCell.title = loc(@"SBSTtitle");
	kSBSettingsCell.choices = [NSArray arrayWithObjects:loc(@"SBSTToggle"),loc(@"SBSTQuit"),nil];
	kSBSettingsCell.detailChoices = [NSArray arrayWithObjects:loc(@"SBSTToggleDetail"),loc(@"SBSTQuitDetail"),nil]; 
	kSBSettingsCell.state = settings.toggleType;
	[kSBSettingsCell addTarget:settings andIntPropertySetter:@selector(setToggleType:)];
	
	[kIconSec addCell:kIconCell];
	[kIconSec addCell:kSBSettingsCell];
	
	
	//kSBIconSec
	kSBIEnable.text = loc(@"SBIEnable");
	kSBIEnable.on = !settings.sbIconSettings.hidden;
	[kSBIEnable addTarget:settings.sbIconSettings andReverseBOOLPropertySetter:@selector(setHidden:)];
	
	kSBIShow.text = loc(@"SBIShow");
	kSBIShow.on = !settings.sbIconSettings.autoclose;
	[kSBIShow addTarget:settings.sbIconSettings andReverseBOOLPropertySetter:@selector(setAutoclose:)];
	
	kSBIPosition.text = loc(@"SBIPosition"); 
	kSBIPosition.title = loc(@"SBIPositionTitle");
	kSBIPosition.choices = [NSArray arrayWithObjects:loc(@"LPfront"),loc(@"LPback"),loc(@"LPbeforeclosed"),nil];
	kSBIPosition.detailChoices = [NSArray arrayWithObjects:loc(@"LPfrontDetail"),loc(@"LPbackDetail"),loc(@"LPbeforeclosedDetail"),nil];
	kSBIPosition.state = settings.sbIconSettings.launchType;
	[kSBIPosition addTarget:settings.sbIconSettings andIntPropertySetter:@selector(setLaunchType:)];
	
 	[kSBIconSec addCell:kSBIEnable];
	[kSBIconSec addCell:kSBIShow];
	[kSBIconSec addCell:kSBIPosition];
	kSBIconSec.header = loc(@"SBIHeader");
	
	
	//kLegacySec
	kLegacyCell.text = loc(@"LegacyQuitAll");
	kLegacyCell.on = settings.legacyMode;
	[kLegacyCell addTarget:settings andBOOLPropertySetter:@selector(setLegacyMode:)];
	
	kLegacySec.footer = loc(@"LegacyQuitAllFooter"); 
	[kLegacySec addCell:kLegacyCell];
	
	
	[_model addGroup:kStartupSec];
	[_model addGroup:kMiscSec];
	[_model addGroup:kReorderSec];
	[_model addGroup:kIconSec];
	[_model addGroup:kSBIconSec];
	[_model addGroup:kLegacySec];
	
	return _model;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		self.model = [self generateModel];
		self.title = loc(@"AdvancedSettingsTitle");
	}
    return self;
}

@end

