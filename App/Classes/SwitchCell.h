//
//  SwitchCell.h
//  iController
//
//  Created by Marius Petcu on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SwitchCell : UITableViewCell {
	UISwitch * Switch;
	SEL selector,setter;
	id target,settertarget;
}

-(BOOL)isOn;
-(void)setOn:(BOOL)value;
-(void)setTarget:(id)target andSelector:(SEL)sel;
-(void)setTarget:(id)target andPropertySetter:(SEL)sel;
+(CGFloat)additionalCellHeightForText:(NSString*)text;

@property(nonatomic,getter=isOn) BOOL on;
@end
