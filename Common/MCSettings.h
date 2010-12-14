//
//  MCSettings.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCIndividualSettings;
enum kQuitModes
{
	kQuitModeRemoveIcons = 0,
	kQuitModeRules,
	NUMQUITMODES
};

enum kToggleTypes
{
	kToggleTypeToggle = 0,
	kToggleTypeQuit,
	NUMTOGGLETYPES
};

@interface MCSettings : NSObject {
	BOOL startupiPod;
	BOOL startupEdit;
	int badgeCorner;
	BOOL quitCurrentApp;
	int quitMode;
	BOOL dontWriggle;
	BOOL allowTap;
	BOOL reorderEdit;
	BOOL reorderNonEdit;
	BOOL swipeQuit;
	BOOL onlyWhenPlaying;
	BOOL noEditMode;
	BOOL fastExit;
	BOOL confirmQuit;
	BOOL confirmQuitSingle;
	BOOL hidePrompt;
	BOOL hidePromptSingle;
	BOOL quitAllEnabled;
	BOOL sbIcon;
	BOOL legacyMode;
	BOOL onlyWhenEmpty;
	int toggleType;
	BOOL startupPinned;
	BOOL pinnedOnlyWhenEmpty;
	BOOL toggleInLockscreen;
	BOOL hidePromptMin;
	MCIndividualSettings * sbIconSettings;
}
@property(nonatomic,assign) BOOL startupiPod;
@property(nonatomic,assign) BOOL startupEdit;
@property(nonatomic,assign) int badgeCorner;
@property(nonatomic,assign) BOOL quitCurrentApp;
@property(nonatomic,assign) int quitMode;
@property(nonatomic,assign) BOOL dontWriggle;
@property(nonatomic,assign) BOOL allowTap;
@property(nonatomic,assign) BOOL reorderEdit;
@property(nonatomic,assign) BOOL reorderNonEdit;
@property(nonatomic,assign) BOOL swipeQuit;
@property(nonatomic,assign) BOOL onlyWhenPlaying;
@property(nonatomic,assign) BOOL noEditMode;
@property(nonatomic,assign) BOOL fastExit;
@property(nonatomic,assign) BOOL confirmQuit;
@property(nonatomic,assign) BOOL confirmQuitSingle;
@property(nonatomic,assign) BOOL hidePrompt;
@property(nonatomic,assign) BOOL hidePromptSingle;
@property(nonatomic,assign) BOOL quitAllEnabled;
@property(nonatomic,assign) BOOL sbIcon;
@property(nonatomic,assign) BOOL legacyMode;
@property(nonatomic,assign) BOOL onlyWhenEmpty;
@property(nonatomic,assign) int toggleType;
@property(nonatomic,assign) BOOL startupPinned;
@property(nonatomic,assign) BOOL pinnedOnlyWhenEmpty;
@property(nonatomic,assign) BOOL toggleInLockscreen;
@property(nonatomic,assign) BOOL hidePromptMin;
@property(nonatomic,readonly) MCIndividualSettings * sbIconSettings;

-(void)loadFromDict:(NSDictionary*)def;
-(void)saveToDict:(NSMutableDictionary*)def;
-(void)reloadDefaults;

+(MCSettings*)sharedInstance;

@end
