//
//  ZJLogTextView.m
//  RunTime
//
//  Created by foscom on 16/7/12.
//  Copyright © 2016年 zengjia. All rights reserved.
//

#import "ZJLogTextView.h"
#import "GetLogFile.h"
#import "AppDelegate.h"
#import "XTPopView.h"
#define BUTTON_HIGHT 30
@interface ZJLogTextView ()<UITextViewDelegate,selectIndexPathDelegate>

@property(nonatomic, strong) UIView   *controlView;
@property(nonatomic, strong) UIButton *smallBtn;
@property(nonatomic, strong) UIButton *bigBtn;
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, strong) UITextView *logTextView;
@property(nonatomic, strong) UIButton *lineMarkBtn;
@property(nonatomic, strong) UIStepper *step;
@property(nonatomic, assign) CGFloat currentScale;
@property(nonatomic, strong) GetLogFile *fieGet;
@property(nonatomic, copy)   NSString *logPath;
@property(nonatomic, assign) BOOL bDrag;
@property(nonatomic, assign) CGRect customFrame;
@property(nonatomic,strong) dispatch_queue_t logQueue;
@end

@implementation ZJLogTextView

static ZJLogTextView *manger = nil;

+ (id)addDebugView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[ZJLogTextView alloc] initWithFrame:CGRectMake(50, 20, 320, 400)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow addSubview:manger];
        });
        
        manger.hidden = YES;
    });
    
    return manger;
}


- (void)logNotification
{
    [self getLogFile];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _customFrame = frame;
        _bDrag = NO;
        self.backgroundColor = [UIColor blackColor];
        [self.controlView addSubview:self.cancelBtn];
        [self.controlView addSubview:self.bigBtn];
        [self.controlView addSubview:self.smallBtn];
        [self.controlView addSubview:self.lineMarkBtn];
        [self.controlView addSubview:self.step];
        [self addSubview:self.controlView];
        [self addSubview:self.logTextView];
        
        _currentScale = 1.0;

        _logQueue = dispatch_queue_create("logqueue", DISPATCH_QUEUE_SERIAL);
        UIPinchGestureRecognizer* pinGesture = [[UIPinchGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(scaleTextView:)];
        [self addGestureRecognizer:pinGesture];
        
         _fieGet = [[GetLogFile alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification) name:@"LOGNOTIFICATION" object:nil];
          [_fieGet getLogFileData:^(NSString *logDataStr,NSString *filepath) {
            _logPath = filepath;
              
          }];
        
        
        
    }
    return self;
}



- (void)getLogFile
{
   dispatch_async(_logQueue, ^{
     
     dispatch_async(dispatch_get_main_queue(), ^{
         _logTextView.text = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:_logPath] encoding:NSUTF8StringEncoding];
     });

 });
    
}

- (void)showDebugView
{
    manger.hidden = NO;
    manger.logTextView.text = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:manger.logPath] encoding:NSUTF8StringEncoding];
}

- (void)dismissDebugView
{
    manger.hidden = YES;
    manger.logTextView.text = @"";

}
- (void)scaleTextView:(UIPinchGestureRecognizer *)paramSender
{
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        self.currentScale = paramSender.scale;
    }else if(paramSender.state == UIGestureRecognizerStateBegan && self.currentScale != 0.0f){
        paramSender.scale = self.currentScale;
    }
    if (paramSender.scale !=NAN && paramSender.scale != 0.0) {
        paramSender.view.transform = CGAffineTransformMakeScale(paramSender.scale, paramSender.scale);
    }
    CGFloat scale = paramSender.scale;

    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (UITextView *)logTextView
{
    if (_logTextView == nil) {
        _logTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_controlView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_controlView.frame))];
        _logTextView.textColor = [UIColor whiteColor];
        _logTextView.font = [UIFont systemFontOfSize:10];
        _logTextView.backgroundColor = [UIColor blackColor];
        
    }
//    _logTextView.userInteractionEnabled = NO; // 不能编辑 不能交互
    _logTextView.editable = NO;  // 不能编辑 能交互
    _logTextView.delegate = self;
    _logTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    return _logTextView;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    
    CGPoint currentPoint= [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];
    
    CGFloat offsetx = currentPoint.x - prePoint.x;
    CGFloat offsety = currentPoint.y - prePoint.y;

    self.center = CGPointMake(self.center.x+offsetx, self.center.y+offsety);
    _customFrame = self.frame;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat contenHeight=scrollView.contentSize.height;
    CGFloat refreshOffSet=scrollView.contentOffset.y+CGRectGetHeight(scrollView.frame);
    if(refreshOffSet==contenHeight)
    {
        _bDrag = NO;
    }else
    {
       _bDrag = YES;
    }    
}

- (UIView *)controlView{

    if (_controlView == nil) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), BUTTON_HIGHT)];
    }
    _controlView.backgroundColor = [UIColor lightGrayColor];
    _controlView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    return _controlView;
    
}

- (UIButton *)lineMarkBtn
{
    if (_lineMarkBtn == nil) {
        
        _lineMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lineMarkBtn.frame = CGRectMake(CGRectGetMaxX(_smallBtn.frame)+10, 0, BUTTON_HIGHT, BUTTON_HIGHT);
    }
    [_lineMarkBtn setTitle:@"断位线" forState:UIControlStateNormal];
    _lineMarkBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [_lineMarkBtn addTarget:self action:@selector(lineMarkShow:) forControlEvents:UIControlEventTouchUpInside];
    
    return _lineMarkBtn;
}
- (UIButton *)smallBtn
{
    if (_smallBtn == nil) {
        _smallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _smallBtn.frame = CGRectMake(CGRectGetMaxX(_bigBtn.frame), 0, BUTTON_HIGHT, BUTTON_HIGHT);
    }
    [_smallBtn setImage:[UIImage imageNamed:@"LogImageSource.bundle/small.jpg"] forState:UIControlStateNormal];
    [_smallBtn addTarget:self action:@selector(smallLogViewShow:) forControlEvents:UIControlEventTouchUpInside];

    return _smallBtn;
}

- (UIButton *)bigBtn
{
    if (_bigBtn == nil) {
        _bigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bigBtn.frame = CGRectMake(CGRectGetMaxX(_cancelBtn.frame), 0, BUTTON_HIGHT, BUTTON_HIGHT);
    }
    [_bigBtn setImage:[UIImage imageNamed:@"LogImageSource.bundle/big"] forState:UIControlStateNormal];
    [_bigBtn addTarget:self action:@selector(bigLogViewShow:) forControlEvents:UIControlEventTouchUpInside];

    return _bigBtn;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, 0, BUTTON_HIGHT, BUTTON_HIGHT);
    }
    [_cancelBtn setImage:[UIImage imageNamed:@"LogImageSource.bundle/close.jpg"] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelLogViewShow:) forControlEvents:UIControlEventTouchUpInside];
    
    return _cancelBtn;
}

- (UIStepper *)step
{
    if (_step == nil) {
        _step = [[UIStepper alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lineMarkBtn.frame)+10, 0, 20, BUTTON_HIGHT)];
        
        _step.minimumValue = 5.0f;
        _step.maximumValue = 30.0f;
        _step.value = 10;
    }
    
    [_step addTarget:self action:@selector(changeFont:) forControlEvents:UIControlEventValueChanged];
    
    
    return _step;
}


- (void)changeFont:(UIStepper *)sender
{

    _logTextView.font = [UIFont systemFontOfSize:sender.value];

}

- (void)cancelLogViewShow:(UIButton *)sender
{
    _logTextView.text = @"";
    manger.hidden = YES;
    
}

- (void)bigLogViewShow:(UIButton *)sender
{
    self.frame = _customFrame;
    
}
- (void)smallLogViewShow:(UIButton *)sender
{
    // 最小化时 暂停计时器 降低CPU
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BUTTON_HIGHT *3, BUTTON_HIGHT);
}

- (void)lineMarkShow:(UIButton*)sender
{
    CGPoint point = CGPointMake(sender.center.x,sender.frame.origin.y+BUTTON_HIGHT);
    
    XTPopView *view1 = [[XTPopView alloc] initWithOrigin:point Width:130 Height:40 * 4 Type:XTTypeOfUpCenter Color:[UIColor colorWithRed:0.2737 green:0.2737 blue:0.2737 alpha:1.0]];
    view1.dataArray = @[@"-------------",
                        @"##########",
                        @"************",
                        @"++++++++++"];
    view1.fontSize = 13;
    view1.row_height = 40;
    view1.titleTextColor = [UIColor whiteColor];
    view1.delegate = self;
    [view1 popViewInView:self];
}
- (void)selectIndexPathRow:(NSInteger)index
{
    switch (index) {
        case 0:NSLog(@"--------------mark-------------------------");break;
        case 1:NSLog(@"##############mark####################");break;
        case 2:NSLog(@"*************************mark*******************");break;
        case 3:NSLog(@"++++++++++++++mark+++++++++++++++++++++++++++++++++");break;
    }
}


@end
