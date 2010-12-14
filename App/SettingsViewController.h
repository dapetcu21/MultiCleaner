//
//  SettingsViewController.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCell.h"
#import "TableGroup.h"
#import "TableModel.h"
#import "TableCellSwitch.h"
#import "TableCellChoice.h"
#import "TableCellActivator.h"
#import "TableCellNavigation.h"

@interface SettingsViewController : UITableViewController {
	TableModel * model;
	NSString * title;
}

@property(nonatomic,retain) TableModel * model;
@property(nonatomic,retain) NSString * title;

@end
