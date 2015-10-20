//
//  XSGroup.h
//  XSAddressBook
//
//  Created by tarena13 on 15/9/26.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XSGroup : NSObject<NSCoding>

@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) NSMutableArray *personGroup;

@end
