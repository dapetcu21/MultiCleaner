//
//  SwitchCell.m
//  iController
//
//  Created by Marius Petcu on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SwitchCell.h"


@implementation SwitchCell

-(void)callback:(id)sender
{
	if (target)
		[target performSelector:selector withObject:self];
	if (setter)
	{
		NSInvocation * inv = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"v@:c"]];
		[inv setSelector:setter];
		[inv setTarget:settertarget];
		BOOL arg = Switch.on;
		[inv setArgument:&arg atIndex:2];
		[inv invoke];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        Switch=[[UISwitch alloc] init];
		[Switch addTarget:self action:@selector(callback:) forControlEvents:UIControlEventValueChanged];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		[self addSubview:Switch];
    }
    return self;
}

-(BOOL)isOn
{
	return Switch.on;
}

-(void)setOn:(BOOL)value
{
	[Switch setOn:value];
}


-(void)setTarget:(id)_target andSelector:(SEL)sel
{
	target = _target;
	selector = sel;
}

-(void)setTarget:(id)_target andPropertySetter:(SEL)sel
{
	settertarget = _target;
	setter = sel;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	Switch.frame=CGRectMake(self.bounds.origin.x+self.bounds.size.width-Switch.frame.size.width-20,
						  self.bounds.origin.y+(self.bounds.size.height-Switch.frame.size.height)/2,
						  Switch.frame.size.width,
						  Switch.frame.size.height);
	self.textLabel.numberOfLines = 0;
	CGRect textFrame = self.textLabel.frame;
	textFrame.size.width = Switch.frame.origin.x-textFrame.origin.x-5;
	self.textLabel.frame = textFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[Switch release];
    [super dealloc];
}

-(CGFloat)additionalCellHeightForWidth:(CGFloat)width;
{
	UILabel * label = self.textLabel;
	NSString * text = label.text;
	static CGFloat subs = 0;
	if (subs==0)
	{
		UISwitch * sw = [[UISwitch alloc] init];
		subs=sw.bounds.size.width;
		[sw release];
		subs+=30;
	}
	NSLog(@"text: %@ subs:%f",text,subs);
	return [text sizeWithFont:label.font constrainedToSize:CGSizeMake(width-subs, FLT_MAX)].height-
	[@"A" sizeWithFont:label.font constrainedToSize:CGSizeMake(width-subs, FLT_MAX)].height;
}

@end
