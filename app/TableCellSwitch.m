//
//  TableCellSwitch.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableCellSwitch.h"
#import "SwitchCell.h"
#import "SettingsViewController.h"

@interface TableCellSwitchInvocation : NSObject
{
	id target;
	SEL selector;
	int type;
}
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL selector;
@property(nonatomic,assign) int type;
@end
@implementation TableCellSwitchInvocation
@synthesize target;
@synthesize selector;
@synthesize type;
@end


@implementation TableCellSwitch
@synthesize on;

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
	[invocations release];
	[super dealloc];
}

-(void)addTarget:(id)target andSelector:(SEL)selector
{
	TableCellSwitchInvocation * inv = [[TableCellSwitchInvocation alloc] init];
	inv.target=target;
	inv.selector=selector;
	inv.type=0;
	[invocations addObject:inv];
	[inv release];
}

-(void)addTarget:(id)target andBOOLPropertySetter:(SEL)selector
{
	TableCellSwitchInvocation * inv = [[TableCellSwitchInvocation alloc] init];
	inv.target=target;
	inv.selector=selector;
	inv.type=1;
	[invocations addObject:inv];
	[inv release];
}

-(void)addTarget:(id)target andReverseBOOLPropertySetter:(SEL)selector
{
	TableCellSwitchInvocation * inv = [[TableCellSwitchInvocation alloc] init];
	inv.target=target;
	inv.selector=selector;
	inv.type=2;
	[invocations addObject:inv];
	[inv release];
}

-(void)clearAllTargets
{
	[invocations removeAllObjects];
}

-(void)stateChanged:(SwitchCell*)cell
{
	BOOL val = [cell isOn];
	on = val;
	for (TableCellSwitchInvocation * inv in invocations)
	{
		BOOL value = val;
		switch(inv.type)
		{
			case 0:
				[inv.target performSelector:inv.selector withObject:self];
				break;
			case 2:
				value=!value;
			case 1:
			{
				NSInvocation * invk = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:c"]];
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
	NSString * cellID = @"TableCellSwitch";
	SwitchCell * cell = (SwitchCell*)[viewController.tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[SwitchCell alloc] initWithReuseIdentifier:cellID] autorelease];
	cell.textLabel.text = text;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.on = on;
	[cell setTarget:self andSelector:@selector(stateChanged:)];
	return cell;
}

-(CGFloat)cellHeight
{
	return viewController.tableView.rowHeight+[SwitchCell additionalCellHeightForText:text];
}

-(void)selected
{
}

@end
