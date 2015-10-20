//
//  XSGroup.m
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "XSGroup.h"

@implementation XSGroup

- (NSMutableArray *)personGroup{
    if (!_personGroup) {
        _personGroup = [NSMutableArray array];
    }
    return _personGroup;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_personGroup forKey:@"personGroup"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _personGroup = [aDecoder decodeObjectForKey:@"personGroup"];
    }
    return self;
}

@end
