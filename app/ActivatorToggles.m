//
//  ActivatorToggles.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "ActivatorToggles.h"
#import "MCSettings.h"
#import "MCIndividualSettings.h"
#import "SwitchCell.h"
#import "MultiLineCell.h"
#import "Common.h"
#import <libactivator/libactivator.h>

@implementation ActivatorToggles

-(TableModel*)generateModel
{
	MCSettings * settings = [MCSettings sharedInstance];
	TableModel * _model = [[[TableModel alloc] init] autorelease];
	
	TableGroup * CloseAppSection = [[[TableGroup alloc] init] autorelease];
	TableGroup * kQuitAllSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kSwitcherSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kLastSec = [[[TableGroup alloc] init] autorelease];
	TableGroup * kJustMinSec = [[[TableGroup alloc] init] autorelease];
	
	TableCellActivator * CAActivatorCell = [[[TableCellActivator alloc] init] autorelease];
	TableCellSwitch * CAHidePromptCell = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * CAConfirmQuitCell = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellActivator * kQAActivator = [[[TableCellActivator alloc] init] autorelease];
	TableCellSwitch * kQAQuitCurrent = [[[TableCellSwitch alloc] init] autorelease];
	TableCellChoice * kQAIconBehavior = [[[TableCellChoice alloc] init] autorelease];
	TableCellSwitch * kQAHidePrompt = [[[TableCellSwitch alloc] init] autorelease];
	TableCellSwitch * kQAConfirm = [[[TableCellSwitch alloc] init] autorelease];
	
	TableCellActivator * kSwitcherActivator = [[[TableCellActivator alloc] init] autorelease];
	TableCellActivator * kSwitcherEditActivator = [[[TableCellActivator alloc] init] autorelease];
	
	TableCellActivator * kLastActivator = [[[TableCellActivator alloc] init] autorelease];
	
	TableCellActivator * kJMActivator = [[[TableCellActivator alloc] init] autorelease];
	TableCellSwitch * kJMHidePrompt = [[[TableCellSwitch alloc] init] autorelease];
	
	//CloseAppSection
	
	CAActivatorCell.text = loc(@"QuitSingle");
	CAActivatorCell.listenerName = @"com.dapetcu21.MultiCleaner";
	
	CAConfirmQuitCell.text = loc(@"ConfirmQuit");
	CAConfirmQuitCell.on = settings.confirmQuitSingle;
	[CAConfirmQuitCell addTarget:settings andBOOLPropertySetter:@selector(setConfirmQuitSingle:)];
	
	CAHidePromptCell.text = loc(@"HidePrompt");
	CAHidePromptCell.on = settings.hidePromptSingle;
	[CAHidePromptCell addTarget:settings andBOOLPropertySetter:@selector(setHidePromptSingle:)];
	
	[CloseAppSection addCell:CAActivatorCell];
	[CloseAppSection addCell:CAHidePromptCell];
	[CloseAppSection addCell:CAConfirmQuitCell];
	
	//kQuitAllSec
	kQAActivator.text = loc(@"QuitAll");
	kQAActivator.listenerName = @"com.dapetcu21.MultiCleaner_quitAllApps";
	
	kQAQuitCurrent.text = loc(@"QuitCurrent");
	kQAQuitCurrent.on = settings.quitCurrentApp;
	[kQAQuitCurrent addTarget:settings andBOOLPropertySetter:@selector(setQuitCurrentApp:)];
	
	kQAIconBehavior.text = loc(@"QuitMode");
	kQAIconBehavior.title = loc(@"QMtitle");
	kQAIconBehavior.choices = [NSArray arrayWithObjects:loc(@"QMRemove"),loc(@"QMUseRules"),nil];
	kQAIconBehavior.detailChoices = [NSArray arrayWithObjects:loc(@"QMRemoveDetail"),loc(@"QMUseRulesDetail"),nil];
	kQAIconBehavior.state = settings.quitMode;
	[kQAIconBehavior addTarget:settings andIntPropertySetter:@selector(setQuitMode:)];
	
	kQAHidePrompt.text = loc(@"HidePrompt");
	kQAHidePrompt.on = settings.hidePrompt;
	[kQAHidePrompt addTarget:settings andBOOLPropertySetter:@selector(setHidePrompt:)];
	
	kQAConfirm.text = loc(@"ConfirmQuit");
	kQAConfirm.on = settings.confirmQuit;
	[kQAConfirm addTarget:settings andBOOLPropertySetter:@selector(setConfirmQuit:)];
	
	[kQuitAllSec addCell:kQAActivator];
	[kQuitAllSec addCell:kQAQuitCurrent];
	[kQuitAllSec addCell:kQAIconBehavior];
	[kQuitAllSec addCell:kQAHidePrompt];
	[kQuitAllSec addCell:kQAConfirm];
	
	//kJustMinSec
	kJMActivator.text = loc(@"JustMinActivator");
	kJMActivator.listenerName = @"com.dapetcu21.MultiCleaner_justMin";
	
	kJMHidePrompt.text = loc(@"JustMinHidePrompt");
	kJMHidePrompt.on = settings.hidePromptMin;
	[kJMHidePrompt addTarget:settings andBOOLPropertySetter:@selector(setHidePromptMin:)];
	
	[kJustMinSec addCell:kJMActivator];
	[kJustMinSec addCell:kJMHidePrompt];
	
	
	//kSwitcherSec
	kSwitcherActivator.text = loc(@"SwitcherActivator");
	kSwitcherActivator.listenerName = @"com.dapetcu21.MultiCleaner_openBar";
	
	kSwitcherEditActivator.text = loc(@"SwitcherEditActivator");
	kSwitcherEditActivator.listenerName = @"com.dapetcu21.MultiCleaner_openEdit";
	
	[kSwitcherSec addCell:kSwitcherActivator];
	[kSwitcherSec addCell:kSwitcherEditActivator];
	[kSwitcherSec setFooter:loc(@"SwitcherLockFooter")];
	
	//kLastSec
	kLastActivator.text = loc(@"LastApp");
	kLastActivator.listenerName = @"com.dapetcu21.MultiCleaner_lastClosed";
	
	[kLastSec addCell:kLastActivator];
	
	[_model addGroup:kQuitAllSec];
	[_model addGroup:CloseAppSection];
	[_model addGroup:kJustMinSec];
	[_model addGroup:kSwitcherSec];
	[_model addGroup:kLastSec];
	
	return _model;
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		self.model = [self generateModel];
		self.title = loc(@"ActivatorTogglesTitle");
	}
    return self;
}

@end

