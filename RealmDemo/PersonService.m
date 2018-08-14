//
//  PersonService.m
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "PersonService.h"
#import "Person.h"

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
- (RLMResults *)read{
    RLMResults<Person *> *tanDogs = [Person objectsWhere:@"name BEGINSWITH 'h'"];
    NSLog(@"count:%zd",tanDogs.count);
    return tanDogs;
}

- (void)update:(RLMResults *)result{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (int i  = 0; i < result.count; i++) {
            Person *person = [result objectAtIndex:i];
            person.name = @"result";
        }
    }];   
}

-(void)updateTest{
    PersonService *db = [[PersonService alloc] init];
    [db insert];
    RLMResults *resluts =  [db read];
    NSDate *beginDate = [NSDate date];
    for (int i  = 0; i < 10 ;i++) {
        [db update:resluts];
    }
    NSDate *enddate = [NSDate date];
    CGFloat timeInterval = [enddate timeIntervalSinceDate:beginDate]/10;
    
    NSLog(@"%f",timeInterval);
}



@end
