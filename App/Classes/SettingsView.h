//
//  SettingsView.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerTableController.h"

@class MCIndividualSettings;

@interface SettingsView : UITableViewController<PickerTableControllerDelegate> {
	MCIndividualSettings * settings;
	NSString * bundleID;
	NSString * name;
	BOOL global;
}

- (id)initWithSettings:(MCIndividualSettings*)settings bundleID:(NSString*)bundleID andName:(NSString*) name;

@end
