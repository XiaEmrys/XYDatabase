//
//  XYUpdateController.m
//  XYDatabaseDemo
//
//  Created by 夏雁博 on 16/4/25.
//  Copyright © 2016年 夏雁博. All rights reserved.
//

#import "XYUpdateController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface XYUpdateController ()

@property(nonatomic, strong) UITextField *detailField;
@property(nonatomic, strong) UITextField *numField;
@property(nonatomic, strong) UITextField *realField;

@end

@implementation XYUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addSubViews];
}

-(void)makeUptateDataBlock:(updateDataBlock)block{
    if (nil != block) {
        self.block = block;
    }
}

-(void)addSubViews{
    [self.view addSubview:self.detailField];
    [self.view addSubview:self.numField];
    [self.view addSubview:self.realField];
    
    [self addLabel:@"detail" yOrigin:kScreenHeight * 0.2];
    [self addLabel:@"num" yOrigin:kScreenHeight * 0.3];
    [self addLabel:@"real" yOrigin:kScreenHeight * 0.4];
    
    CGFloat x = kScreenWidth * 0.3;
    CGFloat y = kScreenHeight * 0.5;
    CGFloat width = kScreenWidth * 0.4;
    CGFloat height = 30;
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitle:@"O  K" forState:UIControlStateNormal];
    [okBtn setBackgroundColor:[UIColor darkGrayColor]];
    
    [self.view addSubview:okBtn];
}

-(void)okBtnClick{
    if (self.block) {
        self.block(self.detailField.text, [self.numField.text integerValue], [self.realField.text floatValue]);
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addLabel:(NSString *)labelName yOrigin:(CGFloat)y{
    CGFloat x = kScreenWidth * 0.1;
    CGFloat width = kScreenWidth *0.2;
    CGFloat height = 25;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    label.text = labelName;
    [self.view addSubview:label];
}

#pragma mark - 懒加载
-(UITextField *)detailField{
    if (nil == _detailField) {
        CGFloat x = kScreenWidth * 0.4;
        CGFloat y = kScreenHeight * 0.2;
        CGFloat width = kScreenWidth * 0.5;
        CGFloat height = 25;
        _detailField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _detailField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _detailField;
}
-(UITextField *)numField{
    if (nil == _numField) {
        CGFloat x = kScreenWidth * 0.4;
        CGFloat y = kScreenHeight * 0.3;
        CGFloat width = kScreenWidth * 0.5;
        CGFloat height = 25;
        _numField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _numField.borderStyle = UITextBorderStyleRoundedRect;
        _numField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _numField;
}
-(UITextField *)realField{
    if (nil == _realField) {
        CGFloat x = kScreenWidth * 0.4;
        CGFloat y = kScreenHeight * 0.4;
        CGFloat width = kScreenWidth * 0.5;
        CGFloat height = 25;
        _realField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _realField.borderStyle = UITextBorderStyleRoundedRect;
        _realField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _realField;
}
@end
