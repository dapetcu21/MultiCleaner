//
//  TableCell.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableCell.h"
#import "SettingsViewController.h"
#import "MultiLineCell.h"

@implementation TableCell
@synthesize viewController;
@synthesize text;
@synthesize group;
@synthesize realIndex;

/*
-(id)init
{
	if (self=[super init])
	{
	}
	return self;
}*/

-(void)dealloc
{
	[text release];
	[super dealloc];
}

-(UITableViewCell*)buildCell
{
	NSString * cellID = @"TableCell";
	MultiLineCell * cell = (MultiLineCell*)[viewController.tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[MultiLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	cell.textLabel.text = text;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

-(CGFloat)cellHeight
{
	return viewController.tableView.rowHeight + [MultiLineCell additionalCellHeightForText:text 
																				detailText:nil 
																				  andStyle:UITableViewCellStyleDefault];
}

-(void)selected
{
	
}

-(void)setHidden:(BOOL)hid
{
	if (hidden==hid)
		return;
	int row = realIndex;
	hidden = hid;
	[group renumberCells];
	if (hid)
	{
		[viewController.tableView 
			deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:group.realIndex]] 
			withRowAnimation:UITableViewRowAnimationLeft];

	}
	else
	{
		[viewController.tableView 
		 insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:realIndex inSection:group.realIndex]] 
		 withRowAnimation:UITableViewRowAnimationLeft];
	}
}

-(BOOL)hidden
{
	return hidden;
}

@end
