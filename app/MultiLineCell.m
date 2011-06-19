//
//  MultiLineCell.m
//  App
//
//  Created by Marius Petcu on 10/27/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MultiLineCell.h"


@implementation MultiLineCell

- (id)initWithStyle:(UITableViewCellStyle)sstyle reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:sstyle reuseIdentifier:reuseIdentifier])) {
		style = sstyle;
    }
    return self;
}

#define border 5.0f

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (style==UITableViewCellStyleSubtitle)
		return;
	if (style==UITableViewCellStyleValue2)
		return;
	if (!(self.detailTextLabel.text))
		return;
	self.textLabel.numberOfLines = 0;
	self.detailTextLabel.numberOfLines = 0;
	CGRect labelFrame = self.textLabel.frame;
	CGRect detailFrame = self.detailTextLabel.frame;
	if (style==UITableViewCellStyleValue1)
	{
		const static float detail=0.25;
		CGFloat totalwidth=detailFrame.origin.x+detailFrame.size.width-labelFrame.origin.x;
		CGFloat detailWidth = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font].width;
		if (detailWidth>detail*totalwidth)
			detailWidth=detail*totalwidth;
		CGFloat constrained = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(totalwidth-detailWidth, FLT_MAX)].width;
		//NSLog(@"defaultfonts: label:%@ %f detail:%@ %f",self.textLabel.font.fontName,self.textLabel.font.pointSize,self.detailTextLabel.font.fontName,self.detailTextLabel.font.pointSize);
		//NSLog(@"%f %f %f",labelFrame.size.width,detailFrame.size.width,totalwidth);
		labelFrame.size.width=constrained;
		detailFrame.origin.x=labelFrame.origin.x+constrained;
		detailFrame.size.width=totalwidth-constrained;
		labelFrame.origin.y = border;
		labelFrame.size.height = self.bounds.size.height - 2*border;
		detailFrame.origin.y = border;
		detailFrame.size.height = self.bounds.size.height - 2*border;
	}
	self.textLabel.frame = labelFrame;
	self.detailTextLabel.frame = detailFrame;
}

-(CGFloat)additionalCellHeight
{
	return [MultiLineCell additionalCellHeightForText:self.textLabel.text detailText:self.detailTextLabel.text andStyle:style];
}

+(CGFloat)additionalCellHeightForText:(NSString*)text detailText:(NSString*)detailText andStyle:(UITableViewCellStyle)style
{
	static CGFloat totalwidth=260.0f;
	static UIFont * font = nil;	
	static UIFont * detailFont = nil;
	static CGFloat defaultHeight = 0.0f;
	const static float detail=0.25;
	if (!font)
	{
		font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
		detailFont = [UIFont fontWithName:@"Helvetica" size:17.0f];
		defaultHeight = [@"A" sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)].height;
		CGFloat defaultDetailHeight = [@"A" sizeWithFont:detailFont constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)].height;
		if (defaultDetailHeight>defaultHeight)
			defaultHeight=defaultDetailHeight;
	}
	CGFloat height;
	if ((style==UITableViewCellStyleValue1)&&(detailText))
	{
		CGFloat detailWidth = [detailText sizeWithFont:detailFont].width;
		if (detailWidth>detail*totalwidth)
			detailWidth=detail*totalwidth;
		CGFloat constrained = [text sizeWithFont:font constrainedToSize:CGSizeMake(totalwidth-detailWidth, FLT_MAX)].width;
		height = [text sizeWithFont:font constrainedToSize:CGSizeMake(constrained,FLT_MAX)].height;
		CGFloat detailheight = [detailText sizeWithFont:detailFont constrainedToSize:CGSizeMake(totalwidth-constrained,FLT_MAX)].height;
		if (detailheight>height)
			height=detailheight;
		return height-defaultHeight;
	}
	return [text sizeWithFont:font constrainedToSize:CGSizeMake(totalwidth, FLT_MAX)].height - defaultHeight;
	}

- (void)dealloc {
    [super dealloc];
}


@end
