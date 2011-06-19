//
//  TableCellChoice.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCell.h"
#import "PickerTableController.h"

@interface TableCellChoice : TableCell<PickerTableControllerDelegate> {
	int state;
	NSMutableArray * invocations;
	NSArray * detailChoices;
	NSArray * choices;
	NSString * title;
}
@property(nonatomic,assign) int state;
@property(nonatomic,retain) NSArray * choices;
@property(nonatomic,retain) NSArray * detailChoices;
@property(nonatomic,retain) NSString * title;

-(void)addTarget:(id)target andSelector:(SEL)selector;
-(void)addTarget:(id)target andIntPropertySetter:(SEL)selector;
-(void)clearAllTargets;

@end
