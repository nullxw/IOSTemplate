//
//  SFContactCenter.h
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
#import <MessageUI/MessageUI.h>

typedef enum {
    SFContactMethodPhone,
    SFContactMethodSMS,
    SFContactMethodEmail,
    SFContactMethodFaceTime
} SFContactMethod;

@interface SFContactCenter : SFObject
{
    UIWebView            *_phoneCallWebView;
    NSMutableArray       *_records;                // 拨号记录
    BOOL                  _saveRecords;            // 是否存储记录
    NSMutableArray       *_tempRecipients;         // 接收者临时变量
}

+ (instancetype)defaultCenter;

+ (BOOL)canCall;
// 会自动检测是否具有打电话功能
- (void)call:(NSString *)recipient;  // 号码不足三位时不拨出

+ (BOOL)canFacetime;
// 会自动检测是否具有Facetime功能
- (void)facetime:(NSString *)recipient; // 号码不足三位时不拨出

+ (BOOL)canSendMessage;
// 会自动检测是否具有发短信功能
- (void)message:(NSArray *)recipients content:(NSString *)content viewController:(UIViewController *)controller;

+ (BOOL)canSendMail;
// 会自动检测是否具有发邮件功能
- (void)mail:(NSArray *)recipients content:(NSString *)content viewController:(UIViewController *)controller;

@end
