//
//  TableModel.m
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TableModel.h"
#import "TableGroup.h"

@implementation TableModel
-(id) init
{
	if ((self=[super init]))
	{
		groups = [[NSMutableArray alloc] init];
		shownGroups = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[shownGroups release];
	[groups release];
	[super dealloc];
}

-(NSArray*)allGroups
{
	return (NSArray*)groups;
}

-(NSArray*)shownGroups
{
	return (NSArray*)shownGroups;
}

-(NSUInteger)count
{
	return [groups count];
}

-(NSUInteger)shownCount
{
	return [shownGroups count];
}

-(void)renumberGroups
{
	int n=0;
	int nhn = 0;
	[shownGroups removeAllObjects];
	for (TableGroup * group in groups)
	{
		group.index=n++;
		if (!group.hidden)
		{
			group.realIndex=nhn++;
			[shownGroups addObject:group];
		}
	}
}

-(TableGroup*)groupAtIndex:(NSUInteger)index
{
	return (TableGroup*)[groups objectAtIndex:index];
}

-(TableGroup*)groupAtRealIndex:(NSUInteger)index
{
	return (TableGroup*)[shownGroups objectAtIndex:index];
}

-(TableCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
	return [(TableGroup*)[self groupAtRealIndex:indexPath.section] cellAtRealIndex:indexPath.row];
}

-(void)addGroup:(TableGroup*)group
{
	group.viewController=viewController;
	group.index = [groups count];
	group.model = self;
	[groups addObject:group];
	if (!group.hidden)
	{
		group.realIndex = [shownGroups count];
		[shownGroups addObject:group];
	}
}

-(void)addGroup:(TableGroup*)group atIndex:(NSUInteger)index
{
	group.viewController=viewController;
	group.model = self;
	[groups insertObject:group atIndex:index];
	[self renumberGroups];
}

-(void)removeGroupAtIndex:(NSUInteger)index
{
	[(TableGroup*)[groups objectAtIndex:index] setModel:nil];
	[groups removeObjectAtIndex:index];
	[self renumberGroups];
}

-(SettingsViewController*)viewController
{
	return viewController;
}

-(void)setViewController:(SettingsViewController *)vc
{
	viewController=vc;
	for (TableGroup * group in groups)
		group.viewController=viewController;
}

@end
