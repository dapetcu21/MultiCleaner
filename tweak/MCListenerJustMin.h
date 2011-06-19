//
//  MCListenerJustMin.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>

@interface MCListenerJustMin : NSObject<LAListener,UIAlertViewDelegate> {
	BOOL menuDown;
	UIAlertView * alert;
}
@property (assign,nonatomic) BOOL menuDown;


-(void)activationConfirmed;
+(MCListenerJustMin*) sharedInstance;

@end
