//
//  MultiCleaner.mm
//  MultiCleaner
//
//  Created by Marius Petcu on 9/6/10.
//  Copyright Home 2010. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//

#define appName MultiCleaner

#include <substrate.h>
#include <substrate2.h>
#include <pthread.h>

#import <SpringBoard/SpringBoard.h>

#import "MultiCleaner.h"
#import "MCListener.h"
#import "MCListenerQuitAll.h"
#import "MCSettingsController.h"

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

struct MultiCleanerVars {
	MCSettingsController * settingsController;
	MCSettings * settings;
	NSMutableDictionary * runningApps;
	NSMutableArray * displayStacks;
	SBIcon * currentIcon;
	bool moved;
	UIView * iconSuperView;
	int index;
	int oldindex;
	NSTimer * flipTimer;
	BOOL flipBack;
	BOOL editMode;
	BOOL isOut;
	float sysVersion;
	BOOL normalCloseTapped;
};
static struct MultiCleanerVars MC;

#define SBWPreActivateDisplayStack        ((SBDisplayStack *)[MC.displayStacks objectAtIndex:0])
#define SBWActiveDisplayStack             ((SBDisplayStack *)[MC.displayStacks objectAtIndex:1])
#define SBWSuspendingDisplayStack         ((SBDisplayStack *)[MC.displayStacks objectAtIndex:2])
#define SBWSuspendedEventOnlyDisplayStack ((SBDisplayStack *)[MC.displayStacks objectAtIndex:3])

inline BOOL versionBigger(float ver)
{
	return (MC.sysVersion-0.000001)<=ver;
}

@interface MCListener(MCMisc)
-(void)resumeMenu;
-(void)flipPageTimer:(id)userinfo;
@end

void removeApplicationFromBar(SBAppSwitcherController * self, SBApplication * app);
BOOL shouldKeepAppWithBundleID(NSString * bundleID);
void badgeAppIcon(SBApplicationIcon * app);
void moveIconToBack(SBAppSwitcherController * self, SBApplicationIcon * icon);
void moveAppToBack(SBAppSwitcherController * self, SBApplication * app);
void badgeApp(SBApplication * app);
void quitForegroundAppAndReturn(BOOL keepIcon);
void quitApp(SBApplication * app);


@implementation MCListener(MCMisc)
-(void)resumeMenu
{
	[[$SBUIController sharedInstance] activateSwitcher];
	if (MC.editMode)
		[[$SBAppSwitcherController sharedInstance] _beginEditing];
}
-(void)flipPageTimer:(id)userinfo
{
	MC.flipTimer = nil;
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>([$SBAppSwitcherController sharedInstance],"_bottomBar");
	UIScrollView * scrollView = MSHookIvar<UIScrollView*>(bottomBar, "_scrollView");
	CGPoint offset = scrollView.contentOffset;
	CGFloat off = (MC.flipBack?(-1):1)*bottomBar.frame.size.width;
	offset.x+=off;
	if (offset.x>=scrollView.contentSize.width) return;
	if (offset.x<=0) return;
	CGPoint iconCenter = MC.currentIcon.center;
	iconCenter.x+=off;
	[scrollView setContentOffset:offset animated:YES];
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //TODO: find right values
	[UIView setAnimationDuration:0.2f];
	MC.currentIcon.center=iconCenter;
	[UIView commitAnimations];
	
}
@end

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

DefineObjCHook(id, SBDS_init, SBDisplayStack * self, SEL _cmd)
{
	if (self=Original(SBDS_init)(self,_cmd))
	{
		[MC.displayStacks addObject:self];
	}
	return self;
}

DefineObjCHook(void, SBDS_dealloc, SBDisplayStack * self, SEL _cmd)
{
	[MC.displayStacks removeObject:self];
	Original(SBDS_dealloc);
}

#pragma mark Settings reloading

extern "C"
void settingsReloaded()
{
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
		if (!icon&&!hidden)
		{
			[appSwitcherModel addToFront:app];
			icon = iconForBundleID(appid);
		}
		if (hidden&&icon)
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
			if (![icon isKindOfClass:[$SBApplicationIcon class]]) continue;
			NSString * bundleID = [[icon application] displayIdentifier];
			if ((![MC.runningApps objectForKey:bundleID])&&([MC.settingsController settingsForBundleID:bundleID].moveBack))
				moveIconToBack(appSwitcher, icon);
		}
		[icons release];
	}
}

#pragma mark App hiding

BOOL shouldKeepAppWithBundleID(NSString * bundleID)
{
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
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

DefineObjCHook(void, SBAS_applicationLaunched_,SBAppSwitcherController* self, SEL _cmd, SBApplication * app)
{
	NSString * bundleID = [app displayIdentifier];
	[MC.runningApps setObject:app forKey:bundleID];
	SBAppSwitcherModel * model = [$SBAppSwitcherModel sharedInstance];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if ([model hasApp:app])
	{
		if (!sett.dontMoveToFront)
			Original(SBAS_applicationLaunched_)(self,_cmd,app);
	} else {
		switch (sett.launchType) {
			case kLTBack:
				[model addToBack:app];
				break;
			case kLTBeforeClosed:
				[model addBeforeClosed:app];
				break;
			default:
				Original(SBAS_applicationLaunched_)(self,_cmd,app);
				break;
		}
		
	}
	//NSMutableArray * apps = MSHookIvar<NSMutableArray*>(model, "_recentDisplayIdentifiers");
}


DefineObjCHook(void, SBAS_applicationDied_,SBAppSwitcherController* self, SEL _cmd, SBApplication * app)
{
	NSString * bundleID = [app displayIdentifier];
	[MC.runningApps removeObjectForKey:bundleID];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:bundleID];
	if (sett.autoclose)		
		removeApplicationFromBar(self,app);
	if (!(sett.autoclose))
	{
		badgeApp(app);
		if ([MC.settingsController settingsForBundleID:bundleID].moveBack)
			moveAppToBack(self, app);
	}
	Original(SBAS_applicationDied_)(self,_cmd,app);
}

DefineObjCHook(id, SBM__recentsFromPrefs, SBAppSwitcherModel * self, SEL _cmd)
{
	NSArray * ret = Original(SBM__recentsFromPrefs)(self,_cmd);
	NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:[ret count]];
	for (NSString * app in ret)
	{
		if (shouldKeepAppWithBundleID(app))
			[arr addObject: app];
	}
	[arr autorelease];
	return arr;
}

DefineObjCHook(void, SBM_addToFront_, SBAppSwitcherModel * self, SEL _cmd, SBApplication * app)
{
	if (shouldKeepAppWithBundleID([app displayIdentifier]))
	{
		Original(SBM_addToFront_)(self,_cmd,app);
		badgeApp(app);
	}
}

#pragma mark Icon badging

void badgeAppIcon(SBApplicationIcon * app)
{
	NSString * bundleID = [[app application] displayIdentifier];
	MCIndividualSettings * settings = [MC.settingsController settingsForBundleID:bundleID];
	BOOL running = ([MC.runningApps objectForKey:bundleID]!=nil);
	BOOL badge = ((running&&(settings.runningBadge))&&!([[$SBAppSwitcherController sharedInstance] _inEditMode]&&(MC.settings.badgeCorner==0)));
	BOOL dim = (((!running)||(settings.alwaysDim))&&(settings.dimClosed));
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
		UIView * container = ((UIView*)MSHookIvar<SBIcon*>(app, "_iconImageContainer"));
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

DefineObjCHook(SBApplicationIcon*, SBAS__iconForApplication_, SBAppSwitcherController * self, SEL _cmd, SBApplication * app)
{
	SBApplicationIcon * icon = Original(SBAS__iconForApplication_)(self,_cmd,app);
	badgeAppIcon(icon);
	return icon;
}

#pragma mark Show current app

DefineObjCHook(id,SBAS__applicationIconsExcept_forOrientation_,SBAppSwitcherController * self, SEL _cmd, id except,int orient)
{
	NSString * bundleID = @"_global";
	SBApplication * app = (SBApplication*)except;
	if (app)
		bundleID = [app displayIdentifier];
	id _except = except;
	if ([MC.settingsController settingsForBundleID:bundleID].showCurrent)
		_except = nil;
	return Original(SBAS__applicationIconsExcept_forOrientation_)(self,_cmd,_except,orient);
}

BOOL iconCloseTapped(SBAppSwitcherController * self,SBApplicationIcon * icon)
{
	SBApplication * app = [icon application];
	MCIndividualSettings * sett = [MC.settingsController settingsForBundleID:[app displayIdentifier]];
	if (MC.normalCloseTapped)
	{
		if (app == [SBWActiveDisplayStack topApplication])
		{
			quitForegroundAppAndReturn(NO);
			return NO;
		}
		return YES;
	}
	if (sett.quitType==kQTIcon)
	{
		removeApplicationFromBar(self, app);
		return NO;
	}
	if (app == [SBWActiveDisplayStack topApplication])
	{
		quitForegroundAppAndReturn(sett.quitType==kQTApp);
		return NO;
	} 
	if (sett.quitType==kQTApp)
	{
		quitApp(app);
		return NO;
	}
	return YES;
}

DefineObjCHook(void,SBAS__quitHit_,SBAppSwitcherController * self, SEL _cmd, SBAppIconQuitButton * button)
{
	SBApplicationIcon * icon = [button appIcon];
	if (iconCloseTapped(self,icon))
		Original(SBAS__quitHit_)(self,_cmd,button);
}

DefineObjCHook(void,SBAS_closeTapped_,SBAppSwitcherController * self, SEL _cmd, SBApplicationIcon * icon)
{
	if (![icon isApplicationIcon]||iconCloseTapped(self,icon))
		Original(SBAS_closeTapped_)(self,_cmd,icon);
}

#pragma mark App quitting

extern "C"
void quitForegroundApp()
{
	SBApplication * app = [SBWActiveDisplayStack topApplication];
	[app setDeactivationSetting:0x2 flag:YES]; //animate flag
	[app setDeactivationSetting:0x10 flag:YES]; //forceExit flag
	[SBWActiveDisplayStack popDisplay:app];
	[SBWSuspendingDisplayStack pushDisplay:app];
}

void quitForegroundAppAndReturn(BOOL keepIcon)
{
	if ([[$SBUIController sharedInstance] isSwitcherShowing])
	{
		SBApplication * app = [SBWActiveDisplayStack topApplication];
		SBAppSwitcherController * appSwitcher = [$SBAppSwitcherController sharedInstance];
		if (!keepIcon)
			removeApplicationFromBar(appSwitcher, app);
		//TODO: Find a better way to call resumeMenu
		MC.editMode = [appSwitcher _inEditMode];
		if ([[MSHookIvar<SBAppSwitcherBarView*>(appSwitcher,"_bottomBar") appIcons] count]!=0)
			[[MCListener sharedInstance] performSelector:@selector(resumeMenu) withObject:nil afterDelay:0.3];
	}
	quitForegroundApp();
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
	for (SBApplication * app in appsToQuit)
		quitApp(app);
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
		if ([MC.settingsController settingsForBundleID:bundleID].quitException)
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
			if ((!MC.settings.quitCurrentApp)&&(app==[SBWActiveDisplayStack topApplication]))
				continue;
			if ([MC.settingsController settingsForBundleID:[app displayIdentifier]].quitException)
				continue;
			[appsToBeRemoved addObject:app];
		}
		for (SBApplication * app in appsToBeRemoved)
			removeApplicationFromBar(appSwitcher, app);
		[appsToBeRemoved release];
	}
	if ((MC.settings.quitCurrentApp)&&!([MC.settingsController settingsForBundleID:
										  [[SBWActiveDisplayStack topApplication] displayIdentifier] ].quitException))
		quitForegroundAppAndReturn(NO);
	pthread_t quitThread;
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	struct sched_param params;
	params.sched_priority=threadPriority();
	pthread_attr_setschedparam(&attr, &params);
	pthread_create(&quitThread, &attr, quitAppsThread, appsToBeQuit);
	pthread_attr_destroy(&attr);
}

#pragma mark Startup

DefineObjCHook(void,SBAS_viewWillAppear,SBAppSwitcherController * self, SEL _cmd)
{
	Original(SBAS_viewWillAppear)(self,_cmd);
	if (MC.settings.startupEdit)
		[self _beginEditing];
	if ((MC.settings.startupiPod)&&((!MC.settings.onlyWhenPlaying)||[[$SBMediaController sharedInstance] isPlaying]))
	{
		SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self,"_bottomBar");
		UIScrollView * scrollView = MSHookIvar<UIScrollView*>(bottomBar, "_scrollView");
		CGPoint pnt = [scrollView contentOffset];
		pnt.x-=[scrollView bounds].size.width;
		[scrollView setContentOffset:pnt animated:YES]; //for some reason it doesen't work with animated=NO
	}
}

DefineObjCHook(void,SB_menuButtonUp_,SpringBoard * self, SEL _cmd, GSEventRef event)
{
	if ([MCListener sharedInstance].menuDown)
		[[MCListener sharedInstance] activationConfirmed];
	if ([MCListenerQuitAll sharedInstance].menuDown)
		[[MCListenerQuitAll sharedInstance] activationConfirmed];
	Original(SB_menuButtonUp_)(self,_cmd,event);
}

#pragma mark Icon reordering

void moveIconToBack(SBAppSwitcherController * self, SBApplicationIcon * icon)
{
	if (!icon) return;
	SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self,"_bottomBar");
	NSMutableArray * icons = (NSMutableArray*)[bottomBar appIcons];
	if (![icons containsObject:icon]) return;
	[icons removeObject:icon];
	[icons addObject:icon];
	[bottomBar _reflowContent:YES];
	[[$SBAppSwitcherModel sharedInstance] addToBack:[icon application]];
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
		if ([appModel hasApp:app])
			[appModel addToBack:app];
	}
}

DefineObjCHook(BOOL,SBAS_iconShouldAllowTap_,SBAppSwitcherController * self, SEL _cmd,id arg)
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
	BOOL ret = Original(SBAS_iconShouldAllowTap_)(self,_cmd,arg);
	if (allowTap)
		(*inEditMode) = save;
	return ret;
}

DefineObjCHook(void,SBAS_iconTouchBegan_,SBAppSwitcherController * self, SEL _cmd,SBIcon * icon)
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
	Original(SBAS_iconTouchBegan_)(self,_cmd,icon);
	if (allowTap)
		(*inEditMode) = save;
	if ([self _inEditMode])
	{
		if (MC.settings.reorderEdit)
			MC.currentIcon = icon;
	} else {
		if (MC.settings.reorderNonEdit)
			MC.currentIcon = icon;
	}
	
}

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

void SBASC_icon_touchMovedwithEvent_(SBAppSwitcherController * self, SEL _cmd, SBIcon * icon, UIEvent * event)
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
	
	BOOL hasPlaceHolder = ((oindex<[icons count])&&(((UIView*)[icons objectAtIndex:oindex]).tag==4444));
	
	UITouch * touch = [[event touchesForView:icon] anyObject];
	CGFloat posy = [touch locationInView:bar].y;
	MC.isOut = (posy<0);
	
	while (MC.index)
	{
		UIView * neighbor = [icons objectAtIndex:MC.index-1];
		CGFloat posx = [touch locationInView:neighbor].x;
		CGRect frame = neighbor.bounds;
		if (!(posx<=frame.origin.x+frame.size.width))
			break;
		MC.index--;
	}
	
	while (MC.index+(int)hasPlaceHolder<[icons count])
	{
		UIView * neighbor = [icons objectAtIndex:MC.index+(int)hasPlaceHolder];
		CGFloat posx = [touch locationInView:neighbor].x;
		CGRect frame = neighbor.bounds;
		if (!(posx>=frame.origin.x))
			break;
		MC.index++;
	}
	
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

void SBASC_icon_touchEnded_(SBAppSwitcherController * self, SEL _cmd, SBIcon * icon, BOOL ended)
{
	if ((icon!=MC.currentIcon)||(!MC.moved)) return;
	SBAppSwitcherBarView * bar = MSHookIvar<SBAppSwitcherBarView*>(self, "_bottomBar");
	NSMutableArray * icons = (NSMutableArray*)[bar appIcons];
	
	BOOL hasPlaceHolder = ((MC.index<[icons count])&&(((UIView*)[icons objectAtIndex:MC.index]).tag==4444));
	if (hasPlaceHolder)
	{
		[icons removeObject:placeholderIcon()];
		[placeholderIcon() removeFromSuperview];
	}
	
	UIScrollView * scroll = MSHookIvar<UIScrollView*>(bar, "_scrollView");
	
	[scroll setCanCancelContentTouches:YES];
	[icon setExclusiveTouch:NO]; 
	if (MC.isOut&&MC.settings.swipeQuit)
	{
		[icons addObject:icon];
		if ([MC.settingsController settingsForBundleID:[[(SBApplicationIcon*)icon application] displayIdentifier]].swipeNoQuit)
		{
			removeApplicationFromBar(self, [(SBApplicationIcon*)icon application]);
		}
		else
		{
			MC.normalCloseTapped = YES;
			if (versionBigger(4.1))
			{
				[self performSelectorOnMainThread:@selector(iconCloseBoxTapped:) withObject:icon waitUntilDone:NO];
			} else {
				SBAppIconQuitButton * quitButton = [[$SBAppIconQuitButton alloc] init];
				quitButton.appIcon = (SBApplicationIcon*)icon;
				[self performSelectorOnMainThread:@selector(_quitButtonHit:) withObject:quitButton waitUntilDone:NO];
				[quitButton release];
			}
			MC.normalCloseTapped = NO;
		}
	} else {
		[icons insertObject:icon atIndex:MC.index];
		
		[UIView beginAnimations:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.1f];
		badgeAppIcon((SBApplicationIcon*)icon);
		[icon setIsGrabbed:NO];
		[UIView commitAnimations];
		[bar _reflowContent:YES];
		if (MC.index!=MC.oldindex)
		{
			SBApplication * app = [(SBApplicationIcon*)icon application];
			SBAppSwitcherModel * model = [$SBAppSwitcherModel sharedInstance];
			[model remove:app];
			NSMutableArray * apps = MSHookIvar<NSMutableArray*>(model, "_recentDisplayIdentifiers");
			if (!MC.index)
				[model addToFront:app];
			else
			{
				NSString * bundleID = [[(SBApplicationIcon*)icon application] displayIdentifier];
				NSString * prevBundleID = [[((SBApplicationIcon*)[icons objectAtIndex:MC.index-1]) application] displayIdentifier];
				[apps insertObject:bundleID atIndex:[apps indexOfObject:prevBundleID]+1];
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

#pragma mark Editing mode

DefineObjCHook(void, SBAS__beginEditing, SBAppSwitcherController * self, SEL _cmd)
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
	Original(SBAS__beginEditing)(self,_cmd);
	if (MC.settings.dontWriggle)
	{
		SBAppSwitcherBarView * bottomBar = MSHookIvar<SBAppSwitcherBarView*>(self, "_bottomBar");
		NSArray * icons = [bottomBar appIcons];
		for (SBApplicationIcon * icon in icons)
		{
			[icon setIsJittering:NO];
		}
		
	}
}

DefineObjCHook(void, SBAS__stopEditing, SBAppSwitcherController * self, SEL _cmd)
{
	if (MC.currentIcon)
	{
		[[$SBAppSwitcherController sharedInstance] icon:MC.currentIcon touchEnded:YES];
		MC.moved = NO;
		MC.currentIcon = nil;
	}
	Original(SBAS__stopEditing)(self,_cmd);
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

#pragma mark SBAppSwitcherModel completion

void SBASM_addToBack_(SBAppSwitcherModel * self, SEL _cmd, SBApplication * app)
{
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	NSString * bundleID = [app displayIdentifier];
	if ([apps containsObject:bundleID])
		[apps removeObject:bundleID];
	[apps addObject:bundleID];
	[self _saveRecents];
}

void SBASM_addBeforeClosed_(SBAppSwitcherModel * self, SEL _cmd, SBApplication * app)
{
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	NSString * bundleID = [app displayIdentifier];
	if ([apps containsObject:bundleID])
		[apps removeObject:bundleID];
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
}

bool SBASM_hasApp_(SBAppSwitcherModel * self, SEL _cmd, SBApplication * app)
{
	NSMutableArray * apps = MSHookIvar<NSMutableArray*>(self, "_recentDisplayIdentifiers");
	NSString * bundleID = [app displayIdentifier];
	return [apps containsObject:bundleID];
}

#pragma mark Init Hooks

DefineObjCHook(void, SB_applicationDidFinishLaunching_,SpringBoard * self, SEL _cmd, id app)
{
	MC.settingsController = [MCSettingsController sharedInstance];
	MC.settings = [MCSettings sharedInstance];
	Original(SB_applicationDidFinishLaunching_)(self,_cmd,app);
}

extern "C" void MultiCleanerInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		MC.runningApps = [[NSMutableDictionary alloc] init];
		MC.displayStacks = [[NSMutableArray alloc] initWithCapacity:4];
		MC.moved = NO;
		MC.currentIcon = nil;
		MC.flipTimer = nil;
		MC.isOut = NO;
		MC.normalCloseTapped = NO;
		MC.sysVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
			
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
		
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(applicationDied:),SBAS_applicationDied_);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(applicationLaunched:),SBAS_applicationLaunched_);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(_iconForApplication:),SBAS__iconForApplication_);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(_beginEditing),SBAS__beginEditing);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(_stopEditing),SBAS__stopEditing);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(_applicationIconsExcept:forOrientation:),SBAS__applicationIconsExcept_forOrientation_);
		if (versionBigger(4.1))
			InstallObjCInstanceHook($SBAppSwitcherController,@selector(iconCloseBoxTapped:),SBAS_closeTapped_);
		else
			InstallObjCInstanceHook($SBAppSwitcherController,@selector(_quitButtonHit:),SBAS__quitHit_);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(viewWillAppear),SBAS_viewWillAppear);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(iconTouchBegan:),SBAS_iconTouchBegan_);
		InstallObjCInstanceHook($SBAppSwitcherController,@selector(iconShouldAllowTap:),SBAS_iconShouldAllowTap_);
		InstallObjCInstanceHook($SpringBoard,@selector(applicationDidFinishLaunching:),SB_applicationDidFinishLaunching_);
		InstallObjCInstanceHook($SpringBoard,@selector(menuButtonUp:),SB_menuButtonUp_);
		InstallObjCInstanceHook($SBAppSwitcherModel,@selector(_recentsFromPrefs),SBM__recentsFromPrefs);
		InstallObjCInstanceHook($SBAppSwitcherModel,@selector(addToFront:),SBM_addToFront_);
		InstallObjCInstanceHook($SBDisplayStack,@selector(init),SBDS_init);
		InstallObjCInstanceHook($SBDisplayStack,@selector(dealloc),SBDS_dealloc);
		
		class_addMethod($SBAppSwitcherModel, @selector(addToBack:), (IMP)&SBASM_addToBack_ , "v@:@");
		class_addMethod($SBAppSwitcherModel, @selector(addBeforeClosed:), (IMP)&SBASM_addBeforeClosed_ , "v@:@");
		class_addMethod($SBAppSwitcherModel, @selector(hasApp:), (IMP)&SBASM_hasApp_ , "B@:@");
		class_addMethod($SBAppSwitcherController, @selector(icon:touchMovedWithEvent:), (IMP)&SBASC_icon_touchMovedwithEvent_, "v@:@@");
		class_addMethod($SBAppSwitcherController, @selector(icon:touchEnded:), (IMP)&SBASC_icon_touchEnded_, "v@:@c");
		
		[MCListener sharedInstance];
		[MCListenerQuitAll sharedInstance];
	}
    [pool release];
}
