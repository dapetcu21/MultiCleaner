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
			@"Automatically remove closed apps from the multitask bar":
			@"Automatically remove the app from the multitask bar when quit";
		default:
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*UITableViewCell * cell = [cells objectForKey:[indexPath description]];
	if ([cell isKindOfClass:[SwitchCell class]])
	{
		return tableView.rowHeight+[(SwitchCell*)cell additionalCellHeightForWidth:300];
	}*/
	if ((indexPath.section==kRearrangeSec)&&(indexPath.row==kMoveBackCell))
		return floor(1.5*tableView.rowHeight);
	if ((indexPath.section==kRearrangeSec)&&(indexPath.row==kNoMoveFrontCell))
		return floor(2.0*tableView.rowHeight);
	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell;
	if (((indexPath.section==kRearrangeSec)&&(indexPath.row==kLaunchTypeCell))||
		((indexPath.section==kAdditionalSec)&&(indexPath.row==kQuitTypeCell))||
		((indexPath.section==kAdditionalSec)&&(indexPath.row==kSwipeTypeCell)))
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	else
		cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	if (indexPath.section==kAutoquitSec)
	{
		cell.textLabel.text=global?
			@"Remove closed apps":
			@"Remove on quit";
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
					@"Badge running apps":
					@"Badge if running";
				break;
			}
			case kDimClosedCell:
			{
				[((SwitchCell*)cell) setOn:settings.dimClosed];
				[((SwitchCell*)cell) setTarget:self andSelector:@selector(modifiedDimClosed:)];
				cell.textLabel.text=global?
					@"Dim closed apps":
					@"Dim icon if closed";
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
				cell.textLabel.text=@"Hide app from bar";
				break;
			}
			case kQuitTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=@"Red button action";
				switch(settings.quitType)
				{
					case kQTAppAndIcon:
						cell.detailTextLabel.text=@"app&icon";
						break;
					case kQTIcon:
						cell.detailTextLabel.text=@"remove icon";
						break;
					case kQTApp:
						cell.detailTextLabel.text=@"close app";
						break;
				}
				break;
			}
			case kSwipeTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=@"Swipe to quit action";
				if (settings.swipeNoQuit)
					cell.detailTextLabel.text=@"rem icon";
				else
					cell.detailTextLabel.text=@"quit";
				break;
			}
			case kShowCurrCell:
			{
				[((SwitchCell*)cell) setOn:settings.showCurrent];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setShowCurrent:)];
				cell.textLabel.text=global?
				@"Show current app":
				@"Show if frontmost";
				break;
			}
			case kExceptionCell:
				[((SwitchCell*)cell) setOn:settings.quitException];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setQuitException:)];
				cell.textLabel.text=@"\"Quit all\" exception";
				break;
			case kSingleExceptionCell:
				[((SwitchCell*)cell) setOn:settings.quitSingleException];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setQuitSingleException:)];
				cell.textLabel.text=@"\"Quit app\" exception";
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
				@"Move closed apps to the back of the bar":
				@"Move to the back of the bar when closed";
				break;
			}
			case kNoMoveFrontCell:
			{
				[((SwitchCell*)cell) setOn:settings.dontMoveToFront];
				[((SwitchCell*)cell) setTarget:settings andPropertySetter:@selector(setDontMoveToFront:)];
				cell.textLabel.text=@"Don't move icon to the front of the bar when switching";
				break;
			}
			case kLaunchTypeCell:
			{
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text=global?
				@"On app launch":
				@"When launched";
				switch(settings.launchType)
				{
					case 0:
						cell.detailTextLabel.text=@"add to front";
						break;
					case 1:
						cell.detailTextLabel.text=@"add to back";
						break;
					case 2:
						cell.detailTextLabel.text=@"add before closed";
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
		@"Dim all apps":
		@"Always dim";
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
		vc.title = @"Launch position";
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:@"Front of the bar (default)",@"Back of the bar",@"Before closed apps moved back",nil];
		vc.tag = kLaunchPositionTag;
		vc.currentSelection = settings.launchType;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kQuitTypeCell))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = @"Quit button behavior";
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:@"Quit app and remove icon",@"Quit app and leave icon",@"Just remove icon",nil];
		vc.tag = kQuitTypeTag;
		vc.currentSelection = settings.quitType;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	if ((indexPath.section==kAdditionalSec)&&(indexPath.row==kSwipeTypeCell))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = @"Swipe to quit behavior";
		vc.delegate = self;
		vc.items = [NSArray arrayWithObjects:@"Quit app and remove icon",@"Just remove icon",nil];
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

