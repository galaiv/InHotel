//
//  NSDictionary+NoNulls.m
//  LineSnob
//
//  Created by Adarsh on 20/02/10.
//  Copyright 2010 Mobomo. All rights reserved.
//

#import "NSDictionary+NoNulls.h"
#import "NSArray+NoNulls.h"


@implementation NSDictionary (NoNulls)


- (NSDictionary *)valueOmittingNullValues {
	
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    for (id key in [self allKeys]) {
        id obj = [self objectForKey:key];
        if (obj != [NSNull null]) {
            if([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
                [newDict setObject:[obj valueOmittingNullValues] forKey:key];
            }
            else {
                [newDict setObject:obj forKey:key];
            }
        }
    }
    return newDict;
}



@end
