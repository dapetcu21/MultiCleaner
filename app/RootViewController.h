//
//  RootViewController.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/7/10.
//  Copyright Home 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationPickerController.h"
#import "SettingsViewController.h"

@interface RootViewController : SettingsViewController <ApplicationPickerControllerDelegate> {
	NSMutableDictionary * settings;
	NSMutableArray * order;
}
@property(readonly,nonatomic) NSArray * applications;
-(void)loadSettings;
-(void)saveSettings;
-(void)resetSettings;

@end
