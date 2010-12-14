//
//  TableCellSwitch.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCell.h"

@interface TableCellSwitch : TableCell {
	BOOL on;
	NSMutableArray * invocations;
}
@property(nonatomic,assign,getter=isOn) BOOL on;

-(void)addTarget:(id)target andSelector:(SEL)selector;
-(void)addTarget:(id)target andBOOLPropertySetter:(SEL)selector;
-(void)addTarget:(id)target andReverseBOOLPropertySetter:(SEL)selector;
-(void)clearAllTargets;
@end
