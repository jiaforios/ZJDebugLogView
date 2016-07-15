实现方法：重定向NSLog 输出到本地 实现脱机下同样可以查看输出日志

使用方法：
0. 在全局头文件中（.pch 文件） 中重新宏定义 NSLog


#define NSLog(format, ...) do {   \
   (NSLog)((format), ##__VA_ARGS__);  \
   dispatch_async(dispatch_get_main_queue(), ^{  \
   [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGNOTIFICATION" object:nil]; \
   });\
} while (0)




1.在 main.m 文件中#import "ZJLogManger.h"并实现重定向方法 [ZJLogManger shareManger];


2. 在需要打来调试的文件内 #import "ZJLogTextView.h"


3.  + (void) addDebugView 添加调试框


4.  - (void) showDebugView 显示调试框


5.  - (void) dismissDebugView 隐藏调试框




注意事项：重定向之后，如果连接Xcode 或者模拟器调试将看不到常规输出日志，可以在 ZJLogManger 中将        self.XcodeOutput = self.SimulatorOutput = YES 就可正常显示但是不会继续重定向




猜想优化措施：
当前实现是实时通知NSLog 事件， 这种方式经常读取本地文件，cpu 暂用率高，设法在nslog内容写入文件之前就能拿到值 并输出