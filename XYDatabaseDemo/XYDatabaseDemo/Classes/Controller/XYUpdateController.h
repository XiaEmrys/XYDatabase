//
//  XYUpdateController.h
//  XYDatabaseDemo
//
//  Created by 夏雁博 on 16/4/25.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^updateDataBlock)(NSString *detail, NSInteger num, float real);

@interface XYUpdateController : UIViewController

@property(nonatomic, strong) UITextField *detailField;
@property(nonatomic, strong) UITextField *numField;
@property(nonatomic, strong) UITextField *realField;

@property(nonatomic, strong) updateDataBlock block;

-(void)makeUptateDataBlock:(updateDataBlock)block;

@end
