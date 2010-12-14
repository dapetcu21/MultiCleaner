//
//  MCIndividualSettings.h
//  MultiCleaner
//
//  Created by Marius Petcu on 10/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

enum kLaunchTypes {
	kLTFront = 0,
	kLTBack,
	kLTBeforeClosed,
	NUMLAUNCHTYPES
};

enum kQuitTypes {
	kQTAppAndIcon = 0,
	kQTApp,
	kQTIcon,
	kQTAppTap,
	NUMQUITTYPES
};

enum kSwipeTypes {
	kSTAppAndIcon = 0,
	kSTIcon,
	kSTApp,
	kSTNothing,
	NUMSWIPETYPES
};

@interface MCIndividualSettings : NSObject<NSCopying> {	
	BOOL pinned;
	BOOL autoclose;
	BOOL hidden;
	BOOL dimClosed;
	BOOL alwaysDim;
	BOOL runningBadge;
	BOOL showCurrent;
	BOOL quitException;
	BOOL moveBack;
	BOOL dontMoveToFront;
	int launchType;
	int quitType;
	int swipeType;
	BOOL quitSingleException;
	BOOL autolaunch;
	BOOL badgePinned;
}

-(void)saveToDict:(NSMutableDictionary*)dict;
-(void)loadFromDict:(NSDictionary*)dict;
-(void)reloadDefaults;

@property(nonatomic,assign) BOOL pinned;
@property(nonatomic,assign) BOOL autoclose;
@property(nonatomic,assign) BOOL hidden;
@property(nonatomic,assign) BOOL dimClosed;
@property(nonatomic,assign) BOOL alwaysDim;
@property(nonatomic,assign) BOOL runningBadge;
@property(nonatomic,assign) BOOL showCurrent;
@property(nonatomic,assign) BOOL quitException;
@property(nonatomic,assign) BOOL quitSingleException;
@property(nonatomic,assign) BOOL moveBack;
@property(nonatomic,assign) BOOL dontMoveToFront;
@property(nonatomic,assign) int launchType;
@property(nonatomic,assign) int quitType;
@property(nonatomic,assign) int swipeType;
@property(nonatomic,assign) BOOL autolaunch;
@property(nonatomic,assign) BOOL badgePinned;

@end
