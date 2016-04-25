//
//  XYDataViewController.m
//  XYDatabaseDemo
//
//  Created by 夏雁博 on 16/4/25.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import "XYDataViewController.h"
#import "XYDBManager.h"
#import "XYDataModel.h"
#import "XYDataCell.h"
#import "XYUpdateController.h"
#import "XYSelectController.h"

@interface XYDataViewController ()<UISearchResultsUpdating>

@property(nonatomic, copy)NSMutableArray<XYDataModel *> *dataArray;
@property(nonatomic, strong) XYDBManager *dbManger;

@property(nonatomic, strong) UISearchController *searchCtl;
@property(nonatomic, strong) XYSelectController *searchResultVC;

@end

@implementation XYDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"addData" style:UIBarButtonItemStylePlain target:self action:@selector(addData)];
    self.navigationItem.rightBarButtonItem = addBtnItem;
    
    XYSelectController *searchResultVC = [[XYSelectController alloc] initWithStyle:UITableViewStylePlain];
    self.searchResultVC = searchResultVC;
    
    UISearchController *searchCtl = [[UISearchController alloc] initWithSearchResultsController:searchResultVC];
    self.searchCtl = searchCtl;
    
    self.searchCtl.searchResultsUpdater = self;
    
    self.tableView.tableHeaderView = searchCtl.searchBar;
}

-(void)addData{
    XYDataModel *lastData = self.dataArray.lastObject;
    
    NSMutableArray<XYDataModel *> *dataArray = [NSMutableArray arrayWithCapacity:100];
    
    
    for (int i = 0; i < 10; ++i) {
        
        NSString *tableName = @"t_test";
        NSDictionary *record = @{
                                 @"detail":[NSString stringWithFormat:@"TEXT-%zd", lastData.dataID + i],
                                 @"num":[NSNumber numberWithInteger:arc4random_uniform(100)],
                                 @"real":[NSNumber numberWithFloat:arc4random_uniform(800)/10.0 + 20.0]
                                 };
        
        [self.dbManger insertRecordInTable:tableName record:record error:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        XYDataModel *data = [[XYDataModel alloc] init];
        data.dataID = lastData.dataID + i + 1;
        data.detail = [record objectForKey:@"detail"];
        data.num = [[record objectForKey:@"num"] integerValue];
        data.real = [[record objectForKey:@"real"] floatValue];
        
        [dataArray addObject:data];
    }
    [self.dataArray addObjectsFromArray:dataArray];
    [self.tableView reloadData];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self.dbManger closeSql];
}


#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = @"dataCell";
    
    XYDataCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (nil == cell) {
        cell = [[XYDataCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    XYDataModel *data = self.dataArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"data-%zd", data.dataID];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"TEXT = %@, INTEGER = %zd, REAL = %.2f",data.detail, data.num, data.real];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XYDataModel *data = self.dataArray[indexPath.row];
        
        NSString *tableName = @"t_test";
        NSArray *requirements = [NSArray arrayWithObject:[NSString stringWithFormat:@"id = %zd", data.dataID]];
        [self.dbManger deleteRecordFromtable:tableName requirements:requirements error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        [self.dataArray removeObject:data];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XYUpdateController *vc = [[XYUpdateController alloc] init];
    [vc makeUptateDataBlock:^(NSString *detail, NSInteger num, float real) {
        XYDataModel *data = self.dataArray[indexPath.row];
        data.detail = detail;
        data.num = num;
        data.real = real;
        
        NSArray *targets = @[
                             [NSString stringWithFormat:@"detail = '%@'", detail],
                             [NSString stringWithFormat:@"num = %zd", num],
                             [NSString stringWithFormat:@"real = %.2f", real]
                             ];
        NSArray *requirements = @[[NSString stringWithFormat:@"id = %zd", data.dataID]];
        [self.dbManger updataTable:@"t_test" targets:targets requirements:requirements error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSArray *requirements = @[[NSString stringWithFormat:@"detail LIKE '%@'",searchController.searchBar.text]];
    NSArray *resultArray = [self.dbManger selectDataFromTable:@"t_test" requirements:requirements error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    NSMutableArray *resultDatas = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *resultDic = obj;
        XYDataModel *data = [[XYDataModel alloc] init];
        data.dataID = [[resultDic objectForKey:@"id"] integerValue];
        data.detail = [resultDic objectForKey:@"detail"];
        data.num = [[resultDic objectForKey:@"num"] integerValue];
        data.real = [[resultDic objectForKey:@"real"] floatValue];
        [resultDatas addObject:data];
    }];
    self.searchResultVC.searchArr = resultDatas;
    [self.searchResultVC.tableView reloadData];
}

#pragma mark - 懒加载
-(NSMutableArray<XYDataModel *> *)dataArray{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
        NSString *dataPath = [NSHomeDirectory() stringByAppendingPathComponent:@"data.sqlite"];
        self.dbManger = [XYDBManager sharedManager];
        BOOL openRec = [self.dbManger openSqlWithFilePath:dataPath error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        if (openRec) {
            NSString *tableName = @"t_test";
            NSString *primaryKey = @"id";
            NSDictionary *items = @{
                                    @"detail":kTableItemTypeTextNotNull,
                                    @"num":kTableItemTypeIntegerNotNull,
                                    @"real":kTableItemTypeRealNotNull
                                    };
            BOOL creatRec = [self.dbManger creatTable:tableName WithPrimaryKey:primaryKey isAutoIncrement:YES andItems:items error:^(NSError *error) {
                NSLog(@"%@", error);
            }];
            if (creatRec) {
                NSArray *dataArr = [self.dbManger getAllRecordFromTable:@"t_test" error:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
                for (NSDictionary *dataDic in dataArr) {
                    XYDataModel *dataModel = [[XYDataModel alloc]init];
                    dataModel.dataID = [[dataDic objectForKey:primaryKey] integerValue];
                    dataModel.detail = [dataDic objectForKey:@"detail"];
                    dataModel.num = [[dataDic objectForKey:@"num"] integerValue];
                    dataModel.real = [[dataDic objectForKey:@"real"] floatValue];
                    [_dataArray addObject:dataModel];
                }
            }
        }
    }
    return _dataArray;
}
@end
