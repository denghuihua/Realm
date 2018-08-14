//
//  PersonService.m
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "PersonService.h"
#import "Person.h"
#import <Realm/Realm.h>

//Person table
@implementation PersonService

- (void)insert{
    RLMRealm *realm = [RLMRealm defaultRealm];
//    for (int i  = 0; i < 10; i++) {
        [realm transactionWithBlock:^{
            for ( int i = 0; i < 10000; i ++) {
                Person *person = [[Person alloc] initWithValue:@[@"huihuaDeng",@10,@[@"dog",@10],[NSDate date]]];
                [realm addObject:person];
//                Person *person = [[Person alloc] init];
//                person.date = [NSDate date];
//                [realm addObject:person];
            } 
        }];   
//    }
}

- (void)perInsert{
    RLMRealm *realm = [RLMRealm defaultRealm];
    //    for (int i  = 0; i < 10; i++) {
     for ( int i = 0; i < 10000; i ++) {
    [realm transactionWithBlock:^{
       
            Person *person = [[Person alloc] initWithValue:@[@"huihuaDeng",@10,@[@"dog",@10],[NSDate date]]];
            [realm addObject:person];
            //                Person *person = [[Person alloc] init];
            //                person.date = [NSDate date];
            //                [realm addObject:person];
       
    }];   
    //    }
          } 
}

//realm 不能够获取前多少前数据  http://www.hangge.com/blog/cache/detail_891.html
- (void)read{
    RLMResults<Person *> *tanDogs = [Person objectsWhere:@"name BEGINSWITH 'h'"];
    NSLog(@"count:%zd",tanDogs.count);
}

//- (void)update:(RLMResults *)result{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    //    for (int i  = 0; i < 10; i++) {
//    
//        [realm transactionWithBlock:^{
//        
//          [result ]
//              person.name = @"xiaoming"
//               
//            
//        }];   
//}



@end
