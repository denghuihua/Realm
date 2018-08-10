//
//  Book.h
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/8.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

@interface Book : RLMObject

@property NSString *title;
@property NSNumber<RLMFloat> *price; 
@property NSInteger bookId;
@end
