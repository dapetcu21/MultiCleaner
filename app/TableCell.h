//
//  TableCell.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SettingsViewController;
@class TableGroup;

@interface TableCell : NSObject {
	SettingsViewController * viewController;
	NSString * text;
	BOOL hidden;
	TableGroup * group;
	int realIndex;
}

@property(nonatomic,assign) SettingsViewController * viewController;
@property(nonatomic,retain) NSString * text; 
@property(nonatomic,assign) BOOL hidden;
@property(nonatomic,assign) TableGroup * group;
@property(nonatomic,assign) int realIndex;

-(UITableViewCell*)buildCell;
-(CGFloat)cellHeight;
-(void)selected;

@end
