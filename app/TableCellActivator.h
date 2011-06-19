//
//  TableCellActivator.h
//  App
//
//  Created by Marius Petcu on 11/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCell.h"

@interface TableCellActivator : TableCell {
	NSString * listenerName;
}

@property(nonatomic,retain) NSString * listenerName;

@end
