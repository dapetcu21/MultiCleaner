//
//  TableModel.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableGroup;
@class TableCell;
@class SettingsViewController;

@interface TableModel : NSObject {
	NSMutableArray * groups;
	NSMutableArray * shownGroups;
	SettingsViewController * viewController;
}
-(NSArray*)allGroups;
-(NSArray*)shownGroups;
-(NSUInteger)count;
-(NSUInteger)shownCount;
-(TableGroup*)groupAtIndex:(NSUInteger)index;
-(TableGroup*)groupAtRealIndex:(NSUInteger)index;
-(TableCell*)cellAtIndexPath:(NSIndexPath*)indexPath;
-(void)addGroup:(TableGroup*)group;
-(void)addGroup:(TableGroup*)group atIndex:(NSUInteger)index;
-(void)removeGroupAtIndex:(NSUInteger)index;
-(void)renumberGroups;

@property(nonatomic,assign) SettingsViewController * viewController;
@end
