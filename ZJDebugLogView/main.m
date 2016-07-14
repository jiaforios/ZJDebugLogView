//
//  main.m
//  ZJDebugLogView
//
//  Created by foscom on 16/7/14.
//  Copyright © 2016年 zengjia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ZJLogManger.h"
int main(int argc, char * argv[]) {
    @autoreleasepool {
        [ZJLogManger shareManger];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
