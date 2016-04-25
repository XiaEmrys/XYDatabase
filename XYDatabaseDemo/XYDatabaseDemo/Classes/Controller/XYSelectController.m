//
//  XYSelectController.m
//  XYDatabaseDemo
//
//  Created by 夏雁博 on 16/4/25.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import "XYSelectController.h"
#import "XYDataCell.h"
#import "XYDataModel.h"

@interface XYSelectController ()

@end

@implementation XYSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = @"searchCell";
    XYDataCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[XYDataCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    XYDataModel *data = self.searchArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"data-%zd", data.dataID];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"TEXT = %@, INTEGER = %zd, REAL = %.2f",data.detail, data.num, data.real];
    
    return cell;
}

#pragma mark - 懒加载
-(NSArray *)searchArr{
    if (nil == _searchArr) {
        _searchArr = [NSArray array];
    }
    return _searchArr;
}
@end
