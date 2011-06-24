//
//  RootViewController.m
//  MultiCleaner
//
//  Created by Marius Petcu on 9/7/10.
//  Copyright Home 2010. All rights reserved.
//

#import "RootViewController.h"
#import "ApplicationCell.h"
#import "SwitchCell.h"
#import "SettingsView.h"
#include <dlfcn.h>
#import <libactivator/libactivator.h>
#include <math.h>
#define prefsPath @"/var/mobile/Library/Preferences/com.dapetcu21.MultiCleaner.plist"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "About.h"
#import "MCSettings.h"
#import "MCIndividualSettings.h"
#import "MultiLineCell.h"
#import "AdvancedView.h"
#import "SettingsViewController.h"
#import "ActivatorToggles.h"
#import "Common.h"

@implementation RootViewController


-(NSArray*) applications
{
	return order;
}

-(id)initWithStyle:(UITableViewStyle)style
{
	if ((self=[super initWithStyle:style]))
	{
		[self loadSettings];
		TableModel * _model = [[[TableModel alloc] init] autorelease];
		
		TableGroup * AboutSection = [[[TableGroup alloc] init] autorelease];
		TableGroup * GeneralSettings = [[[TableGroup alloc] init] autorelease];
		
		
		TableCellNavigation * AboutCell = [[[TableCellNavigation alloc] init] autorelease];
		
		TableCellNavigation * ActivatorCell = [[[TableCellNavigation alloc] init] autorelease];
		TableCellNavigation * GlobalSettingsCell = [[[TableCellNavigation alloc] init] autorelease];
		TableCellNavigation * AdvancedSettingsCell = [[[TableCellNavigation alloc] init] autorelease];
		
		
		//AboutSection
		AboutCell.text = loc(@"About");
		[AboutCell setTarget:self andSelector:@selector(about:)];
		
		[AboutSection addCell:AboutCell];
		
		//GeneralSettings
		ActivatorCell.text = loc(@"ActivatorToggles");
		[ActivatorCell setTarget:self andSelector:@selector(activatorToggles:)];
		
		GlobalSettingsCell.text = loc(@"GlobalSettings");
		[GlobalSettingsCell setTarget:self andSelector:@selector(globalSettings:)];
		
		AdvancedSettingsCell.text = loc(@"AdvancedSettings");
		[AdvancedSettingsCell setTarget:self andSelector:@selector(advancedSettings:)];

		[GeneralSettings addCell:ActivatorCell];
		[GeneralSettings addCell:GlobalSettingsCell];
		[GeneralSettings addCell:AdvancedSettingsCell];
	
		
		[_model addGroup:AboutSection];
		[_model addGroup:GeneralSettings];
		
		self.model = _model;
		self.title = @"MultiCleaner";
	}
	return self;
}

-(void)loadSettings
{
	[order release];
	order = [[NSMutableArray alloc] initWithObjects:@"_global",nil];
	NSDictionary * def = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	if (!def)
		def = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
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
	UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithTitle:loc(@"Add")
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

enum kClosedAppCells {
	kCAActivator = 0,
	kCAHidePrompt,
	kCAConfirm,
	NUMCLOSEDAPPCELLS
};


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [super numberOfSectionsInTableView:tableView]+1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.model.count==section)
		return [settings count]-1;
	//else
	return [super tableView:tableView numberOfRowsInSection:section];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==self.model.count)
		return loc(@"PerAppSettings");
	return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section==self.model.count)
		return nil;
	return [super tableView:tableView titleForFooterInSection:section];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==self.model.count)
		return self.tableView.rowHeight;
	//else
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (self.model.count==indexPath.section)
	{
		ApplicationCell * cell = (ApplicationCell*)[tableView dequeueReusableCellWithIdentifier:@"AppCell"];
		if (cell == nil) {
			cell = [[[ApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AppCell"] autorelease];
		}
		NSString * bundleID = [order objectAtIndex:indexPath.row+1];
		[cell setDisplayId:bundleID];
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle=UITableViewCellSelectionStyleBlue;		
		return cell;
	}
	//else
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section==self.model.count);
}


-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	int kAppSettings = self.model.count;
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
		if (indexPath.section==self.model.count)
		{
			NSString * bundleID = [order objectAtIndex:indexPath.row+1];
			[settings removeObjectForKey:bundleID];
			[order removeObjectAtIndex:indexPath.row+1];
			[self saveSettings];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
    }
}




// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	int kAppSettings = self.model.count;
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
    return indexPath.section==self.model.count;
}



#pragma mark -
#pragma mark Table view delegate

-(void)globalSettings:(id)sender
{
	SettingsView * vc = [[SettingsView alloc] initWithSettings:[settings objectForKey:@"_global"] 
													  bundleID:@"_global" 
													   andName:loc(@"GlobalSettingsTitle")];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

-(void)activatorToggles:(id)sender
{
	ActivatorToggles * vc = [[ActivatorToggles alloc] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

-(void)advancedSettings:(id)sender
{
	AdvancedView * vc = [[AdvancedView alloc] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

-(void)about:(id)sender
{
	About * vc = [[About alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==self.model.count)
	{
		ApplicationCell * cell = (ApplicationCell*) [tableView cellForRowAtIndexPath:indexPath];
		NSString * bundleID = [order objectAtIndex:indexPath.row+1];
		NSLog(@"selected bundleID: 0x%x",bundleID);
		MCIndividualSettings * sett = [settings objectForKey:bundleID];
		NSLog(@"selected count:%d",[bundleID retainCount]);
		SettingsView * vc = [[SettingsView alloc] initWithSettings:sett
														  bundleID:bundleID
														   andName:cell.textLabel.text];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
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

