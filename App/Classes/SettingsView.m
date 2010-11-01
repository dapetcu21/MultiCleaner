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

@implementation SettingsView

#pragma mark -
#pragma mark Initialization


- (id)initWithSettings:(MCIndividualSettings*)settings_ bundleID:(NSString*)bundleID_ andName:(NSString*) name_
{
	if (self=[super initWithStyle:UITableViewStyleGrouped])
	{
		settings=settings_;
		bundleID=bundleID_;
		name=name_;
		global=[bundleID isEqual:@"_global"];
		[name retain];
		[settings retain];
		[bundleID retain];
	//	cells = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[settings release];
	[name release];
	[bundleID release];
//	[cells release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title=name;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

enum kSections
{
	kAutoquitSec=0,
	kOptionsSec,
	kAlwaysDimSec,
	kAdditionalSec,
	kRearrangeSec,
	NUMSECTIONS
};

enum kRearrangeCells
{
	kMoveBackCell = 0,
	kNoMoveFrontCell,
	kLaunchTypeCell,
	NUMREARRANGECELLS
};

enum kOptionCells
{
	kRunningBadgeCell=0,
	kDimClosedCell,
	NUMOPTIONSCELLS
}; 

enum kAdditionalCells
{
	kShowCurrCell = 0,
	kQuitTypeCell,
	kSwipeTypeCell,
	kAutostartCell,
	kHiddenCell,
	kExceptionCell,
	kSingleExceptionCell,
	NUMADDCELLS
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return NUMSECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
		case kAutoquitSec:
			return 1;
		case kOptionsSec:
			return NUMOPTIONSCELLS;
		case kRearrangeSec:
			return NUMREARRANGECELLS;
		case kAdditionalSec:
			return global?NUMADDCELLS-3:NUMADDCELLS;
		case kAlwaysDimSec:
			return settings.dimClosed?1:0;
		default:
			return 0;
	}
}

- (void)modifiedDimClosed:(SwitchCell*)sender
{
	settings.dimClosed = sender.on;
	if (sender == [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kDimClosedCell inSection:kOptionsSec]])
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kAlwaysDimSec] withRowAnimation:UITableViewRowAnimationLeft];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	switch (section)
	{
		case kAutoquitSec:
			return global?
			loc(@"RemoveClosedFooter"):
			loc(@"RemoveClosedFooterIndiv");
		default:
			return nil;
	}
}

- (NSString*)switchKeyForIndexPath:(NSIndexPath*)path
{
	switch(path.section)
	{
		case kAutoquitSec:
			switch(path.row)
			{
				case 0:
					return global?@"RemoveClosed":@"RemoveClosedIndiv";
				default:
					return nil;
			}
			break;
		case kOptionsSec:
			switch(path.row)
			{
				case kRunningBadgeCell:
					return global?@"Badge":@"BadgeIndiv";
				case kDimClosedCell:
					return global?@"Dim":@"DimIndiv";
				default:
					return nil;
			}
			break;
		case kAlwaysDimSec:
			switch(path.row)
			{
				case 0:
					return global?@"AlwaysDim":@"AlwaysDimIndiv"; 
				default:
					return nil;
			}
			break;
		case kAdditionalSec:
			switch(path.row)
			{
				case kShowCurrCell:
					return global?@"ShowCurrent":@"ShowCurrentIndiv";
				case kAutostartCell:
					return global?@"Autostart":@"AutostartIndiv";
				case kHiddenCell:
					return @"Hide";
				case kExceptionCell:
					return @"AllException";
				case kSingleExceptionCell:
					return @"SingleException";
				default:
					return nil;
			}
		case kRearrangeSec:
			switch(path.row)
			{
				case kMoveBackCell:
					return global?@"MoveBack":@"MoveBackIndiv";
				case kNoMoveFrontCell:
					return @"NoMoveFront";
				default:
					return nil;
			}
		default:
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * key = [self switchKeyForIndexPath:indexPath];
	if (key)
		return tableView.rowHeight+[SwitchCell additionalCellHeightForText:loc(key)];
	NSString * text;
	NSString * detail;
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kQuitTypeCell))
	{
		text=loc(@"QuitType");
		switch(settings.quitType)
		{
			case kQTAppAndIcon:
				detail=loc(@"QTappicon");
				break;
			case kQTIcon:
				detail=loc(@"QTicon");
				break;
			case kQTApp:
				detail=loc(@"QTapp");
				break;
			case kQTAppTap:
				detail=loc(@"QT2tap");
				break;
		}
		return tableView.rowHeight + [MultiLineCell additionalCellHeightForText:text detailText:detail andStyle:UITableViewCellStyleValue1];
	}
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kSwipeTypeCell))
	{
		text=loc(@"SwipeType");
		if (settings.swipeNoQuit)
			detail=loc(@"STicon");
		else
			detail=loc(@"STapp");
		return tableView.rowHeight + [MultiLineCell additionalCellHeightForText:text detailText:detail andStyle:UITableViewCellStyleValue1];
	}
	if ((indexPath.section==kRearrangeSec)&&(indexPath.row==kLaunchTypeCell))
	{	
		text=global?
		loc(@"LaunchPos"):
		loc(@"LaunchPosIndiv");
		switch(settings.launchType)
		{
			case 0:
				detail=loc(@"LPfront");
				break;
			case 1:
				detail=loc(@"LPback");
				break;
			case 2:
				detail=loc(@"LPbeforeclosed");
				break;
		}
		return tableView.rowHeight + [MultiLineCell additionalCellHeightForText:text detailText:detail andStyle:UITableViewCellStyleValue1];
	}
	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell;
	if (((indexPath.section==kRearrangeSec)&&(indexPath.row==kLaunchTypeCell))||
		((indexPath.section==kAdditionalSec)&&(indexPath.row==kQuitTypeCell))||
		((indexPath.section==kAdditionalSec)&&(indexPath.row==kSwipeTypeCell)))
		cell = [[[MultiLineCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingsViewNormalCell"] autorelease];
	else
		cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsViewSwitchCell"] autorelease];
	
	if (indexPath.section==kAutoquitSec)
	{
		cell.textLabel.text=global?
			loc(@"RemoveClosed"):
			loc(@"RemoveClosedIndiv");
		[((SwitchCell*)cell) setOn:settings.autoclose];
		[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setAutoclose:)];
    } 
	else
	if (indexPath.section==kOptionsSec)
	{
		switch (indexPath.row)
		{
			case kRunningBadgeCell:
			{
				[((SwitchCell*)cell) setOn:settings.runningBadge];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setRunningBadge:)];
				cell.textLabel.text=global?
					loc(@"Badge"):
					loc(@"BadgeIndiv");
				break;
			}
			case kDimClosedCell:
			{
				[((SwitchCell*)cell) setOn:settings.dimClosed];
				[((SwitchCell*)cell) setTarget:self andSelector:@selector(modifiedDimClosed:)];
				cell.textLabel.text=global?
					loc(@"Dim"):
					loc(@"DimIndiv");
				break;
			}
		}
		
	}
	else
	if (indexPath.section==kAdditionalSec)
	{
		switch (indexPath.row)
		{
			case kHiddenCell:
			{
				[((SwitchCell*)cell) setOn:settings.hidden];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setHidden:)];
				cell.textLabel.text=loc(@"Hide");
				break;
			}
			case kAutostartCell:
			{
				[((SwitchCell*)cell) setOn:settings.autolaunch];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setAutolaunch:)];
				cell.textLabel.text=global?loc(@"Autostart"):loc(@"AutostartIndiv");
				break;
			}
			case kQuitTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=loc(@"QuitType");
				switch(settings.quitType)
				{
					case kQTAppAndIcon:
						cell.detailTextLabel.text=loc(@"QTappicon");
						break;
					case kQTIcon:
						cell.detailTextLabel.text=loc(@"QTicon");
						break;
					case kQTApp:
						cell.detailTextLabel.text=loc(@"QTapp");
						break;
					case kQTAppTap:
						cell.detailTextLabel.text=loc(@"QT2tap");
						break;
				}
				break;
			}
			case kSwipeTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=loc(@"SwipeType");
				if (settings.swipeNoQuit)
					cell.detailTextLabel.text=loc(@"STicon");
				else
					cell.detailTextLabel.text=loc(@"STapp");
				break;
			}
			case kShowCurrCell:
			{
				[((SwitchCell*)cell) setOn:settings.showCurrent];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setShowCurrent:)];
				cell.textLabel.text=global?
				loc(@"ShowCurrent"):
				loc(@"ShowCurrentIndiv");
				break;
			}
			case kExceptionCell:
				[((SwitchCell*)cell) setOn:settings.quitException];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setQuitException:)];
				cell.textLabel.text=loc(@"AllException");
				break;
			case kSingleExceptionCell:
				[((SwitchCell*)cell) setOn:settings.quitSingleException];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setQuitSingleException:)];
				cell.textLabel.text=loc(@"SingleException");
				break;
		}
	}
	if (indexPath.section==kRearrangeSec)
	{
		switch (indexPath.row)
		{
			case kMoveBackCell:
			{
				[((SwitchCell*)cell) setOn:settings.moveBack];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setMoveBack:)];
				cell.textLabel.text=global?
				loc(@"MoveBack"):
				loc(@"MoveBackIndiv");
				break;
			}
			case kNoMoveFrontCell:
			{
				[((SwitchCell*)cell) setOn:settings.dontMoveToFront];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setDontMoveToFront:)];
				cell.textLabel.text=loc(@"NoMoveFront");
				break;
			}
			case kLaunchTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=global?
				loc(@"LaunchPos"):
				loc(@"LaunchPosIndiv");
				switch(settings.launchType)
				{
					case 0:
						cell.detailTextLabel.text=loc(@"LPfront");
						break;
					case 1:
						cell.detailTextLabel.text=loc(@"LPback");
						break;
					case 2:
						cell.detailTextLabel.text=loc(@"LPbeforeclosed");
						break;
				}
				break;
			}
		}
	}
	if (indexPath.section==kAlwaysDimSec)
	{
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		[((SwitchCell*)cell) setOn:settings.alwaysDim];
		[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setAlwaysDim:)];
		cell.textLabel.text=global?
		loc(@"AlwaysDim"):
		loc(@"AlwaysDimIndiv");
	}
	//[cells setObject:cell forKey:[indexPath description]];
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

#define kLaunchPositionTag 2001
#define kQuitTypeTag 2002
#define kSwipeTypeTag 2003

- (void)pickerTableController:(PickerTableController *)tvc changedSelectionTo:(int)sel
{
	if (tvc.tag == kLaunchPositionTag)
		settings.launchType=sel;
	if (tvc.tag == kQuitTypeTag)
		settings.quitType=sel;
	if (tvc.tag == kSwipeTypeTag)
		settings.swipeNoQuit=(BOOL)sel;
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section==kRearrangeSec)&&(indexPath.row==kLaunchTypeCell))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = loc(@"LPtitle");
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:loc(@"LPfrontDetail"),loc(@"LPbackDetail"),loc(@"LPbeforeclosedDetail"),nil];
		vc.tag = kLaunchPositionTag;
		vc.currentSelection = settings.launchType;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kQuitTypeCell))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = loc(@"QTtitle");
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:loc(@"QTappiconDetail"),loc(@"QTappDetail"),loc(@"QTiconDetail"),loc(@"QT2tapDetail"),nil];
		vc.tag = kQuitTypeTag;
		vc.currentSelection = settings.quitType;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kSwipeTypeCell))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = loc(@"STtitle");
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:loc(@"STappDetail"),loc(@"STiconDetail"),nil];
		vc.tag = kSwipeTypeTag;
		vc.currentSelection = (int)(settings.swipeNoQuit);
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end

