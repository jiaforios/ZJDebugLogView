//
//  ViewController.m
//  ZJDebugLogView
//
//  Created by foscom on 16/7/14.
//  Copyright © 2016年 zengjia. All rights reserved.
//

#import "ViewController.h"
#import "ZJLogTextView.h"
@interface ViewController ()
@property(nonatomic,strong)ZJLogTextView *manger;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   _manger =  [ZJLogTextView addDebugView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 450, 100, 50);
    [btn setTitle:@"显示调试框" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(showLogView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
}


- (void)showLogView:(UIButton *)sender
{
    if (_manger.hidden) {
        [sender setTitle:@"关闭调试框" forState:UIControlStateNormal];

        [_manger showDebugView];
        
    }else
    {
        [sender setTitle:@"显示调试框" forState:UIControlStateNormal];

        [_manger dismissDebugView];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"这是一条测试信息");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
