//
//  MCImageView.m
//  MultiCleaner
//
//  Created by Marius Petcu on 11/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "MCImageView.h"


@implementation MCImageView

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self removeFromSuperview];
}

@end
