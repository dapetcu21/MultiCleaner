//
//  AdvancedView.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@class RootViewController;

@interface AdvancedView : SettingsViewController<UIAlertViewDelegate>{
	RootViewController * delegate;
}

@property(nonatomic,assign) RootViewController * delegate;

@end
