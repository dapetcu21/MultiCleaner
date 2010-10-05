//
//  MCListener.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>

@interface MCListener : NSObject<LAListener,UIAlertViewDelegate>  {
	BOOL menuDown;
	UIAlertView * alert;
}
@property (assign,nonatomic) BOOL menuDown;


-(void)activationConfirmed;
+(MCListener*) sharedInstance;

@end
