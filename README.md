实现方法：重定向NSLog 输出到本地 实现脱机下同样可以查看输出日志

使用方法：
1.在 main.m 文件中#import "ZJLogManger.h"并实现重定向方法 [ZJLogManger shareManger];


2. 在需要打来调试的文件内 #import "ZJLogTextView.h"


3.  + (void) addDebugView 添加调试框


4.  - (void) showDebugView 显示调试框


5.  - (void) dismissDebugView 隐藏调试框


