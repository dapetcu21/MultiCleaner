/*
 *  MultiCleaner.h
 *  MultiCleaner
 *
 *  Created by Marius Petcu on 9/8/10.
 *  Copyright 2010 Home. All rights reserved.
 *
 */

#ifndef MULTICLEANER_H
#define MULTICLEANER_H

#define BETA_VERSION @"2010-12-17 00:00:00 +0200"

#ifdef __cplusplus
extern "C" 
{
#endif
void settingsReloaded();
void quitForegroundApp();
void quitAllApps();
void toggleBar();
void openLastApp();
void minimizeForegroundApp();
NSString * foregroundAppDisplayIdentifier();
BOOL isMultitaskingOff();
#ifdef __cplusplus
}
#endif

#define SBBUNDLEID @"com.dapetcu21.SpringBoard"
#define SWITCHERBUNDLEID @"com.dapetcu21.SwitcherBar"

#define MCLog(args...) NSLog(@"MultiCleaner: %@",[NSString stringWithFormat:args]);
#define loc(x,y) [[NSBundle bundleWithPath:@"/Applications/MultiCleaner.app"] localizedStringForKey:(x) value:(y) table:nil]
#endif