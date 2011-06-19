//
//  TableCellChoice.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableCellChoice.h"
#import "MultiLineCell.h"
#import "SettingsViewController.h"
#import "Common.h"

@interface TableCellChoiceInvocation : NSObject
{
	id target;
	SEL selector;
	int type;
}
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL selector;
@property(nonatomic,assign) int type;
@end
@implementation TableCellChoiceInvocation
@synthesize target;
@synthesize selector;
@synthesize type;
@end


@implementation TableCellChoice
@synthesize state;
@synthesize choices;
@synthesize detailChoices;
@synthesize title;

-(id)init
{
	if ((self=[super init]))
	{
		invocations = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[choices release];
	[title release];
	[detailChoices release];
	[invocations release];
	[super dealloc];
}

-(void)addTarget:(id)target andSelector:(SEL)selector
{
	TableCellChoiceInvocation * inv = [[TableCellChoiceInvocation alloc] init];
	inv.target=target;
	inv.selector=selector;
	inv.type=0;
	[invocations addObject:inv];
	[inv release];
}

-(void)addTarget:(id)target andIntPropertySetter:(SEL)selector
{
	TableCellChoiceInvocation * inv = [[TableCellChoiceInvocation alloc] init];
	inv.target=target;
	inv.selector=selector;
	inv.type=1;
	[invocations addObject:inv];
	[inv release];
}


-(void)clearAllTargets
{
	[invocations removeAllObjects];
}

-(void)pickerTableController:(PickerTableController *)tvc changedSelectionTo:(int)sel
{
	state = sel;
	for (TableCellChoiceInvocation * inv in invocations)
	{
		int value = sel;
		switch(inv.type)
		{
			case 0:
				[inv.target performSelector:inv.selector withObject:self];
				break;
			case 1:
			{
				NSInvocation * invk = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:i"]];
				[invk setSelector:inv.selector];
				[invk setTarget:inv.target];
				[invk setArgument:&value atIndex:2];
				[invk invoke];
				break;
			}
		}
	}
}

-(UITableViewCell*)buildCell
{
	NSString * cellID = @"TableCellChoice";
	MultiLineCell * cell = (MultiLineCell*)[viewController.tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[MultiLineCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
	cell.textLabel.text = text;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.detailTextLabel.text = [choices objectAtIndex:state];
	return cell;
}

-(CGFloat)cellHeight
{
	return viewController.tableView.rowHeight+[MultiLineCell additionalCellHeightForText:text 
																			  detailText:[choices objectAtIndex:state] 
																				andStyle:UITableViewCellStyleValue1];
}

-(void)selected
{
	PickerTableController * vc = [[PickerTableController alloc] initWithStyle:UITableViewStyleGrouped];
	vc.title = title;
	vc.delegate = self;
	vc.items = detailChoices;
	vc.currentSelection = state;
	[viewController.navigationController pushViewController:vc animated:YES];
	[vc release];
}

@end
