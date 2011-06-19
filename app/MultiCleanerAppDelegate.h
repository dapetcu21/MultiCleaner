//
//  MultiCleanerAppDelegate.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/7/10.
//  Copyright Home 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface MultiCleanerAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	RootViewController * rootController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

