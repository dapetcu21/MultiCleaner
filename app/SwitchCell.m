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
		if (reverse)
			arg=!arg;
		[inv setArgument:&arg atIndex:2];
		[inv invoke];
	}
}

-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		if (style!=UITableViewCellStyleDefault)
		{
			[self release];
			return nil;
		}
        Switch=[[UISwitch alloc] init];
		[Switch addTarget:self action:@selector(callback:) forControlEvents:UIControlEventValueChanged];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		[self.contentView addSubview:Switch];
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
	reverse = NO;
}

-(void)setTarget:(id)_target andPropertySetter:(SEL)sel
{
	settertarget = _target;
	setter = sel;
	reverse = NO;
}

-(void)setTarget:(id)_target andReversePropertySetter:(SEL)sel
{
	[self setTarget:_target andPropertySetter:sel];
	reverse = YES;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	float leftBorder = 10;
	float rightBorder = 5;
	CGRect cb = self.contentView.bounds;
	Switch.frame=CGRectMake(cb.origin.x+cb.size.width-Switch.frame.size.width-leftBorder,
						  (int)(cb.origin.y+(cb.size.height-Switch.frame.size.height)/2),
						  Switch.frame.size.width,
						  Switch.frame.size.height);
	self.textLabel.numberOfLines = 0;
	CGRect textFrame = self.textLabel.frame;
	textFrame.size.width = Switch.frame.origin.x-textFrame.origin.x-rightBorder;
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

+(CGFloat)additionalCellHeightForText:(NSString*)text
{
	static CGFloat width = 0;
	static CGFloat height = 0;
	static UIFont * font;
	
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	BOOL landscape = ((orient == UIInterfaceOrientationLandscapeLeft) || (orient == UIInterfaceOrientationLandscapeRight));
	CGRect r = [[UIApplication sharedApplication] keyWindow].bounds;
	
	width = (landscape?r.size.height:r.size.width) - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?192:122);
	if (!font)
	{
		font = [UIFont boldSystemFontOfSize:17.0f];
		[font retain];
	}
	height = [@"A" sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX)].height;
	return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX)].height-height;
}

@end
