//
//  TableCellNavigation.m
//  App
//
//  Created by Marius Petcu on 11/15/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableCellNavigation.h"
#import "SettingsViewController.h"
#import "MultiLineCell.h"

@implementation TableCellNavigation

-(UITableViewCell*)buildCell
{
	NSString * cellID = @"TableCellNavigation";
	MultiLineCell * cell = (MultiLineCell*)[viewController.tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[MultiLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	cell.textLabel.text = text;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
	if (target)
		[target performSelector:selector withObject:self];
}

-(void)setTarget:(id)_target andSelector:(SEL)_selector
{
	target=_target;
	selector=_selector;
}

@end
