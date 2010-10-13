//
//  AdvancedView.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "AdvancedView.h"
#import "MCSettings.h"
#import "SwitchCell.h"
#import <libactivator/libactivator.h>

@implementation AdvancedView


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Advanced settings";
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

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
enum kAdvancedSections {
	kQuitAllSec = 0,
	kStartupSec,
	kMiscSec,
	kReorderSec,
	NUMADVANCEDSECTIONS
};
enum kQuitAllCells {
	kQAActivator = 0,
	kQAQuitCurrent,
	kQAIconBehavior,
	kQAHidePrompt,
	kQAConfirm,
	NUMQACELLS
};
enum kStartupCells {
	kSUEditMode= 0,
	kSUiPod,
	kSUiPodOnlyPlaying,
	NUMSTARTUPCELLS
};
enum kMiscCells
{
	kMSCBadgePos = 0,
	kMSCDontWriggle,
	kMSCAllowTap,
	kMSCNoEdit,
	kMSCFastQuit,
	NUMMISCCELLS
};
enum kReorderCells
{
	kROInEditMode,
	kROOutsideEditMode,
	kROSwipeQuit,
	NUMREORDERCELLS
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((indexPath.section==kQuitAllSec)&&(indexPath.row==kQAActivator))
		return floor(1.5*tableView.rowHeight);
	if ((indexPath.section==kMiscSec)&&(indexPath.row==kMSCFastQuit))
		return floor(1.5*tableView.rowHeight);
	if ((indexPath.section==kMiscSec)&&(indexPath.row==kMSCAllowTap))
		return floor(1.5*tableView.rowHeight);
	if ((indexPath.section==kReorderSec)&&(indexPath.row==kROSwipeQuit))
		return floor(1.5*tableView.rowHeight);
	return tableView.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return NUMADVANCEDSECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kQuitAllSec:
			return NUMQACELLS;
		case kStartupSec:
			return NUMSTARTUPCELLS-(([MCSettings sharedInstance].startupiPod)?0:1);
		case kMiscSec:
			return NUMMISCCELLS;
		case kReorderSec:
			return NUMREORDERCELLS;
		default:
			return 0;
	}
}

-(void)setiPodStartup:(SwitchCell*)sender
{
	[MCSettings sharedInstance].startupiPod = sender.on;
	NSArray * rows = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:kSUiPodOnlyPlaying inSection:kStartupSec]];
	if (sender.on)
		[self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationLeft];
	else
		[self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationLeft];
}

NSString * kCorners[4]={@"Top-left",@"Top-right",@"Bottom-right",@"Bottom-left"};

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    switch (indexPath.section) {
		case kQuitAllSec:
			switch (indexPath.row) {
				case kQAActivator:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
					cell.textLabel.text = @"Quit all apps";
					cell.detailTextLabel.text = @"Activator trigger";
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case kQAQuitCurrent:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setQuitCurrentApp:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].quitCurrentApp;
					cell.textLabel.text = @"Also quit current app";
					break;
				case kQAHidePrompt:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setHidePrompt:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].hidePrompt;
					cell.textLabel.text = @"Hide prompt";
					break;
				case kQAConfirm:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setConfirmQuit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].confirmQuit;
					cell.textLabel.text = @"Confirm quit";
					break;
				case kQAIconBehavior:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
					cell.textLabel.text = @"Icon Behavior";
					switch ([MCSettings sharedInstance].quitMode)
					{
						case kQuitModeRemoveIcons:
							cell.detailTextLabel.text = @"Remove";
							break;
						case kQuitModeRules:
							cell.detailTextLabel.text = @"Use rules";
							break;
					}
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			} 
			break;
		case kStartupSec:
			cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
			switch(indexPath.row)
			{
				case kSUiPod:
					cell.textLabel.text = @"Start in iPod controls";
					[(SwitchCell*)cell setTarget:self andSelector:@selector(setiPodStartup:)];
					((SwitchCell*)cell).on=[MCSettings sharedInstance].startupiPod;
					break;
				case kSUEditMode:
					cell.textLabel.text = @"Start in edit mode";
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setStartupEdit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].startupEdit;
					break;
				case kSUiPodOnlyPlaying:
					cell.textLabel.text = @"  only when playing";
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setOnlyWhenPlaying:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].onlyWhenPlaying;
			}
			break;
		case kMiscSec:
			switch(indexPath.row)
			{
				case kMSCBadgePos:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
					cell.textLabel.text = @"Badge corner";
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.detailTextLabel.text = kCorners[[MCSettings sharedInstance].badgeCorner];
					break;
				case kMSCDontWriggle:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setDontWriggle:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].dontWriggle;
					cell.textLabel.text = @"Don't wriggle";
					break;
				case kMSCNoEdit:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setNoEditMode:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].noEditMode;
					cell.textLabel.text = @"Disable edit mode";
					break;
				case kMSCFastQuit:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setFastExit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].fastExit;
					cell.textLabel.text = @"Home exits edit mode and dissmissess bar";
					break;
				case kMSCAllowTap:
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setAllowTap:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].allowTap;	
					cell.textLabel.text = @"Allow launching apps from edit mode";
					break;
			}
			break;
		case kReorderSec:
			switch(indexPath.row)
			{
				case kROInEditMode:
				{
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setReorderEdit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].reorderEdit;
					cell.textLabel.text = @"Reorder in edit mode";
					break;
				}
				case kROOutsideEditMode:
				{
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setReorderNonEdit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].reorderNonEdit;
					cell.textLabel.text = @"Reorder outside edit";
					break;
				}
				case kROSwipeQuit:
				{
					cell = [[[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
					[(SwitchCell*)cell setTarget:[MCSettings sharedInstance] andPropertySetter:@selector(setSwipeQuit:)]; 
					((SwitchCell*)cell).on=[MCSettings sharedInstance].swipeQuit;
					cell.textLabel.text = @"Swipe app out of the bar to quit it";
					break;
				}
			}
			break;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

#define quitModeTag 1001
#define badgeCornerTag 1002

- (void)pickerTableController:(PickerTableController *)tvc changedSelectionTo:(int)sel
{
	if (tvc.tag==quitModeTag)
		[MCSettings sharedInstance].quitMode=sel;
	if (tvc.tag==badgeCornerTag)
		[MCSettings sharedInstance].badgeCorner=sel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section==kQuitAllSec)&&(indexPath.row==kQAActivator))
	{
		LAListenerSettingsViewController * vc = [[LAListenerSettingsViewController alloc] init];
		vc.listenerName=@"com.dapetcu21.MultiCleaner_quitAllApps";
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		return;
	}
	if ((indexPath.section==kQuitAllSec)&&(indexPath.row==kQAIconBehavior))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = @"Icon Behavior";
		vc.items = [NSArray arrayWithObjects:@"Remove all icons",@"Remove using rules",nil];
		vc.delegate = self;
		vc.tag = quitModeTag;
		vc.currentSelection = [MCSettings sharedInstance].quitMode;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		return;
	}
	if ((indexPath.section==kMiscSec)&&(indexPath.row==kMSCBadgePos))
	{
		PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.title = @"Badge corner";
		vc.items = [NSArray arrayWithObjects:kCorners[0],kCorners[1],kCorners[2],kCorners[3],nil];
		vc.delegate = self;
		vc.tag = badgeCornerTag;
		vc.currentSelection = [MCSettings sharedInstance].badgeCorner;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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


- (void)dealloc {
    [super dealloc];
}


@end

