//
//  MCSettingsController.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/time.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "MCIndividualSettings.h"
#import "MCSettings.h"

@interface MCSettingsController : NSObject {
	NSMutableDictionary * settings;
	NSArray * order;
	NSString * prefsPath;
	struct timespec lasttime;
	CPDistributedMessagingCenter * center;
}

+(MCSettingsController*)sharedInstance;
+(void)initHooks;
-(BOOL)loadSettings;
-(void)saveSettings;
-(MCIndividualSettings*)settingsForBundleID:(NSString*)bundleID;
-(MCIndividualSettings*)newSettingsForBundleID:(NSString*)bundleID;
-(void)removeSettingsForBundleID:(NSString*)bundleID;
-(void)showWelcomeScreen;
-(void)registerForMessage:(NSString*)name target:(id)tgt selector:(SEL)select;
@end
