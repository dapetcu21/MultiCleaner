//
//  MultiLineCell.h
//  App
//
//  Created by Marius Petcu on 10/27/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MultiLineCell : UITableViewCell {
	UITableViewCellStyle style; 
}

-(CGFloat)additionalCellHeight;
+(CGFloat)additionalCellHeightForText:(NSString*)text detailText:(NSString*)detailText andStyle:(UITableViewCellStyle)style;

@end
