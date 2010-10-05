//
//  RootViewController.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/7/10.
//  Copyright Home 2010. All rights reserved.
//

#import "RootViewController.h"
#import "ApplicationCell.h"
#import "SettingsView.h"
#include <dlfcn.h>
#import <libactivator/libactivator.h>
#include <math.h>
#define prefsPath @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "About.h"
#import "MCSettings.h"
#import "MCIndividualSettings.h"
#import "AdvancedView.h"

@implementation RootViewController


-(NSArray*) applications
{
	return [[order retain] autorelease];
}

-(id)initWithStyle:(UITableViewStyle)style
{
	if (self=[super initWithStyle:style])
	{
		[self loadSettings];
	}
	return self;
}

-(void)loadSettings
{
	[order release];
	order = [[NSMutableArray alloc] initWithObjects:@"_global",nil];
	NSDictionary * def = [[NSDictionary alloc]initWithContentsOfFile:prefsPath];
	NSArray * ord = [def objectForKey:@"Order"];
	if ([ord isKindOfClass:[NSArray class]])
	{
		for (NSString * ident in ord)
		{
			if (![ident isKindOfClass:[NSString class]])
				continue;
			if ([ident isEqual:@"_global"])
				continue;
			[order addObject:ident];
		}
	}
	settings = [[NSMutableDictionary alloc] initWithCapacity:[ord count]];
	NSDictionary * apps = [def objectForKey:@"Apps"];
	if (![apps isKindOfClass:[NSDictionary class]])
		apps=nil;
	for (NSString * ident in order)
	{
		NSDictionary * sett_item = [apps objectForKey:ident];
		if (![sett_item isKindOfClass:[NSDictionary class]])
			sett_item=nil;
		MCIndividualSettings * item = [[MCIndividualSettings alloc] init];
		[item loadFromDict:sett_item];
		[settings setObject:item forKey:ident];
		[item release];
	}
	[[MCSettings sharedInstance] loadFromDict:def];
	[def release];
}

-(void)saveSettings
{
	
	NSMutableDictionary * def = [[NSMutableDictionary alloc]init];
	[def setObject:order forKey:@"Order"];
	NSMutableDictionary * apps = [[NSMutableDictionary alloc]init];
	for (NSString * bundleID in order)
	{
		MCIndividualSettings * sett = [settings objectForKey:bundleID];
		NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
		[sett saveToDict:dict];
		[apps setObject:dict forKey:bundleID];
		[dict release];
	}
	[def setObject:apps forKey:@"Apps"];
	[apps release];
	[[MCSettings sharedInstance] saveToDict:def];
	[def writeToFile:prefsPath atomically:YES];
	
	[def release];
	CPDistributedMessagingCenter * center = [CPDistributedMessagingCenter centerNamed:@"com.dapetcu21.MultiCleaner.center"];
	[center sendMessageName:@"reloadSettings" userInfo:nil];
}

#pragma mark -
#pragma mark View lifecycle

-(void)addApp
{
	ApplicationPickerController * controller = [[ApplicationPickerController alloc] initWithDelegate:self];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title=@"MultiCleaner";
	//[self setEditing:YES];
	UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithTitle:@"Add" 
																style:UIBarButtonItemStylePlain 
															   target:self 
															   action:@selector(addApp)];
	
	self.navigationItem.leftBarButtonItem=button;
	self.navigationItem.rightBarButtonItem=self.editButtonItem;
	[button release];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self saveSettings];
}

#pragma mark -
#pragma mark Table view data source

enum kSections {
	kCloseAppSection = 0,
	kAboutSection,
	kGeneralSettings,
	kAppSettings,
	NUMSECTIONS
};


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMSECTIONS;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case kCloseAppSection:
			return 1;
		case kGeneralSettings:
			return 2;
		case kAppSettings:
			return [settings count]-1;
		case kAboutSection:
			return 1;
			break;

		default:
			return 0;
	}
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==kAppSettings)
		return @"Per-application settings";
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==kCloseAppSection)
		return round(self.tableView.rowHeight*1.4f);
	return self.tableView.rowHeight;
}

extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *AppCellIdentifier= @"AppCell";
	UITableViewCell *cell;
	
	if (indexPath.section==kAppSettings)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:AppCellIdentifier];
		if (cell == nil) {
			cell = [[[ApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AppCellIdentifier] autorelease];
		}
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.detailTextLabel.text=nil;
    }
	
	
	if (indexPath.section==kCloseAppSection)
	{
		cell.textLabel.text=@"Quit current app";
		cell.selectionStyle=UITableViewCellSelectionStyleBlue;
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		cell.detailTextLabel.text=@"Activator trigger";
	}
	
	if (indexPath.section==kAboutSection)
	{
		cell.textLabel.text=@"About";
		cell.selectionStyle=UITableViewCellSelectionStyleBlue;
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	
	if (indexPath.section==kGeneralSettings)
	{
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text=@"Global settings";
				break;
			case 1:
				cell.textLabel.text=@"Advanced settings";
				break;
		}
	}
	
	if (indexPath.section==kAppSettings)
	{
		NSString * bundleID = [order objectAtIndex:indexPath.row+1];
		[(ApplicationCell*)cell setDisplayId:bundleID];
	}
	
	if ((indexPath.section==kGeneralSettings)||(indexPath.section==kAppSettings))
	{
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle=UITableViewCellSelectionStyleBlue;
	}
	
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section==kAppSettings);
}


-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (sourceIndexPath.section!=kAppSettings)
		return sourceIndexPath;
	if (proposedDestinationIndexPath.section!=kAppSettings)
		return [NSIndexPath indexPathForRow:(proposedDestinationIndexPath.section<kAppSettings)?0:
								([self tableView:tableView numberOfRowsInSection:kAppSettings]-1)
								  inSection:kAppSettings];
	return proposedDestinationIndexPath;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (indexPath.section==kAppSettings)
		{
			NSString * bundleID = [order objectAtIndex:indexPath.row+1];
			[settings removeObjectForKey:bundleID];
			[order removeObjectAtIndex:indexPath.row+1];
			[self saveSettings];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}




// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (fromIndexPath.section!=kAppSettings)
		return;
	if (toIndexPath.section!=kAppSettings)
		return;
	NSString * bundleID = [order objectAtIndex:fromIndexPath.row+1];
	[order removeObjectAtIndex:fromIndexPath.row+1];
	[order insertObject:bundleID atIndex:toIndexPath.row+1];
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return indexPath.section==kAppSettings;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController * vc = nil;
	if (indexPath.section==kCloseAppSection)
	{
		vc = [[LAListenerSettingsViewController alloc] init];
		((LAListenerSettingsViewController*)vc).listenerName=@"com.dapetcu21.MultiCleaner";
	} else
	if (indexPath.section==kAppSettings)
	{
		ApplicationCell * cell = (ApplicationCell*) [tableView cellForRowAtIndexPath:indexPath];
		NSString * bundleID = [order objectAtIndex:indexPath.row+1];
		NSLog(@"selected bundleID: 0x%x",bundleID);
		MCIndividualSettings * sett = [settings objectForKey:bundleID];
		NSLog(@"selected count:%d",[bundleID retainCount]);
		vc = [[SettingsView alloc] initWithSettings:sett
										   bundleID:bundleID
											andName:cell.textLabel.text];
	} else
	if (indexPath.section==kGeneralSettings)
	{
		switch (indexPath.row) {
			case 0:
				vc = [[SettingsView alloc] initWithSettings:[settings objectForKey:@"_global"] 
												   bundleID:@"_global" 
													andName:@"Global settings"];
				break;
			case 1:
				vc = [[AdvancedView alloc] initWithStyle:UITableViewStyleGrouped];
				break;
		}
	} else
	if (indexPath.section==kAboutSection)
	{
		vc = [[About alloc] initWithNibName:nil bundle:nil];
	}
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self saveSettings];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[self saveSettings];
	[order release];
	[settings release];
    [super dealloc];
}

#pragma mark  ApplicationPickerController

- (void)applicationPickerController:(ApplicationPickerController *)controller didSelectAppWithDisplayIdentifier:(NSString *)displayId
{
	NSString * key = [[NSString alloc] initWithString:displayId];
	[order addObject:key];
	[settings setObject:[[[settings objectForKey:@"_global"] copy] autorelease] forKey:key];
	[key release];
	[self.tableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)applicationPickerControllerDidFinish:(ApplicationPickerController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}


@end

