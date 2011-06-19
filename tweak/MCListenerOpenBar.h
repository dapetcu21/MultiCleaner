//
//  MCListenerOpenBar.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>

@interface MCListenerOpenBar : NSObject<LAListener> {
	BOOL inUse;
}
+(MCListenerOpenBar*) sharedInstance;
@end
