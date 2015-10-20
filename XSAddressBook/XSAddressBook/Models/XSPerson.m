//
//  XSPerson.m
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "XSPerson.h"

@implementation XSPerson

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_tel forKey:@"tel"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _tel = [aDecoder decodeObjectForKey:@"tel"];
    }
    return self;
}

@end
