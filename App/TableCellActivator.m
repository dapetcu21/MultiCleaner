//
//  TableCellActivator.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableCellActivator.h"
#import "SettingsViewController.h"
#import <libactivator/libactivator.h>
#include <math.h>

@implementation TableCellActivator
@synthesize listenerName;

-(UITableViewCell*)buildCell
{
	NSString * cellID = @"TableCellActivator";
	UITableViewCell * cell = [viewController.tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
	cell.textLabel.text = text;
	cell.detailTextLabel.text = loc(@"Activator");
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

-(CGFloat)cellHeight
{
	return floor(viewController.tableView.rowHeight*1.4f);
}

-(void)selected
{
	LAListenerSettingsViewController * vc = [[LAListenerSettingsViewController alloc] init];
	vc.listenerName = listenerName;
	[viewController.navigationController pushViewController:vc animated:YES];
	[vc release];
}

-(void)dealloc
{
	[listenerName release];
	[super dealloc];
}

@end
