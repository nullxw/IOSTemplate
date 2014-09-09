//
//  PSAccount.m
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "PSAccount.h"

@implementation PSAccount

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super initWithDictionary:otherDictionary];
    if (self) {
        self.ID = [otherDictionary stringForKey:@"ID"];
        self.name = [otherDictionary stringForKey:@"name"];
        self.phone  = [otherDictionary stringForKey:@"phone"];
        self.email = [otherDictionary stringForKey:@"email"];
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.ID              = [aDecoder decodeObjectForKey:@"ID"];
        self.name            = [aDecoder decodeObjectForKey:@"name"];
        self.phone           = [aDecoder decodeObjectForKey:@"phone"];
        self.email           = [aDecoder decodeObjectForKey:@"email"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_ID                                     forKey:@"ID"];
    [aCoder encodeObject:_name                                   forKey:@"name"];
    [aCoder encodeObject:_phone                                  forKey:@"phone"];
    [aCoder encodeObject:_email                                  forKey:@"email"];
}

@end
