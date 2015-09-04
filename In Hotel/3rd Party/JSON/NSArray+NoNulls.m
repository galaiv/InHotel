//
//  NSArray+NoNulls.m
//  LineSnob
//
//  Created by Adarsh on 20/02/10.
//  Copyright 2010 Mobomo. All rights reserved.
//

#import "NSArray+NoNulls.h"
#import "NSDictionary+NoNulls.h"

@implementation NSArray (NoNulls)

- (NSArray *)valueOmittingNullValues {
	
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        if (obj != [NSNull null]) {
            if([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                [newArray addObject:[obj valueOmittingNullValues] ];
            }
            else {
                [newArray addObject:obj ];
            }
        }
    }
    return newArray;
}

@end
