#define appName MultiCleaner

#include <pthread.h>
#include <notify.h>
#include <stdlib.h>
#include <sys/utsname.h>

#import <SpringBoard/SpringBoard.h>

#include <substrate.h>

#import "MultiCleaner.h"
#import "MCListener.h"
#import "MCListenerQuitAll.h"
#import "MCListenerOpenBar.h"
#import "MCListenerOpenEdit.h"
#import "MCListenerLastClosed.h"
#import "MCSettingsController.h"
#import "MCListenerJustMin.h"
#import "MCImageView.h"

Class $SBAppSwitcherController;
Class $SpringBoard;
Class $SBAppSwitcherModel;
Class $SBDisplayStack;
Class $SBApplication;
Class $SBApplicationController;
Class $SBIcon;
Class $SBUIController;
Class $SBApplicationIcon;
Class $SBAppIconQuitButton;
Class $SBMediaController;
Class $SBPlatformController;
Class $SBAppSwitcherBarView;
Class $SBIconModel;
Class $SBCallAlertDisplay;
Class $SBAwayController;

struct MultiCleanerVars {
	MCSettingsController * settingsController;
	MCSettings * settings;
	NSMutableDictionary * runningApps;
	NSMutableDictionary * autostartedApps;
	NSMutableArray * displayStacks;
	SBIcon * currentIcon;
	bool moved;
	UIView * iconSuperView;
	int index;
	int oldindex;
	int lastindex;
	NSTimer * flipTimer;
	BOOL flipBack;
	BOOL editMode;
	BOOL isOut;
	BOOL isOutBack;
	int majorSysVersion;
	int minorSysVersion;
	int bugfixSysVersion;
	BOOL normalCloseTapped;
	BOOL legacyMode;
	BOOL shouldReturnToSwitcher;
	BOOL keepAllApps;
	int nrPlaceholders;
	int nrPinned;
	BOOL inPinnedArea;
	BOOL isApp;
	BOOL noCloseAnim;
	BOOL bypassPhone;
	BOOL notIgnoringEvents;
	BOOL iPad;
	NSString * lastBundleID;
};
static struct MultiCleanerVars MC;

#define SBWPreActivateDisplayStack        ((SBDisplayStack *)[MC.displayStacks objectAtIndex:0])
#define SBWActiveDisplayStack             ((SBDisplayStack *)[MC.displayStacks objectAtIndex:1])
#define SBWSuspendingDisplayStack         ((SBDisplayStack *)[MC.displayStacks objectAtIndex:2])
#define SBWSuspendedEventOnlyDisplayStack ((SBDisplayStack *)[MC.displayStacks objectAtIndex:3])

extern "C" 
NSString * foregroundAppDisplayIdentifier()
{
	SBApplication * app = [SBWActiveDisplayStack topApplication];
	return [app displayIdentifier];
}

inline BOOL versionBigger(int majorv,int minorv,int bfixv)
{
	if (majorv==MC.majorSysVersion)
	{
		if (MC.minorSysVersion==minorv)
			return MC.bugfixSysVersion>=bfixv;
		return MC.minorSysVersion>=minorv;
	}
	return MC.majorSysVersion>=majorv;
}

inline BOOL versionBigger(int majorv,int minorv)
{
	if (majorv==MC.majorSysVersion)
		return MC.minorSysVersion>=minorv;
	return MC.majorSysVersion>=majorv;
}

@interface MCListener(MCMisc)
-(void)flipPageTimer:(id)userinfo;
-(void)closeApp:(SBApplication*)app;
-(void)pinnedChanged:(NSString*)name userInfo:(NSDictionary*)ui;
@end

enum kPinTypes {
	kPinSett = 0,
	kPinDrag,
	kPinMove,
	NUMPINTYPES
};

void removeApplicationFromBar(SBAppSwitcherController * self, SBApplication * app);
BOOL shouldKeepAppWithBundleID(NSString * bundleID);
void badgeAppIcon(SBApplicationIcon * app);
void moveIconToBack(SBAppSwitcherController * self, SBApplicationIcon * icon);
void moveAppToBack(SBAppSwitcherController * self, SBApplication * app);
void badgeApp(SBApplication * app);
void quitForegroundAppAndReturn(BOOL keepIcon);
void quitApp(SBApplication * app);
void refreshAppStatus(BOOL state);
void iconPinnedToTheBar(SBApplicationIcon * app, int type);
SBApplicationIcon * iconForBundleID(NSString * str);
int iconsPerPage(SBAppSwitcherBarView * bar);
void renumberSubviews(SBAppSwitcherBarView * self);
CGPoint firstPageOffset(SBAppSwitcherBarView * self, CGFloat width);
void modelAddToFront(SBAppSwitcherModel * self, SBApplication * app);
void modelAddToBack(SBAppSwitcherModel * self, SBApplication * app);
void modelAddBeforeClosed(SBAppSwitcherModel * self, SBApplication * app);
bool modelHasApp(SBAppSwitcherModel * self, SBApplication * app);
void modelRemove(SBAppSwitcherModel * self, SBApplication * app);
bool iconIsApplicationIcon(SBIcon * self);

@implementation MCListener(MCMisc)
-(void)flipPageTimer:(id)userinfo
{
	MC.flipTimer = nil;
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>([$SBAppSwitcherController sharedInstance],"_bottomBar");
	UIScrollView * scrollView = MSHookIvar<UIScrollView*>(bottomBar, "_scrollView");
	CGPoint offset = scrollView.contentOffset;
	CGFloat off = (MC.flipBack?(-1):1)*bottomBar.bounds.size.width;
	CGFloat init = firstPageOffset(bottomBar, bottomBar.bounds.size.width).x;
	offset.x+=off;
	
	int div = iconsPerPage(bottomBar);
	int desired_page = round((offset.x-init)/bottomBar.bounds.size.width);
	int pinned_pages = MC.nrPinned?((MC.nrPinned-1)/div)+1:0;
	BOOL inPinnedArea = desired_page<pinned_pages;
	if (inPinnedArea!=MC.inPinnedArea)
	{
		if (!MC.isApp)
			return;
		int nr = MC.nrPlaceholders;
		MC.inPinnedArea = inPinnedArea;
		renumberSubviews(bottomBar);
		if (MC.nrPlaceholders!=nr+(inPinnedArea?-1:1))
			offset.x = scrollView.contentOffset.x;
		[bottomBar _reflowContent:YES];
		if (versionBigger(4,2))
			[bottomBar _adjustContentOffsetForReflow:YES];
	}
		
	
	if (offset.x==scrollView.contentOffset.x) return;
	if (offset.x>=scrollView.contentSize.width) return;
	if (offset.x<init) return;
	CGPoint iconCenter = MC.currentIcon.center;
	iconCenter.x+=off;
	[scrollView setContentOffset:offset animated:YES];
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //TODO: find right values
	[UIView setAnimationDuration:0.2f];
	MC.currentIcon.center=iconCenter;
	[UIView commitAnimations];
	
}

-(void)closeApp:(SBApplication*)app
{
	quitApp(app);
}


-(void)pinnedChanged:(NSString*)name userInfo:(NSDictionary*)ui
{
	if (isMultitaskingOff())
		return;
	NSDictionary * dict = [ui objectForKey:@"PinnedApps"];
	NSArray * apps = [dict allKeys];
	for (NSString * bundleID in apps)
	{
		MCIndividualSettings * sett = [MC.settingsController newSettingsForBundleID:bundleID];
		MCIndividualSettings * global = [MC.settingsController settingsForBundleID:@"_global"];
		if ([(NSNumber*)[dict objectForKey:bundleID] boolValue]==sett.pinned)
			continue;
		BOOL locked = sett.pinned = !sett.pinned;
		if ([sett isEqual:global])
		{
			[MC.settingsController removeSettingsForBundleID:bundleID];
			sett = global;
		}
		SBApplicationIcon * icon = iconForBundleID(bundleID);
		SBAppSwitcherController * switcherController = [$SBAppSwitcherController sharedInstance];
		SBApplication * app = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:bundleID];
		if (!icon)
		{
			BOOL wasOff = ([MC.runningApps objectForKey:bundleID]==nil);
			[switcherController applicationLaunched:app];
			if (wasOff)
				[switcherController applicationDied:app];

		} else {
			if (!locked&&!shouldKeepAppWithBundleID(bundleID))
				removeApplicationFromBar(switcherController, app);
			else
				badgeAppIcon(icon);
		}

	}
}
@end

#pragma mark -
#pragma mark Support functions

BOOL rectContainsPoint(CGRect rect, CGPoint pnt)
{
	return ((pnt.x>=rect.origin.x)&&(pnt.x<=rect.origin.x+rect.size.width)&&(pnt.y>=rect.origin.y)&&(pnt.y<=rect.origin.y+rect.size.height));
}

SBApplicationIcon * iconForBundleID(NSString * str)
{
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>([$SBAppSwitcherController sharedInstance],"_bottomBar");
	return [bottomBar applicationIconForDisplayIdentifier:str];
}

%hook SBDisplayStack
-(id)init
{
	if ((self=%orig))
	{
		[MC.displayStacks addObject:self];
	}
	return self;
}

-(void)dealloc
{
	[MC.displayStacks removeObject:self];
	%orig;
}
%end

#pragma mark -
#pragma mark Settings reloading

extern "C"
void settingsReloaded()
{
	if (isMultitaskingOff())
	{
		refreshAppStatus(NO);
		return;
	}
	SBAppSwitcherController * appSwitcher = [$SBAppSwitcherController sharedInstance];
	SBAppSwitcherModel * appSwitcherModel = [$SBAppSwitcherModel sharedInstance];
	SBApplicationController * appController = [$SBApplicationController sharedInstance];
	
	NSMutableArray * allApps = [[NSMutableArray alloc] initWithArray:[MC.runningApps allKeys]];
	int n = [appSwitcherModel count];
	for (int i=0; i<n; i++)
	{
		NSString * app = [[appSwitcherModel appAtIndex:i] displayIdentifier];
		if (![MC.runningApps objectForKey:app])
			[allApps addObject:app];
	}
	for (NSString * appid in allApps)
	{
		SBApplication * app =[appController applicationWithDisplayIdentifier:appid];
		SBApplicationIcon * icon = iconForBundleID(appid);
		BOOL hidden = !shouldKeepAppWithBundleID(appid); 
		if (!modelHasApp(appSwitcherModel,app)&&!hidden)
		{
			BOOL isRunning = [MC.runningApps objectForKey:appid]!=nil;
			[appSwitcher applicationLaunched:app];
			if (!isRunning)
				[appSwitcher applicationDied:app];
		}
		if (hidden)
			removeApplicationFromBar(appSwitcher, app);
		if ((!hidden)&&icon)
		{
			badgeAppIcon(icon);
		}
	}
	[allApps release];
	BOOL shouldMoveClosedToBack = YES;
	if (shouldMoveClosedToBack)
	{
		SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(appSwitcher,"_bottomBar");
		NSArray * icons = [[bottomBar appIcons] copy];
		for (SBApplicationIcon * icon in icons)
		{
			if (!iconIsApplicationIcon(icon)) continue;
			NSString * bundleID = [[icon application] displayIdentifier];
			if ((![MC.runningApps objectForKey:bundleID])&&([MC.settingsController settingsForBundleID:bundleID].moveBack))
				moveIconToBack(appSwitcher, icon);
		}
		[icons release];
	}

	refreshAppStatus(MC.settings.sbIcon);
}

#pragma mark -
#pragma mark App hiding

%hook SBCallAlertDisplay
-(void)answer:(id)arg
{
	MC.bypassPhone = YES;
	%orig;
}
%end

BOOL shouldKeepAppWithBundleID(NSString * bundleID)
{
	if (MC.keepAllApps)
		return YES;
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if (sett.pinned)
		return YES;
	return !(sett.hidden||(sett.autoclose&&![MC.runningApps objectForKey:bundleID]));
}

void removeApplicationFromBar(SBAppSwitcherController * self, SBApplication * app)
{
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self,"_bottomBar");
	SBApplicationIcon * icon = iconForBundleID([app displayIdentifier]);
	if (icon)
		[bottomBar removeIcon:icon];
	[self _removeApplicationFromRecents:app];
}


%hook SBAppSwitcherController

-(void)applicationLaunched:(SBApplication *)app
{
	NSString * bundleID = [app displayIdentifier];
	if (MC.bypassPhone && [bundleID isEqual:@"com.apple.mobilephone"])
	{
		MC.bypassPhone = NO;
		return;
	}
	[MC.runningApps setObject:app forKey:bundleID];
	if (![bundleID isEqual:SBBUNDLEID]&&![bundleID isEqual:SWITCHERBUNDLEID])
	{
		[bundleID retain];
		[MC.lastBundleID release];
		MC.lastBundleID = bundleID;
	}
	SBAppSwitcherModel * model = [$SBAppSwitcherModel sharedInstance];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if (modelHasApp(model, app))
	{
		if (!(sett.dontMoveToFront||sett.pinned))
			%orig;
		else
			badgeApp(app);
	} else {
		switch (sett.pinned?kLTFront:sett.launchType) {
			case kLTBack:
				modelAddToBack(model, app);
				break;
			case kLTBeforeClosed:
				modelAddBeforeClosed(model, app);
				break;
			default:
				%orig;
				break;
		}

	}
	//NSMutableArray * apps = MSHookIvar<NSMutableArray*>(model, "_recentDisplayIdentifiers");
}

-(void) applicationDied:(SBApplication *)app
{
	NSString * bundleID = [app displayIdentifier];
	[MC.runningApps removeObjectForKey:bundleID];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if (((sett.autoclose)&&!(sett.pinned))&&!MC.keepAllApps)		
		removeApplicationFromBar(self,app);
	else
	{
		badgeApp(app);
		if (sett.moveBack&&!sett.pinned)
			moveAppToBack(self, app);
	}
	%orig;
}

%end

%hook SBAppSwitcherModel

-(id)_recentsFromPrefs
{
	NSArray * ret = %orig;
	NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:[ret count]];
	for (NSString * app in ret)
	{
		if (shouldKeepAppWithBundleID(app))
			[arr addObject: app];
	}
	[arr autorelease];
	return arr;
}

%end

#pragma mark -
#pragma mark Icon badging

void badgeAppIcon(SBApplicationIcon * app)
{
	if (!iconIsApplicationIcon(app))
		return;
	NSString * bundleID = [[app application] displayIdentifier];
	MCIndividualSettings * settings = [MC.settingsController settingsForBundleID:bundleID];
	BOOL editing = [[$SBAppSwitcherController sharedInstance] _inEditMode];
	BOOL running = ([MC.runningApps objectForKey:bundleID]!=nil);
	BOOL showquit = editing&&!(((settings.quitType==kQTApp)||(settings.pinned))&&!running);
	BOOL badge = (((running&&(settings.runningBadge))||(settings.pinned&&settings.badgePinned))&&!(showquit&&(MC.settings.badgeCorner==0)));
	BOOL dim = (((!running)||(settings.alwaysDim))&&(settings.dimClosed));
	if (showquit&&[bundleID isEqual:SBBUNDLEID])
		showquit = NO;
	
	if (showquit!=[app isShowingCloseBox])
	{
		if (versionBigger(4,1))
		{
			[app setShowsCloseBox:showquit];
		} else {
			if (!showquit)
				[app setCloseBox:nil];
			else;
		}
	}

	if (dim)
	{
		[app setIconImageAlpha:0.5f];
		[app setIconLabelAlpha:0.5f];
	} else {
		[app setIconImageAlpha:1.0f];
		[app setIconLabelAlpha:1.0f];
	}
	[[app viewWithTag:4432] removeFromSuperview];
	if (badge)
	{
		static const NSString * imageName = @"MultiCleaner_RunningBadge";
		UIImageView * badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
		UIView * container = MSHookIvar<UIView*>(app, "_iconImageContainer");
		CGRect bounds = [container bounds];
		switch (MC.settings.badgeCorner) {
			case 0:
				badgeView.origin = CGPointMake(-12.0f, -9.0f);
				break;
			case 1:
				badgeView.origin = CGPointMake(bounds.size.width+12.0f-badgeView.bounds.size.width, -9.0f);
				break;
			case 2:
				badgeView.origin = CGPointMake(bounds.size.width+12.0f-badgeView.bounds.size.width, bounds.size.width+4.0f-badgeView.bounds.size.height);
				break;
			case 3:
				badgeView.origin = CGPointMake(-12.0f,bounds.size.width+4.0f-badgeView.bounds.size.height);
				break;
			default:
				badgeView.origin = CGPointMake(-12.0f, -9.0f);
				break;
		}
		badgeView.tag = 4432;
		[container addSubview:badgeView];
		[badgeView release];
	}
}

void badgeApp(SBApplication * app)
{
	SBApplicationIcon * icon = iconForBundleID([app displayIdentifier]);
	if (icon)
		badgeAppIcon(icon);	
}

%hook SBApplicationIcon
-(SBApplicationIcon*)_iconForApplication:(SBApplication*)app
{
	SBApplicationIcon * icon = %orig;
	badgeAppIcon(icon);
	return icon;
}
%end

#pragma mark -
#pragma mark Show current app

%hook SBAppSwitcherController
-(id)_applicationIconsExcept:(SBApplication*)app forOrientation:(int)orient
{
	NSString * bundleID = @"_global";
	if (app)
		bundleID = [app displayIdentifier];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if (sett.showCurrent||sett.pinned)
		app = nil;
	return %orig;
}
%end

#pragma mark -
#pragma mark Close Box

inline bool iconIsApplicationIcon(SBIcon * self)
{
	if (![self isApplicationIcon])
		return false;
	switch (self.tag) {
		case 4445:
			return false;
			break;
		case 4446:
			return false;
			break;
		case 4444:
			return false;
			break;
	}
	return true;
}

BOOL iconCloseTapped(SBAppSwitcherController * self,SBApplicationIcon * icon)
{
	if (!iconIsApplicationIcon(icon))
		return YES;
	SBApplication * app = [icon application];
	NSString * bundleID = [app displayIdentifier];
	if ([bundleID isEqual:SBBUNDLEID])
		return NO;
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	int quitType = sett.quitType;
	if (sett.pinned)
		quitType=kQTApp;
	if (MC.normalCloseTapped)
	{
		quitType = kQTAppAndIcon;
		MC.normalCloseTapped = NO;
	}
	if (quitType==kQTAppTap)
	{
		quitType = [MC.runningApps objectForKey:[app displayIdentifier]]?kQTApp:kQTIcon;
	}
	if (quitType==kQTIcon)
	{
		removeApplicationFromBar(self, app);
		return NO;
	}
	if (app == [SBWActiveDisplayStack topApplication])
	{
		quitForegroundAppAndReturn(quitType==kQTApp);
		return NO;
	} 
	if (quitType==kQTApp)
	{
		quitApp(app);
		return NO;
	}
	return YES;
}


%hook SBAppSwitcherController
//TODO: convert these

%group pre41
-(void)_quitButtonHit:(SBAppIconQuitButton*) button
{
	SBApplicationIcon * icon = [button appIcon];
	if (iconCloseTapped(self,icon))
		%orig;
}
%end

%group post41
-(void)iconCloseBoxTapped:(SBApplicationIcon*)icon
{
	if (iconCloseTapped(self,icon))
		%orig;
}
%end

%end

#pragma mark -
#pragma mark App quitting

extern "C" 
void openLastApp()
{
	SBIcon * app = [[$SBIconModel sharedInstance] leafIconForIdentifier:MC.lastBundleID];
	[app launch];
}

extern "C" 
void minimizeForegroundApp()
{
	SBApplication * app = [SBWActiveDisplayStack topApplication];
	if (!app) return;
	[app setDeactivationSetting:0x2 flag:YES]; //animate flag
	[SBWActiveDisplayStack popDisplay:app];
	[SBWSuspendingDisplayStack pushDisplay:app];
}

extern "C"
void quitForegroundApp(BOOL removeIcon)
{
	SBApplication * app = [SBWActiveDisplayStack topApplication];
	if (!app) return;
	[app setDeactivationSetting:0x2 flag:YES]; //animate flag
	[app setDeactivationSetting:0x10 flag:YES]; //forceExit flag
	[SBWActiveDisplayStack popDisplay:app];
	[SBWSuspendingDisplayStack pushDisplay:app];
	if (removeIcon)
	{
		MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:[app displayIdentifier]];
		if (sett.removeOnQuitApp&&!sett.pinned)
			removeApplicationFromBar([$SBAppSwitcherController sharedInstance], app);
	}
}

%hook SBUIController
-(void)applicationSuspendAnimationDidStop:(id)stop finished:(id) finished context:(void*) context
{
	if (MC.shouldReturnToSwitcher)
	{
		MC.shouldReturnToSwitcher = NO;
		[[$SBUIController sharedInstance] activateSwitcher];
		if (MC.editMode)
			[[$SBAppSwitcherController sharedInstance] _beginEditing];
	}
	%orig;
}
%end

void quitForegroundAppAndReturn(BOOL keepIcon)
{
	if ([[$SBUIController sharedInstance] isSwitcherShowing])
	{
		SBApplication * app = [SBWActiveDisplayStack topApplication];
		SBAppSwitcherController * appSwitcher = [$SBAppSwitcherController sharedInstance];
		if (!keepIcon)
			removeApplicationFromBar(appSwitcher, app);
		MC.editMode = [appSwitcher _inEditMode];
		if ([[MSHookIvar<SBAppSwitcherBarView*>(appSwitcher,"_bottomBar") appIcons] count]!=0)
			MC.shouldReturnToSwitcher = YES;
	}
	quitForegroundApp(NO);
}

int threadPriority()
{
	struct sched_param param;
	int policy;
	int	rt;
	rt = pthread_getschedparam(pthread_self(), &policy, &param);
	return param.sched_priority;
}

void * quitAppsThread(void * ui)
{
	threadPriority();
	NSArray * appsToQuit = (NSArray*)ui;
	if (MC.legacyMode)
	{
		for (SBApplication * app in appsToQuit)
			[[MCListener sharedInstance] performSelectorOnMainThread:@selector(closeApp:) withObject:app waitUntilDone:YES];
	} else {
		for (SBApplication * app in appsToQuit)
			quitApp(app);
	}
	[appsToQuit release];
	return NULL;
}


void quitApp(SBApplication * app)
{
	[app setDeactivationSetting:0x10 flag:YES];
	[app deactivate];
}

extern "C" 
void quitAllApps()
{	
	SBAppSwitcherController * appSwitcher = [$SBAppSwitcherController sharedInstance];
	SBAppSwitcherModel * appSwitcherModel = [$SBAppSwitcherModel sharedInstance];
	
	NSMutableArray * appsToBeQuit = [[NSMutableArray alloc] initWithCapacity:[MC.runningApps count]];
	
	for (NSString * bundleID in [MC.runningApps allKeys])
	{
		SBApplication * app = [MC.runningApps objectForKey:bundleID];
		if (app==[SBWActiveDisplayStack topApplication])
			continue;
		if ([bundleID isEqual:SBBUNDLEID])
			continue;
		MCIndividualSettings * settings = [MC.settingsController settingsForBundleID:bundleID];
		if (settings.quitException)
			continue;
		[appsToBeQuit addObject:app];
	}
	if (MC.settings.quitMode==kQuitModeRemoveIcons)
	{
		int n = [appSwitcherModel count];
		NSMutableArray * appsToBeRemoved = [[NSMutableArray alloc] initWithCapacity:n];
		for (int i=0; i<n; i++)
		{
			SBApplication * app = [appSwitcherModel appAtIndex:i];
			NSString * bundleID = [app displayIdentifier];
			if ((!MC.settings.quitCurrentApp)&&(app==[SBWActiveDisplayStack topApplication]))
				continue;
			if ([bundleID isEqual:SBBUNDLEID])
				continue;
			if ([MC.settingsController settingsForBundleID:bundleID].pinned)
				continue;
			[appsToBeRemoved addObject:app];
		}
		for (SBApplication * app in appsToBeRemoved)
			removeApplicationFromBar(appSwitcher, app);
		[appsToBeRemoved release];
	}
	MCIndividualSettings * foregroundSettings = [MC.settingsController settingsForBundleID:[[SBWActiveDisplayStack topApplication] displayIdentifier]];
	if ((MC.settings.quitCurrentApp)&&!(foregroundSettings.quitException))
		quitForegroundAppAndReturn(MC.settings.quitMode==kQuitModeRemoveIcons);
	MC.legacyMode = MC.settings.legacyMode;
	pthread_t quitThread;
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	struct sched_param params;
	params.sched_priority=threadPriority();
	pthread_attr_setschedparam(&attr, &params);
	pthread_create(&quitThread, &attr, quitAppsThread, appsToBeQuit);
	pthread_attr_destroy(&attr);
}

#pragma mark -
#pragma mark Startup

%hook SBAppSwitcherController
-(void)viewWillAppear
{
	%orig;
	if (MC.settings.startupEdit)
		[self _beginEditing];
}
%end

static void (*SBAS_viewDidDisappear_orig)(SBAppSwitcherController * self, SEL _cmd) = NULL;
void SBAS_viewDidDisappear(SBAppSwitcherController * self, SEL _cmd)
{
	if ((MC.currentIcon)&&(MC.moved))
		[self icon:MC.currentIcon touchEnded:YES];
	if (SBAS_viewDidDisappear_orig)
		SBAS_viewDidDisappear_orig(self,_cmd);
}

%hook SpringBoard
-(void)menuButtonUp:(GSEventRef)event
{
	if ([MCListener sharedInstance].menuDown)
		[[MCListener sharedInstance] activationConfirmed];
	if ([MCListenerQuitAll sharedInstance].menuDown)
		[[MCListenerQuitAll sharedInstance] activationConfirmed];
	if ([MCListenerJustMin sharedInstance].menuDown)
		[[MCListenerJustMin sharedInstance] activationConfirmed];
	%orig;
}
%end

#pragma mark -
#pragma mark Icon reordering

void moveIconToBack(SBAppSwitcherController * self, SBApplicationIcon * icon)
{
	if (!icon) return;
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self,"_bottomBar");
	NSMutableArray * icons = (NSMutableArray*)[bottomBar appIcons];
	if (![icons containsObject:icon]) return;
	[icons removeObject:icon];
	int n = [icons count];
	while (n)
	{
		SBApplicationIcon * icn = [icons objectAtIndex:n-1];
		if (!iconIsApplicationIcon(icn))
			break;
		NSString * bID = [[icn application] displayIdentifier];
		if (!((![MC.runningApps objectForKey:bID])&&([MC.settingsController settingsForBundleID:bID].moveBack)))
			break;
		n--;
	}
	[icons insertObject:icon atIndex:n];
	modelAddBeforeClosed([$SBAppSwitcherModel sharedInstance], [icon application]);
	[bottomBar _reflowContent:YES];
	if (versionBigger(4,2))
		[bottomBar _adjustContentOffsetForReflow:YES];
}

void moveAppToBack(SBAppSwitcherController * self, SBApplication * app)
{
	if (!app) return;
	SBApplicationIcon * icon = iconForBundleID([app displayIdentifier]);
	if (icon)
		moveIconToBack(self, icon);
	else 
	{
		SBAppSwitcherModel * appModel = [$SBAppSwitcherModel sharedInstance];
		if (modelHasApp(appModel, app))
			modelAddBeforeClosed(appModel, app);
	}
}

%hook SBAppSwitcherController
-(BOOL)iconShouldAllowTap:(id)arg
{
	BOOL allowTap = MC.settings.allowTap;
	BOOL save;
	BOOL *inEditMode;
	if (allowTap)
	{
		inEditMode = &MSHookIvar<BOOL>(self, "_editing");
		save=(*inEditMode);
		(*inEditMode) = NO;
	}
	BOOL ret = %orig;
	if (allowTap)
		(*inEditMode) = save;
	return ret;
}

-(void)iconTouchBegan:(SBIcon *)icon
{
	BOOL allowTap = MC.settings.allowTap;
	BOOL save;
	BOOL *inEditMode;
	if (allowTap)
	{
		inEditMode = &MSHookIvar<BOOL>(self, "_editing");
		save=(*inEditMode);
		(*inEditMode) = NO;
	}
	%orig;
	if (allowTap)
		(*inEditMode) = save;
	MC.isApp = iconIsApplicationIcon(icon);
	NSString * bundleID = nil;
	if (MC.isApp)
	{
		bundleID = [[(SBApplicationIcon*)icon application] displayIdentifier];
		if ([bundleID isEqual:SBBUNDLEID])
			MC.isApp = NO;
	}
	if ([self _inEditMode])
	{
		if (MC.settings.reorderEdit)
		{
			MC.currentIcon = icon;
			MC.inPinnedArea = MC.isApp?[MC.settingsController settingsForBundleID:bundleID].pinned:NO;
			MC.lastindex = -1;
		}
	} else {
		if (MC.settings.reorderNonEdit)
		{
			MC.currentIcon = icon;
			MC.inPinnedArea = MC.isApp?[MC.settingsController settingsForBundleID:bundleID].pinned:NO;
			MC.lastindex = -1;
		}
	}
	
}
%end

SBIcon * placeholderIcon()
{
	static SBIcon * ph = nil;
	if (!ph)
	{
		ph = [[$SBApplicationIcon alloc] initWithDefaultSize];
		ph.tag = 4444;
		//[ph addSubview:[[[UIView alloc] initWithFrame:ph.bounds] autorelease]];
	}
	return ph;
}

%hook SBAppSwitcherController

%new(v@:@@)
-(void)icon:(SBIcon*)icon touchMovedWithEvent:(UIEvent*)event
{
	if (icon!=MC.currentIcon) return;
	SBAppSwitcherBarView * bar = MSHookIvar<SBAppSwitcherBarView*>(self, "_bottomBar");
	NSMutableArray * icons = (NSMutableArray*)[bar appIcons];
	if (!MC.moved)
	{
		UIScrollView * scroll = MSHookIvar<UIScrollView*>(bar, "_scrollView"); //to add to initForOrientation:
		[scroll setCanCancelContentTouches:NO];
		MC.moved = YES;
		MC.index = [icons indexOfObject:icon];
		MC.oldindex = MC.index;
		[icons removeObjectAtIndex:MC.index];
		[icons insertObject:placeholderIcon() atIndex:MC.index];
		[icon setExclusiveTouch:YES];
		
		[icon.superview bringSubviewToFront:icon];
		 
		[icon setIconImageAlpha:1.0f];
		[icon setIconLabelAlpha:1.0f];
		[UIView beginAnimations:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.1f];
		[icon setIsGrabbed:YES];
		[UIView commitAnimations];
	}
	int oindex = MC.index;
	
	BOOL hasPlaceHolder = ((oindex<(int)[icons count])&&(((UIView*)[icons objectAtIndex:oindex]).tag==4444));
	
	UITouch * touch = [[event touchesForView:icon] anyObject];
	CGFloat posy = [touch locationInView:bar].y;
	MC.isOutBack =  (bar.bounds.size.height-posy<=15);
	MC.isOut = (posy<0);
	
	if (!MC.isOut)
	{
		
		while (MC.index)
		{
			SBIcon * neighbor = [icons objectAtIndex:MC.index-1];
			CGFloat posx = [touch locationInView:neighbor].x;
			CGRect frame = neighbor.bounds;
			if (neighbor.tag==4445)
				break;
			if (neighbor.tag==4446)
				break;
			if (!(posx<=frame.origin.x+frame.size.width))
				break;
			MC.index--;
		}
		
		while (MC.index+(int)hasPlaceHolder<(int)[icons count])
		{
			SBIcon * neighbor = [icons objectAtIndex:MC.index+(int)hasPlaceHolder];
			CGFloat posx = [touch locationInView:neighbor].x;
			CGRect frame = neighbor.bounds;
			if (neighbor.tag==4445)
				break;
			if (neighbor.tag==4446)
				break;
			if (!(posx>=frame.origin.x))
				break;
			MC.index++;
		}
			
	}
	
	if (MC.isOut&&MC.lastindex<0)
		MC.lastindex = MC.index;
	if (!MC.isOut&&MC.lastindex>=0)
		MC.lastindex = -1;
	
	int last= [icons count] -1;
	if ([(UIView*)[icons objectAtIndex:last] tag]!=4444)
		last++;
	BOOL shouldHavePlaceHolder = (!MC.isOut)||((MC.isOut)&&(MC.index==last));

	
	if ((oindex!=MC.index)||(shouldHavePlaceHolder!=hasPlaceHolder))
	{
		if (hasPlaceHolder)
			[icons removeObjectAtIndex:oindex];
		if (shouldHavePlaceHolder)
			[icons insertObject:placeholderIcon() atIndex:MC.index];
		[bar _reflowContent:YES];
		if (versionBigger(4,2))
			[bar _adjustContentOffsetForReflow:YES];
	}
	CGPoint point = [touch locationInView:bar];
	CGRect barbounds = bar.bounds;
	if (rectContainsPoint(barbounds, point))
	{
		#define TRESH 20
		BOOL flipPage = ((point.x<=TRESH)||(point.x>=barbounds.origin.x+barbounds.size.width-TRESH));
		if (flipPage&&!MC.flipTimer)
		{
			MC.flipTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:[MCListener sharedInstance] selector:@selector(flipPageTimer:) userInfo:nil repeats:NO];
			MC.flipBack = (point.x<=TRESH);
		} 
		if (!flipPage&&MC.flipTimer)
		{
			[MC.flipTimer invalidate];
			MC.flipTimer = nil;
		}

	}
}

%new(v@:@c)
-(void)icon:(SBIcon*)icon touchEnded:(BOOL)ended
{
	if ((icon!=MC.currentIcon)||(!MC.moved)) return;
	SBAppSwitcherBarView * bar = MSHookIvar<SBAppSwitcherBarView*>(self, "_bottomBar");
	NSMutableArray * icons = (NSMutableArray*)[bar appIcons];
	
	BOOL hasPlaceHolder = ((MC.index<(int)[icons count])&&(((UIView*)[icons objectAtIndex:MC.index]).tag==4444));
	if (hasPlaceHolder)
	{
		[icons removeObject:placeholderIcon()];
		[placeholderIcon() removeFromSuperview];
	}
	
	UIScrollView * scroll = MSHookIvar<UIScrollView*>(bar, "_scrollView");
	
	[scroll setCanCancelContentTouches:YES];
	[icon setExclusiveTouch:NO]; 
	[icon setIsGrabbed:NO];
	
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:[[(SBApplicationIcon*)icon application] displayIdentifier]];
	BOOL isApp = iconIsApplicationIcon(icon);
	int swipeType = isApp?sett.swipeType:kSTNothing;
	if (isApp&&sett.pinned)
	{
		if (swipeType==kSTAppAndIcon)
			swipeType = kSTApp;
		if (swipeType==kSTIcon)
			swipeType = kSTNothing;
	}
	if ((swipeType==kSTApp)&&MC.isOut)
	{
		SBApplication * app = [(SBApplicationIcon*)icon application];
		if ([SBWActiveDisplayStack topApplication]==app)
			quitForegroundAppAndReturn(YES);
		else
			quitApp(app);
	}
	if (MC.isOut&&MC.settings.swipeQuit&&(swipeType!=kSTNothing)&&(swipeType!=kSTApp))
	{
		[icons addObject:icon];
		if (swipeType==kSTIcon)
		{
			removeApplicationFromBar(self, [(SBApplicationIcon*)icon application]);
		}
		else
		{
			MC.normalCloseTapped = YES;
			if (versionBigger(4,1))
			{
				[self performSelectorOnMainThread:@selector(iconCloseBoxTapped:) withObject:icon waitUntilDone:NO];
			} else {
				SBAppIconQuitButton * quitButton = [[$SBAppIconQuitButton alloc] init];
				quitButton.appIcon = (SBApplicationIcon*)icon;
				[self performSelectorOnMainThread:@selector(_quitButtonHit:) withObject:quitButton waitUntilDone:NO];
				[quitButton release];
			}
		}
		renumberSubviews(bar);
	} else {
		[icons insertObject:icon atIndex:MC.index];
		
		[UIView beginAnimations:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.1f];
		badgeAppIcon((SBApplicationIcon*)icon);
		[UIView commitAnimations];
		[bar _reflowContent:YES];
		if (versionBigger(4,2))
			[bar _adjustContentOffsetForReflow:YES];
		if (isApp&&(MC.index!=MC.oldindex))
		{
			SBApplication * app = [(SBApplicationIcon*)icon application];
			SBAppSwitcherModel * model = [$SBAppSwitcherModel sharedInstance];
			NSString * bundleID = [app displayIdentifier];
			
			modelRemove(model, app);
			NSMutableArray * apps = MSHookIvar<NSMutableArray*>(model, "_recentDisplayIdentifiers");
			if (!MC.index)
				modelAddToFront(model, app);
			else
			{
				SBApplicationIcon * prevIcon = MC.index?((SBApplicationIcon*)[icons objectAtIndex:MC.index-1]):nil;
				if (!prevIcon||(prevIcon.tag==4445))
					[apps insertObject:bundleID atIndex:0];
				else
				{
					NSString * prevBundleID = [[prevIcon application] displayIdentifier];
					[apps insertObject:bundleID atIndex:[apps indexOfObject:prevBundleID]+1];
				}
				[model _saveRecents];
			}
			
		}
		if (isApp)
		{
			if (MC.isOutBack)
				iconPinnedToTheBar(icon, kPinDrag);
			else
			{
				SBApplication * app = [(SBApplicationIcon*)icon application];
				NSString * bundleID = [app displayIdentifier];
				MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
				if (sett.pinned != MC.inPinnedArea)
					iconPinnedToTheBar(icon, kPinMove);
			}
		}
	}
	
	
	if (MC.flipTimer)
	{
		[MC.flipTimer invalidate];
		MC.flipTimer = nil;
	}
	
	MC.currentIcon = nil;
	MC.moved = NO;
}

%end

#pragma mark -
#pragma mark App Pinning

CGPoint firstPageOffset(SBAppSwitcherBarView * self, CGFloat width)
{
	if (versionBigger(4,2))
		return (CGPoint)[self _firstPageOffset:width];
	//else
	return [self _firstPageOffset];
}

int iconsPerPage(SBAppSwitcherBarView * self)
{
	if (versionBigger(4,2))
		return [self _iconCountForWidth:[self bounds].size.width];
	else
	return [[self class] iconsPerPage:MSHookIvar<int>(self,"_orientation")];

}

void renumberSubviews(SBAppSwitcherBarView * self)
{
	int nroph = MC.nrPlaceholders;
	MC.nrPlaceholders = 0;
	MC.nrPinned = 0;
	NSMutableArray * icons = (NSMutableArray*)[self appIcons];
	int n=[icons count];
	NSMutableIndexSet * indexSet = [[NSMutableIndexSet alloc] init];
	for (int i=0; i<n; i++)
	{
		SBApplicationIcon * icon = (SBApplicationIcon*)[icons objectAtIndex:i];
		if ([icon isApplicationIcon]&&[MC.settingsController settingsForBundleID:[[icon application] displayIdentifier]].pinned)
			MC.nrPinned++;
		if ((icon.tag==4444)&&(MC.inPinnedArea))
			MC.nrPinned++;
		if ((icon.tag==4445)||(icon.tag==4446))
			[indexSet addIndex:i];
	}
	[icons removeObjectsAtIndexes:indexSet];
	[indexSet release];
	int div = iconsPerPage(self);
	int nrph = (div - MC.nrPinned%div)%div;
	for (int i=0; i<nrph; i++)
	{
		SBApplicationIcon * pHolder = [[$SBApplicationIcon alloc] initWithDefaultSize];
		pHolder.tag = 4445;
		[icons insertObject:pHolder atIndex:0];
	}
	MC.nrPlaceholders = nrph;
	MC.oldindex += (MC.nrPlaceholders-nroph);
	MC.index += (MC.nrPlaceholders-nroph);
	if ([icons count]-MC.nrPlaceholders-MC.nrPinned==0)
	{
		SBApplicationIcon * pHolder = [[$SBApplicationIcon alloc] initWithDefaultSize];
		pHolder.tag = 4446;
		[icons addObject:pHolder];
	}
}

%hook SBAppSwitcherBarView
-(void)layoutSubviews
{
	renumberSubviews(self);
	%orig;
}


-(void)_positionAtFirstPage:(BOOL)animated
{
	CGRect bounds = self.bounds;
	CGPoint pnt = firstPageOffset(self,bounds.size.width);
	BOOL isPlaying = [[$SBMediaController sharedInstance] isPlaying];
	BOOL isEmpty = [[self appIcons] count]?(((SBApplicationIcon*)[[self appIcons] lastObject]).tag==4446):YES;
	BOOL shouldiPod = ((MC.settings.startupiPod)&&(((MC.settings.onlyWhenPlaying)&&isPlaying)
												   || ((MC.settings.onlyWhenEmpty)&&isEmpty)
												   || (!(MC.settings.onlyWhenPlaying)&&!(MC.settings.onlyWhenEmpty))));
	if (shouldiPod&&MC.settings.unlessMusic)
	{
		SBApplication * app = (SBApplication*)[[$SBMediaController sharedInstance] nowPlayingApplication];
		if ([app isEqual:[SBWActiveDisplayStack topApplication]])
			shouldiPod = NO;
	}
	int div = iconsPerPage(self);
	int pinned_pages = MC.nrPinned?((MC.nrPinned-1)/div)+1:0;
	BOOL shouldPinned = pinned_pages&&(MC.settings.startupPinned&&(!MC.settings.pinnedOnlyWhenEmpty || isEmpty));
	if (shouldPinned)
		pinned_pages--;
	if ((shouldiPod&&!shouldPinned)||(shouldiPod&&MC.settings.onlyWhenPlaying&&isPlaying))
		pnt.x -= bounds.size.width;
	else
		pnt.x += bounds.size.width * pinned_pages;
	UIScrollView * scroll = MSHookIvar<UIScrollView*>(self, "_scrollView");
	[scroll setContentOffset:pnt animated:animated];
}
%end

void iconPinnedToTheBar(SBApplicationIcon * icon, int type)
{
	if (!iconIsApplicationIcon(icon))
		return;
	[icon retain];
	SBApplication * app = [icon application];
	NSString * bundleID = [app displayIdentifier];
	if ([bundleID isEqual:SBBUNDLEID])
	{
		[icon release];
		return;
	}
	MCIndividualSettings * sett = [MC.settingsController newSettingsForBundleID:bundleID];
	MCIndividualSettings * global = [MC.settingsController settingsForBundleID:@"_global"];
	BOOL lock = sett.pinned = !sett.pinned;
	if ([sett isEqual:global])
	{
		[MC.settingsController removeSettingsForBundleID:bundleID];
		sett = global;
	}
	if (type!=kPinSett)
	{
		[UIHardware _playSystemSound:lock?1100:1101];
		UIImage * img = [UIImage imageNamed:lock?@"MultiCleaner_pinLock":@"MultiCleaner_pinUnlock"];
		MCImageView * imgView = [[MCImageView alloc] initWithImage:img];
		imgView.contentMode = UIViewContentModeScaleAspectFit;
		UIView * container = MSHookIvar<UIView*>(icon, "_iconImageContainer");
		CGRect bounds = [container bounds];
		imgView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
		[container addSubview:imgView];
		imgView.alpha = 1.0f;
		[UIView beginAnimations:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:1.0f];
		[UIView setAnimationDelegate:imgView];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		imgView.alpha = 0.0f;
		[UIView commitAnimations];
		[imgView release];
		[MC.settingsController saveSettings]; 
	}
	SBAppSwitcherController * controller = [$SBAppSwitcherController sharedInstance];
	SBAppSwitcherModel * model = [$SBAppSwitcherModel sharedInstance];
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(controller, "_bottomBar");
	BOOL keep = shouldKeepAppWithBundleID(bundleID);
	if (type!=kPinMove)
	{
		[app retain];
		if (bottomBar)
		{
			NSMutableArray * icons = (NSMutableArray*)[bottomBar appIcons];
			if ([icons containsObject:icon])
			{
				[icon retain];
				if (keep)
				{
					[icons removeObject:icon];
					int i=0,n = [icons count];
					for (i=0; i<n; i++)
					{
						SBApplicationIcon * icn = (SBApplicationIcon*)[icons objectAtIndex:i];
						if (icn==placeholderIcon())
							continue;
						if (icn.tag==4445)
							continue;
						if (![icn isApplicationIcon])
							continue;
						if ([MC.settingsController settingsForBundleID:[[icn application] displayIdentifier]].pinned)
							continue;
						break;
					}
					[icons insertObject:icon atIndex:i];
				} else
					removeApplicationFromBar(controller, app);
				[icon release];
			}
		}
		modelRemove(model, app);
		if (keep)
		{
			if (!lock&&sett.moveBack&&([MC.runningApps objectForKey:bundleID]==nil))
			{
				moveAppToBack(controller, app);
			}
			else
				modelAddToFront(model, app);
		}
		[app release];
	}
	else
		if (!keep)
			removeApplicationFromBar(controller, app);
	if (keep)
		badgeAppIcon(icon);
	int nrp = MC.nrPlaceholders;
	renumberSubviews(bottomBar);

	[bottomBar _reflowContent:YES];
	if (versionBigger(4,2))
		[bottomBar _adjustContentOffsetForReflow:YES];

	if (keep&&(type==kPinDrag))
	{
		int div = iconsPerPage(bottomBar);
		if ((MC.nrPlaceholders==div-1)&&(nrp==0)&&lock)
		{
			UIScrollView * scrollView = MSHookIvar<UIScrollView*>(bottomBar, "_scrollView");
			CGPoint offset = scrollView.contentOffset;
			CGFloat off = bottomBar.bounds.size.width;
			offset.x+=off;
			if (offset.x<scrollView.contentSize.width)
				[scrollView setContentOffset:offset animated:YES];
		}
		if ((MC.nrPlaceholders==0)&&(nrp==div-1)&&!lock)
		{
			UIScrollView * scrollView = MSHookIvar<UIScrollView*>(bottomBar, "_scrollView");
			CGPoint offset = scrollView.contentOffset;
			CGFloat off = - bottomBar.bounds.size.width;
			offset.x+=off;
			if (offset.x>=firstPageOffset(bottomBar, -off).x)
				[scrollView setContentOffset:offset animated:YES];
		}
	}
	[icon release];
}

#pragma mark -
#pragma mark Editing mode

//TODO

%hook SBIcon

%group post41
-(void)setShowsCloseBox:(BOOL)close
{
	if (MC.noCloseAnim&&iconIsApplicationIcon(self))
	{
		NSString * bundleID = [[(SBApplicationIcon*)self application] displayIdentifier];
		MCIndividualSettings * settings = [MC.settingsController settingsForBundleID:bundleID];
		BOOL running = ([MC.runningApps objectForKey:bundleID]!=nil);
		close = !(((settings.quitType==kQTApp)||(settings.pinned))&&!running);
	}
	%orig;
}
%end

%group pre41
-(void)setCloseBox:(id)box
{
	if (MC.noCloseAnim&&iconIsApplicationIcon(self))
	{
		NSString * bundleID = [[(SBApplicationIcon*)self application] displayIdentifier];
		MCIndividualSettings * settings = [MC.settingsController settingsForBundleID:bundleID];
		BOOL running = ([MC.runningApps objectForKey:bundleID]!=nil);
		BOOL showquit = !(((settings.quitType==kQTApp)||(settings.pinned))&&!running);
		if (!showquit)
			box = nil;
	} 
	%orig;
}
%end
%end

%hook SBAppSwitcherController

-(void)_beginEditing
{
	if (MC.settings.noEditMode)
		return;
	for (NSString * app in [MC.runningApps allKeys])
	{
		UIImageView * badge = [iconForBundleID(app) viewWithTag:4432];
		if (badge&&(MC.settings.badgeCorner==0))
		{
			[UIView beginAnimations:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
			[UIView setAnimationDuration:0.5f];
			badge.alpha = 0.0f;
			[UIView commitAnimations];
		}
	}
	MC.noCloseAnim = YES;
	%orig;
	MC.noCloseAnim = NO;
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self, "_bottomBar");
	NSArray * icons = [bottomBar appIcons];
	for (SBApplicationIcon * icon in icons)
		badgeAppIcon(icon);
	if (MC.settings.dontWriggle)
	{
		for (SBApplicationIcon * icon in icons)
			[icon setIsJittering:NO];
	}
}

-(void)_stopEditing
{
	if (MC.currentIcon)
	{
		[[$SBAppSwitcherController sharedInstance] icon:MC.currentIcon touchEnded:YES];
		MC.moved = NO;
		MC.currentIcon = nil;
	}
	%orig;
	for (NSString * app in [MC.runningApps allKeys])
	{
		SBApplicationIcon * icon = iconForBundleID(app);
		badgeAppIcon(icon);
		UIImageView * badge = [icon viewWithTag:4432];
		if (badge&&(MC.settings.badgeCorner==0))
		{
			badge.alpha = 0.0f;
			[UIView beginAnimations:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
			[UIView setAnimationDuration:0.5f];
			badge.alpha = 1.0f;
			[UIView commitAnimations];
		}
	}
	if (MC.settings.fastExit)
		[[$SBUIController sharedInstance] dismissSwitcher];
}
%end

#pragma mark -
#pragma mark SBAppSwitcherModel completion

%hook SBAppSwitcherModel
-(void)addToFront:(id)arg
{
	SBApplication * app;
	NSString * bundleID;
	if (versionBigger(4,2))
	{
		bundleID = (NSString*) arg;
		app = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:bundleID];
	} else {
		app =  (SBApplication*) arg;
		bundleID = [app displayIdentifier];
	}
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	[apps removeObject:bundleID];
	if (!shouldKeepAppWithBundleID(bundleID))
	{
		[self _saveRecents];
		return;
	}
	int i=0,n = [apps count];
	for (i=0; i<n; i++)
	{
		NSString * application = (NSString*)[apps objectAtIndex:i];
		if ([MC.settingsController settingsForBundleID:application].pinned)
			continue;
		break;
	}
	[apps insertObject:bundleID atIndex:i];
	[self _saveRecents];
	badgeApp(app);
}
%end 

void modelAddToFront(SBAppSwitcherModel * self, SBApplication * app)
{
	if (versionBigger(4,2))
		[self addToFront:[app displayIdentifier]];
	else 
		[self addToFront:app];
}

void modelAddToBack(SBAppSwitcherModel * self, SBApplication * app)
{
	NSString * bundleID = [app displayIdentifier];
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	[apps removeObject:bundleID];
	if (!shouldKeepAppWithBundleID(bundleID))
	{
		[self _saveRecents];
		return;
	}
	[apps addObject:bundleID];
	[self _saveRecents];
	badgeApp(app);
}

void modelAddBeforeClosed(SBAppSwitcherModel * self, SBApplication * app)
{
	NSString * bundleID = [app displayIdentifier];
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	[apps removeObject:bundleID];
	if (!shouldKeepAppWithBundleID(bundleID))
	{
		[self _saveRecents];
		return;
	}
	int n = [apps count];
	while (n)
	{
		NSString * bID = [apps objectAtIndex:n-1];
		if (!((![MC.runningApps objectForKey:bID])&&([MC.settingsController settingsForBundleID:bID].moveBack)))
			break;
		n--;
	}
	[apps insertObject:bundleID atIndex:n];
	[self _saveRecents];
	badgeApp(app);
}

bool modelHasApp(SBAppSwitcherModel * self, SBApplication * app)
{
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	NSString * bundleID = [app displayIdentifier];
	return [apps containsObject:bundleID];
}

void modelRemove(SBAppSwitcherModel * self, SBApplication * app)
{
	if (versionBigger(4,2))
		[self remove:[app displayIdentifier]];
	else
		[self remove:app];
}

#pragma mark -
#pragma mark App Icon

extern "C" 
void toggleBar(BOOL dontIgnore)
{
	//[[$SBUIController sharedInstance] _toggleSwitcher];
	SBUIController * UIController = [$SBUIController sharedInstance];
	if (dontIgnore)
		MC.notIgnoringEvents = YES;
	if ([UIController isSwitcherShowing])
	{
		[UIController dismissSwitcher];
	}
	else
	{
		[UIController activateSwitcher];
	}
	if (dontIgnore)
		MC.notIgnoringEvents = NO;
}

extern "C" 
void toggleBarEdit(BOOL dontIgnore)
{
	SBUIController * UIController = [$SBUIController sharedInstance];
	if (dontIgnore)
		MC.notIgnoringEvents = YES;
	if ([UIController isSwitcherShowing])
		[UIController dismissSwitcher];
	else {
		[UIController activateSwitcher];
		[[$SBAppSwitcherController sharedInstance] _beginEditing];
	}
	if (dontIgnore)
		MC.notIgnoringEvents = NO;
}

%hook SBUIController
-(BOOL)_ignoringEvents
{
	BOOL ret = %orig;
	if (MC.notIgnoringEvents)
		ret = NO;
	return ret;
}
%end

%hook SBApplicationIcon
-(void)launch
{
	if ((!isMultitaskingOff())&&([[[self application] displayIdentifier]isEqual:SWITCHERBUNDLEID]))
		toggleBar(NO);
	else
		if ([[[self application] displayIdentifier] isEqual:SBBUNDLEID])
		{
			//do nothing
		}
		else
			%orig;
}
%end

typedef BOOL (*LibHidePrototype)(NSString * bundleID);

void refreshAppStatus(BOOL state)
{
	void * libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
	if (libHandle == NULL)
	{
		MCLog(@"can't open libhide");
	}
	LibHidePrototype IsIconHiddenDisplayId = (LibHidePrototype)dlsym(libHandle, "IsIconHiddenDisplayId");
	if (!IsIconHiddenDisplayId) 
	{
		MCLog(@"can't get function pointer: IsIconHiddenDisplayId");
		dlclose(libHandle);
		return;
	}
	if (!IsIconHiddenDisplayId(SBBUNDLEID))
	{
		LibHidePrototype LibHideIconDisplayID = (LibHidePrototype)dlsym(libHandle,"HideIconViaDisplayId");
		if (!LibHideIconDisplayID)
		{
			MCLog(@"can't get function pointer: HideIconViaDisplayId");
		}
		else
			if (!LibHideIconDisplayID(SBBUNDLEID))
				MCLog(@"can't hide SpringBoard icon");
	}
	
	BOOL sett = !IsIconHiddenDisplayId(SWITCHERBUNDLEID);
	if (sett==state)
	{
		dlclose(libHandle);
		return;
	}
	
	LibHidePrototype LibHideIconDisplayID = (LibHidePrototype)dlsym(libHandle, state?"UnHideIconViaDisplayId":"HideIconViaDisplayId");
	if (!LibHideIconDisplayID)
	{
		MCLog(@"can't get function pointer: %s",state?"UnHideIconViaDisplayId":"HideIconViaDisplayId");
		dlclose(libHandle);
		return;
	}
	if (!LibHideIconDisplayID(SWITCHERBUNDLEID))
	{
		MCLog(@"can't hide/unhide icon");
	}
	notify_post("com.libhide.hiddeniconschanged");
	dlclose(libHandle);
}

#pragma mark -
#pragma mark SpringBoard Icon

%hook SBAppSwitcherController
-(void)iconTapped:(SBIcon*)icon
{
	if (iconIsApplicationIcon(icon)&&[[[(SBApplicationIcon*)icon application] displayIdentifier] isEqual:SBBUNDLEID])
	{
		minimizeForegroundApp();
	}
	else
		%orig;
}
%end

void addSBIcon()
{
	[[$SBAppSwitcherController sharedInstance] applicationLaunched:[[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:SBBUNDLEID]];
}

void remSBIcon()
{
	[[$SBAppSwitcherController sharedInstance] applicationDied:[[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:SBBUNDLEID]];
}

%hook SBApplication
-(void)activateApplicationAnimated:(SBApplication*)app
{
	%orig;
	addSBIcon();
}

-(void)activateApplicationFromSwitcher:(SBApplication*)app
{
	%orig;
	addSBIcon();
}

-(void)animateApplicationSuspend:(SBApplication*)app
{
	%orig;
	remSBIcon();
}
%end

#pragma mark -
#pragma mark Gestures

%group post43
%hook SBUIController
-(void)_calculateSwitchAppList
{
	NSMutableArray * & applist = MSHookIvar<NSMutableArray*>(self,"_switchAppFullyOrderedList");
	//Original(SBUIC_calculateAppList)(self,_cmd);
	if (applist) return;
	NSMutableArray * list = [[NSMutableArray alloc] init];
	SBApplication * topApp = [SBWActiveDisplayStack topApplication];
	NSString * topAppBundleID = [topApp displayIdentifier];
	if ([[topApp bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		return;
	NSArray * appIcons = [[[$SBAppSwitcherController sharedInstance] switcherViewForApp:topApp orientation:1] appIcons];
	BOOL shouldAdd = YES;
	for (SBIcon * icon in appIcons)
	{
		if (![icon isKindOfClass:$SBApplicationIcon]) continue;
		SBApplication * app = [(SBApplicationIcon*)icon application];
		if (!app) continue;
		if ([[app displayIdentifier] isEqualToString:topAppBundleID])
			shouldAdd = NO;
		[list addObject:app];
	}
	if (shouldAdd)
	{
		NSUInteger index = 0;
		NSUInteger n = [list count];
		for (index = 0; index<n; index++)
		{
			SBApplication * app = [list objectAtIndex:index];
			NSString * bundleID = [app displayIdentifier];
			if (!([MC.settingsController settingsForBundleID:bundleID].pinned))
				break;
		}
		[list insertObject:topApp atIndex:index];
	}
	applist = list;	
}
%end
%end

#pragma mark -
#pragma mark Init Hooks

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)app
{
	%orig;
	MC.settingsController = [MCSettingsController sharedInstance];
	MC.settings = [MCSettings sharedInstance];
	[MC.settingsController registerForMessage:@"pinnedChanged" target:[MCListener sharedInstance] selector:@selector(pinnedChanged:userInfo:)];
}
%end

%hook SBApplication

-(BOOL)_shouldAutoLaunchOnBootOrInstall:(BOOL)ok
{
	BOOL res = %orig;
	if (res)
	{
		NSString * bundleID = [self displayIdentifier];
		if ((![MC.runningApps objectForKey:bundleID])&&([MC.settingsController settingsForBundleID:bundleID].autolaunch))
		{
			if (![MC.autostartedApps objectForKey:bundleID])
			{
				[[$SBAppSwitcherController sharedInstance] applicationLaunched:self];
				[MC.autostartedApps setObject:self forKey:bundleID];
			}
		}
	}
	return res;
}
%end

BOOL isMultitaskingOff()
{
	return (![[$SBPlatformController sharedInstance] hasCapability:@"multitasking"]);
}

static __attribute__((constructor)) void init() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
#ifdef BETA_VERSION
		NSDate * date = [NSDate date];
		if ([date compare:[NSDate dateWithString:BETA_VERSION]]==NSOrderedDescending)
			return;
#endif
		
		MC.runningApps = [[NSMutableDictionary alloc] init];
		MC.autostartedApps = [[NSMutableDictionary alloc] init];
		MC.displayStacks = [[NSMutableArray alloc] initWithCapacity:4];
		MC.moved = NO;
		MC.currentIcon = nil;
		MC.flipTimer = nil;
		MC.isOut = NO;
		MC.isOutBack = NO;
		MC.normalCloseTapped = NO;
		MC.legacyMode = NO;
		MC.keepAllApps = NO;
		MC.nrPinned = 0;
		MC.nrPlaceholders = 0;
		MC.inPinnedArea = NO;
		MC.isApp = YES;
		MC.noCloseAnim = NO;
		MC.lastBundleID = nil;
		MC.bypassPhone = NO;
		MC.notIgnoringEvents = NO;
		
		struct utsname u;
		uname(&u);
		if (strncmp("iPad", u.machine, 4)==0)
			MC.iPad = YES;
		else
			MC.iPad = NO;
		
		NSDictionary * sysVersionDict = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
		NSString * version = [sysVersionDict objectForKey:@"ProductVersion"];
		if (!version)
		{
			version = [[UIDevice currentDevice] systemVersion];
			MCLog(@"Couldn't get ProductVersion from /System/Library/CoreServices/SystemVersion.plist ... Defaulting to [[UIDevice currentDevice] systemVersion]");
		}
		MC.majorSysVersion = 0;
		MC.minorSysVersion = 0;
		MC.bugfixSysVersion = 0;
		sscanf([version UTF8String],"%d.%d.%d",&MC.majorSysVersion,&MC.minorSysVersion,&MC.bugfixSysVersion);
		[sysVersionDict release];
		
		$SBAppSwitcherController = objc_getClass("SBAppSwitcherController");
		$SpringBoard = objc_getClass("SpringBoard");
		$SBAppSwitcherModel = objc_getClass("SBAppSwitcherModel");
		$SBDisplayStack = objc_getClass("SBDisplayStack");
		$SBApplication = objc_getClass("SBApplication");
		$SBApplicationController = objc_getClass("SBApplicationController");
		$SBIcon = objc_getClass("SBIcon");
		$SBApplicationIcon = objc_getClass("SBApplicationIcon");
		$SBUIController =objc_getClass("SBUIController");
		$SBAppIconQuitButton = objc_getClass("SBAppIconQuitButton");
		$SBMediaController = objc_getClass("SBMediaController");
		$SBPlatformController = objc_getClass("SBPlatformController");
		$SBAppSwitcherBarView = objc_getClass("SBAppSwitcherBarView");
		$SBIconModel = objc_getClass("SBIconModel");
		$SBCallAlertDisplay = objc_getClass("SBCallAlertDisplay");
		$SBAwayController = objc_getClass("SBAwayController");
		
		%init
		
		if (versionBigger(4,1))
			%init(post41);
		else
			%init(pre41);

		if (versionBigger(4,3))
			%init(post43);
		
		if ([$SBAppSwitcherController instancesRespondToSelector:@selector(viewDidDisappear)])
			MSHookMessageEx($SBAppSwitcherController,@selector(viewDidDisappear),(IMP)SBAS_viewDidDisappear,(IMP*)&SBAS_viewDidDisappear_orig);
		else
			class_addMethod($SBAppSwitcherController,@selector(viewDidDisappear),(IMP)SBAS_viewDidDisappear,"v@:");
		
		[MCListener sharedInstance];
		[MCListenerQuitAll sharedInstance];
		[MCListenerOpenBar sharedInstance];
		[MCListenerLastClosed sharedInstance];
		[MCListenerJustMin sharedInstance];
		[MCListenerOpenEdit sharedInstance];
		
		MCLog(@"Finished loading");
	}
    [pool release];
}
