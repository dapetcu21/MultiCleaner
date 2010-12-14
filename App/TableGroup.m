//
//  TableGroup.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableGroup.h"
#import "TableCell.h"
#import "SettingsViewController.h"

@implementation TableGroup
@synthesize header;
@synthesize footer;
@synthesize index;
@synthesize realIndex;
@synthesize model;

-(id)init
{
	if (self=[super init])
	{
		cells = [[NSMutableArray alloc] init];
		cellsShown = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[cells release];
	[cellsShown release];
	[super dealloc];
}

-(NSUInteger)count
{
	return [cells count];
}

-(NSUInteger)realCount
{
	return [cellsShown count];
}

-(TableCell*)cellAtIndex:(NSUInteger)_index
{
	return (TableCell*)[cells objectAtIndex:_index];
}

-(TableCell*)cellAtRealIndex:(NSUInteger)_index
{
	return (TableCell*)[cellsShown objectAtIndex:_index];
}

-(void)addCell:(TableCell*)cell
{
	cell.group = self;
	cell.viewController=viewController;
	cell.realIndex = [cellsShown count];
	[cells addObject:cell];
	if (!(cell.hidden))
		[cellsShown addObject:cell];
}

-(void)addCell:(TableCell *)cell atIndex:(NSUInteger)_index
{
	cell.group = self;
	cell.viewController=viewController;
	[cells insertObject:cell atIndex:_index];
	[self renumberCells];
}

-(void)removeCellAtIndex:(NSUInteger)_index
{
	[(TableCell*)[cells objectAtIndex:_index] setGroup:nil];
	[cells removeObjectAtIndex:_index];
	[self renumberCells];
}

-(SettingsViewController*)viewController
{
	return viewController;
}

-(void)setViewController:(SettingsViewController *)vc
{
	viewController=vc;
	for (TableCell* cell in cells)
		cell.viewController=viewController;
}

-(void)renumberCells
{
	int n=0;
	[cellsShown removeAllObjects];
	for (TableCell* cell in cells)
		if (!(cell.hidden))
		{
			cell.realIndex = n++;
			[cellsShown addObject:cell];
		}
}

-(BOOL)hidden
{
	return hidden;
}

-(void)setHidden:(BOOL)hid
{
	if (hidden==hid)
		return;
	int row = realIndex;
	hidden = hid;
	[model renumberGroups];
	if (hid)
	{
		[viewController.tableView 
		 deleteSections:[NSIndexSet indexSetWithIndex:row]
		 withRowAnimation:UITableViewRowAnimationLeft];
	}
	else
	{
		[viewController.tableView 
		 insertSections:[NSIndexSet indexSetWithIndex:realIndex]
		 withRowAnimation:UITableViewRowAnimationLeft];
	}
}

@end
