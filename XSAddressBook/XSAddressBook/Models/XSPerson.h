//
//  XSPerson.h
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XSPerson : NSObject<NSCoding>

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *tel;

@end
