//
//  Person.h
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>
#import "Dog.h"

@interface Person : RLMObject
@property NSString *name;
@property NSInteger age;
@property Dog *dog;
@property NSDate *date;
@end
