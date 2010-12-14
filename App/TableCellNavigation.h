//
//  TableCellNavigation.h
//  App
//
//  Created by Marius Petcu on 11/15/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCell.h"

@interface TableCellNavigation : TableCell {
	id target;
	SEL selector;
}

-(void)setTarget:(id)target andSelector:(SEL)selector;

@end
