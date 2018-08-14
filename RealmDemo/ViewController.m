//
//  ViewController.m
//  RealmDemo
//
//  Created by huihuadeng on 2018/8/7.
//  Copyright © 2018年 huihuadeng. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Dog.h"
#import "Book.h"
#import "PersonService.h"
//realm
/*单次连续写入10000条 23.8 s*/
/*事物单次写入10000条 451 ms*/
/*单次连续读取10000条 6.62ms*/
/*单次单次更新10000条 935 ms*/

//coreData
/*单次连续写入10000条 33.2 s*/
/*事物单次写入10000条 202 ms*/
/*单次连续读取10000条 18.1ms*/
/*单次单次更新10000条 339 ms*/

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) RLMResults  *dataArray; //侵入性太高，没办法把RLM对象从项目中分离出来
@property(nonatomic, strong) RLMNotificationToken *notification;
@end


/*to do  array结果集 对象与上层之间的解耦   与coreData区别  性能？  并发多线程之间相互读写问题*/
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //三个按钮  新增 删除 更新 查就是table显示的数据了
    
    [[NSFileManager defaultManager] removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    NSLog(@"fileURL:%@",[RLMRealmConfiguration defaultConfiguration].fileURL);
    
    NSLog(@"并发开始"); //并发 1000 * 1000 条时间 20s
    RLMRealm *realm = [RLMRealm defaultRealm];
    
//    [self multiThreadWrite];

   
}

- (void)multiThreadForOneDataCreate{
    //多个线程同时使用同一个 主键创建 一条数据，crash   *** Terminating app due to uncaught exception 'RLMException', reason: 'Attempting to create an object of type 'Book' with an existing primary key value '2'.'  使用createOrUpdateInRealm 可避开此问题
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool{
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            for (NSInteger idx1 = 0; idx1 < 10; idx1++) {
                [realm beginWriteTransaction];
                
                for (NSInteger idx2 = 0; idx2 < 1000; idx2++) {
                    //'Attempting to create an object of type 'Book' with an existing primary key value '2'.'
                    [Book createInRealm:realm withValue:@{@"title":@"huahua",@"price":@18,@"bookId":@2}];
                }
                [realm commitWriteTransaction];
                
                //                NSLog(@"%@",[[Person allObjects]sortedResultsUsingKeyPath:@"date" ascending:YES]);
                
            }
        }
        NSLog(@"本任务结束");
    });
}

- (void)multiThreadForOneDataUpate{
    //多个线程同时使用同一个 主键更新 一条数据，没问题 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool{
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            for (NSInteger idx1 = 0; idx1 < 10; idx1++) {
                [realm beginWriteTransaction];
                
                for (NSInteger idx2 = 0; idx2 < 1000; idx2++) {
                    
                    [Book createOrUpdateInRealm:realm withValue:@{@"title":@"pengpeng",@"price":@19,@"bookId":@2}];
                }
                [realm commitWriteTransaction];
                
                //                NSLog(@"%@",[[Person allObjects]sortedResultsUsingKeyPath:@"date" ascending:YES]);
                
            }
        }
        NSLog(@"本任务结束");
    });
}

- (void)multiThreadWrite{
    //并发写入
    NSLog(@"并发开始"); //并发 1000 * 1000 条时间 20s
    for (NSInteger idx1 = 0; idx1 < 100; idx1++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"本任务开始:%zd==%@",idx1,[NSThread currentThread]);
            @autoreleasepool{
                RLMRealm *realm = [RLMRealm defaultRealm];
                //Realm 单条线程写入操作是同步以及阻塞进行的
                [realm beginWriteTransaction];
                NSLog(@"transaction写入开始:%zd==%@",idx1,[NSThread currentThread]);
                for (NSInteger idx2 = 0; idx2 < 1000; idx2++) {
                    [Person createInRealm:realm withValue:@{@"name":@"huahua",@"age":@18,@"date":[NSDate date]}];
                }
                NSLog(@"transaction写入结束:%zd==%@",idx1,[NSThread currentThread]);
                [realm commitWriteTransaction];
                //                NSLog(@"%@",[[Person allObjects]sortedResultsUsingKeyPath:@"date" ascending:YES]);
                
            }
            NSLog(@"本任务结束:%zd",idx1);
        });
    }
}


- (void)configTableView{
    //一开始数据库表中内容为空的时候，建立的结果映射没有任何意义，先保证建立数据库
    [RLMRealm defaultRealm];
    self.dataArray = [[Person allObjects] sortedResultsUsingKeyPath:@"date" ascending:YES];
    __weak typeof(self) weakSelf = self;
    self.notification = [weakSelf.dataArray addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable changes, NSError * _Nullable error) {
        if (error) {
            NSLog(@"failed to open realm on background worker:%@",error);
            return;
        }
        
        UITableView *tv = weakSelf.tableView;
        if (!changes) {
            [tv reloadData];
            return;
        }
        
        [tv beginUpdates];
        [tv deleteRowsAtIndexPaths:[changes deletionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv insertRowsAtIndexPaths:[changes insertionsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv reloadRowsAtIndexPaths:[changes modificationsInSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tv endUpdates];
    }];
    
    [self addActionButtons];
    CGRect tableViewFrame = CGRectInset(self.view.frame, 0, 64);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
}

-(void)addActionButtons{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
    CGFloat buttonWidth = 60;
    CGFloat space = (self.view.frame.size.width - buttonWidth *3)/4;
    for (int i  = 0; i <3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        switch (i) {
            case 0:
                {
                    [button setTitle:@"add" forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(insert) forControlEvents:UIControlEventTouchUpInside];
                }
                break;
            case 1:
            {
                [button setTitle:@"update" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
     
            }
                break;
            case 2:
            {
                [button setTitle:@"delete" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
          
            }
                break;
                
            default:
                break;
        }
        button.frame = CGRectMake(space*(i + 1) + i *buttonWidth, 0, buttonWidth, 44); 
        [view addSubview:button];
    }
    
}

#pragma mark - actions

- (void)insert{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for ( int i = 0; i < 10; i ++) {
            Person *person = [[Person alloc] initWithValue:@[@"huihuaDeng",@10,@[@"dog",@10],[NSDate date]]];
            
            [realm addObject:person];
        } 
    }];
}

- (void)update{
   
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [self.dataArray setValue:@20 forKey:@"age"];
    }];
}

- (void)delete{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
}

#pragma mark - tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"realmCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    Person *person = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = person.name; 
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",person.age];
    return cell;
}

 //只有在访问属性时才读取数据 
-(void)queryStudy{
//    数据过滤 支持谓词字符串和谓词对象两种查询方式  谓词过滤见苹果文档   参考链接https://academy.realm.io/posts/nspredicate-cheatsheet/?_ga=2.184242671.815515014.1533522944-1448585560.1520231910     
    RLMResults<Dog *> *tanDogs = [Dog objectsWhere:@"name BEGINSWITH 'h'"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@",@"p"];
    tanDogs = [Dog objectsWithPredicate:pred];
    
// 数据排序  支持属性名 键值 键值属性排序  支持连接查询
    RLMResults<Dog *> *sortedDogs = [[Dog objectsWhere:@"name BEGINSWITH 'p'"] sortedResultsUsingKeyPath:@"name" ascending:NO];
    RLMResults<Person *>*dogOwners = [[Person allObjects] sortedResultsUsingKeyPath:@"dog.age" ascending:NO];

    
    //自动更新查询结果集  使用枚举enumeration不会自动更新
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<Dog *> *dogs = [Dog objectsInRealm:realm where:@"age > 2"];
    NSLog(@"%zd",dogs.count);
    
    [realm transactionWithBlock:^{
        [Dog createInRealm:realm withValue:@[@"blackHair",@7]]; 
    }];
    
    NSLog(@"%zd",dogs.count);
}

- (void)writeStudy{
    //增 删 改 都需要在事物中执行   查不需要
    NSLog(@"write begin");
    //创建对象三种方式
    //属性创建
    Dog *dog1 = [[Dog alloc] init];
    dog1.name = @"huahua";
    dog1.age = 3;
    
    //字典创建
    Dog *dog2 = [[Dog alloc] initWithValue:@{@"name":@"pluto",@"age":@4}];
    
    //数组创建
    //数组中元素的顺序需要和model中property申明的顺序保持一致
    Dog *dog3 = [[Dog alloc] initWithValue:@[@"pluto2",@2]];
    
    NSLog(@"dog1:%@\n dog2:%@\n dog3:%@",dog1,dog2,dog3);
    
    //嵌套对象创建  对应表关系中 一对多
    Person *person1 = [[Person alloc] init];
    person1.name = @"huihuadeng";
    person1.dog = dog1;
    
    //内联数组中的对象仅包含realm 对象
    Person *person2 = [[Person alloc] initWithValue:@[@"jane",@30,dog2]];
    Person *person3 = [[Person alloc] initWithValue:@[@"jane",@60,@[@"buster",@5]]];
    
    //写入数据库
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    //插入  （不同线程的多个写操作会相互阻塞，建议将多个写操作放到一个线程中进行；一个对象写操作之后，其他地方自动更新）
    [realm transactionWithBlock:^{
        [realm addObject:person1];
        [realm addObject:person2];
        [realm addObject:person3];
    }];
    
    //更新   写入更新都需要在事物 中进行
    //属性更新
    [realm transactionWithBlock:^{
        dog3.age = 10;
    }]; 
    
    //键值观察 RLMObject, RLMResult, and RLMArray 都可以 键值观察
    RLMResults<Person *> *persons = [Person allObjects];
    [realm transactionWithBlock:^{
        [[persons firstObject] setValue:@"100" forKeyPath:@"age"];
        [persons setValue:@"Earth" forKeyPath:@"name"];
    }];
    
    //对象含主键 主键如何创建  不含自增长index，如需要，需要手动创建及维护
    //to do <Dog> <Dog *区别> 
    Book *cheeseBook = [[Book alloc] init];
    cheeseBook.title = @"cheese recipes";
    cheeseBook.price = @9000;
    cheeseBook.bookId = 1000;
    
    Book *cheeseBook2 = [[Book alloc] init];
    cheeseBook2.title = @"cheese recipes";
    cheeseBook2.price = @9000;
    cheeseBook2.bookId = 13000;
    
    //更新主键 以下两种更新表的方式，仅适用于 有主键的表
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:cheeseBook];
        [realm addOrUpdateObject:cheeseBook2];
        [Book createOrUpdateInRealm:realm withValue:@{@"bookId":@1000,@"price":@0}];
    }];
    
    //删除对象 删除对象之后，realm仍会持有该对象
    [realm transactionWithBlock:^{
        [realm deleteObject:cheeseBook];
    }];
    NSLog(@"write end");
}


@end
