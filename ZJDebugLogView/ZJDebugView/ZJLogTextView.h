//
//  ZJLogTextView.h
//  RunTime
//
//  Created by foscom on 16/7/12.
//  Copyright © 2016年 zengjia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJLogTextView : UIView

+ (id) addDebugView;
- (void)showDebugView;
- (void)dismissDebugView;

@end
