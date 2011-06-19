//
//  MCListenerOpenEdit.h
//  MultiCleaner
//
//  Created by Marius Petcu on 9/26/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>

@interface MCListenerOpenEdit : NSObject<LAListener> {
	BOOL inUse;
}
+(MCListenerOpenEdit*) sharedInstance;
@end
