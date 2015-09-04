//
//  NSArray+NoNulls.h
//  LineSnob
//
//  Created by Adarsh on 20/02/10.
//  Copyright 2010 Mobomo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (NoNulls) 


- (NSArray *)valueOmittingNullValues;

@end
