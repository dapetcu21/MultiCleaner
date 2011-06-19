//
//  PickerTableController.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerTableController;

@protocol PickerTableControllerDelegate

-(void)pickerTableController:(PickerTableController*)tvc changedSelectionTo:(int)sel;

@end


@interface PickerTableController : UITableViewController {
	NSArray * items;
	NSString * title;
	int currentSelection;
	int tag;
	id<PickerTableControllerDelegate> delegate;
}

@property(nonatomic,retain) NSString * title;
@property(nonatomic,assign) int currentSelection;
@property(nonatomic,assign) id<PickerTableControllerDelegate> delegate;
@property(nonatomic,retain) NSArray * items;
@property(nonatomic,assign) int tag;

@end
