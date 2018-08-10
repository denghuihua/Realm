//
//  Dog.h
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "RLMObject.h"

@interface Dog : RLMObject

@property NSString *name;
@property NSInteger age;

@end

RLM_ARRAY_TYPE(Dog);
