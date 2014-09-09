//
//  PSPerson.m
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "PSPerson.h"

@implementation PSPerson

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super initWithDictionary:otherDictionary];
    if (self) {
        self.ID = [otherDictionary stringForKey:@"ID"];
        self.name = [otherDictionary stringForKey:@"name"];
        self.age = [otherDictionary stringForKey:@"age"];
        self.phone  = [otherDictionary stringForKey:@"phone"];
        self.email = [otherDictionary stringForKey:@"email"];
        self.distance = [otherDictionary stringForKey:@"distance"];
        self.info = [otherDictionary stringForKey:@"info"];
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
        self.age             = [aDecoder decodeObjectForKey:@"age"];
        self.phone           = [aDecoder decodeObjectForKey:@"phone"];
        self.email           = [aDecoder decodeObjectForKey:@"email"];
        self.distance        = [aDecoder decodeObjectForKey:@"distance"];
        self.info            = [aDecoder decodeObjectForKey:@"info"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_ID                                     forKey:@"ID"];
    [aCoder encodeObject:_name                                   forKey:@"name"];
    [aCoder encodeObject:_age                                    forKey:@"age"];
    [aCoder encodeObject:_phone                                  forKey:@"phone"];
    [aCoder encodeObject:_email                                  forKey:@"email"];
    [aCoder encodeObject:_distance                               forKey:@"distance"];
    [aCoder encodeObject:_info                                   forKey:@"info"];
}


@end
