//
//  TableGroup.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableCell;
@class SettingsViewController;
@class TableModel;

@interface TableGroup : NSObject {
	NSMutableArray * cells;
	NSMutableArray * cellsShown;
	NSString * header;
	NSString * footer;
	SettingsViewController * viewController;
	int index;
	int realIndex;
	TableModel * model; 
	BOOL hidden;
}

-(NSUInteger)count;
-(NSUInteger)realCount;
-(TableCell*)cellAtIndex:(NSUInteger)index;
-(TableCell*)cellAtRealIndex:(NSUInteger)index;
-(void)renumberCells;
-(void)addCell:(TableCell*)cell;
-(void)addCell:(TableCell *)cell atIndex:(NSUInteger)index;
-(void)removeCellAtIndex:(NSUInteger)index;

@property(nonatomic,assign) int index;
@property(nonatomic,assign) int realIndex;
@property(nonatomic,retain) NSString * header;
@property(nonatomic,retain) NSString * footer;
@property(nonatomic,assign) TableModel * model;
@property(nonatomic,assign) SettingsViewController * viewController;
@property(nonatomic,assign) BOOL hidden;
@end
