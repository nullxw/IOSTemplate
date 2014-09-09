//
//  SFContactCenter.m
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFContactCenter.h"
#import "SFFileManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface SFContactCenter ()<UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    CTCallCenter *_center;
}
@end

@implementation SFContactCenter

static SFContactCenter *defaultCenterInstance = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _saveRecords = YES;
        
        _tempRecipients = [[NSMutableArray alloc] init];
        _phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        // 监听拨号状态
        _center = [[CTCallCenter alloc] init];
        
        __block SFContactCenter * __weak weakSelf = self;
        
        _center.callEventHandler = ^(CTCall *call) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([call.callState isEqualToString:CTCallStateDialing]) {
                    [weakSelf clearTempCache];
                }
            });
        };
    }
    return self;
}

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultCenterInstance = [[self alloc] init];
        });
    }
    return defaultCenterInstance;
}

/*******
 数据管理
 *******/

// 初始化临时变量
- (void)clearTempCache
{
    [_tempRecipients removeAllObjects];
}

/*******
 电话功能
 *******/
// 是否可打电话
+ (BOOL)canCall
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://123456"]];
}

// 打电话给指定号码
- (void)call:(NSString *)recipient
{
    if (recipient.length > 2) {
        
        if ([SFContactCenter canCall]) {
            [_tempRecipients removeAllObjects];
            [_tempRecipients addObject:recipient];
            
            NSString *urlString = [NSString stringWithFormat:@"tel:%@", recipient];
            [_phoneCallWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"设备不支持打电话功能", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
}

/************
 FaceTime功能
 ************/
// 是否可Facetime
+ (BOOL)canFacetime
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"facetime://123456"]];
}

// FaceTime指定号码或邮箱
- (void)facetime:(NSString *)recipient
{
    if (recipient.length > 2) {
        
        if ([SFContactCenter canFacetime]) {
            [_tempRecipients removeAllObjects];
            [_tempRecipients addObject:recipient];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:recipient message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:@"FaceTime", nil];
            [alert show];

        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"设备FaceTime功能不可用", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self faceTimeAction];
    }
}

- (void)faceTimeAction
{
    NSString *urlString = [NSString stringWithFormat:@"facetime://%@", _tempRecipients.lastObject];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

/*******
 短信功能
 *******/
// 是否可发送短信
+ (BOOL)canSendMessage
{
    Class messageClass = NSClassFromString(@"MFMessageComposeViewController");
    if (messageClass) { // 设备有短信功能
        return [messageClass canSendText];
    }
    return NO;
}

// 发短信给指定号码列表
- (void)message:(NSArray *)recipients content:(NSString *)content viewController:(UIViewController *)controller
{
    if ([SFContactCenter canSendMessage]) {
        [self showMessageComposeWithRecipients:recipients body:content viewController:controller];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"设备短信功能不可用", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
        [alert show];
        
    }
    
}

// 弹出系统短信界面
- (void)showMessageComposeWithRecipients:(NSArray *)recipients body:(NSString *)content viewController:(UIViewController *)controller
{
    _tempRecipients.array = recipients;
    
    MFMessageComposeViewController *messageComposeView = [[MFMessageComposeViewController alloc] init];
    messageComposeView.messageComposeDelegate = self;
    messageComposeView.recipients = recipients;
    messageComposeView.body = content;
    [controller presentViewController:messageComposeView animated:YES completion:nil];

}

/**************************************
 MFMessageComposeViewControllerDelegate
 **************************************/
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultSent:
			break;
            
        case MessageComposeResultCancelled:
			break;
            
		case MessageComposeResultFailed:
			break;
            
		default:
			break;
	}
    
    [self clearTempCache];
    [controller dismissViewControllerAnimated:YES completion:nil];

}

/*******
 邮件功能
 *******/
// 是否可发送邮件
+ (BOOL)canSendMail
{
    Class mailClass = NSClassFromString(@"MFMailComposeViewController");
    if (mailClass) { // 设备有邮件功能
        return [mailClass canSendMail];
    }
    return NO;
}

// 发邮件给指定邮箱列表
- (void)mail:(NSArray *)recipients content:(NSString *)content viewController:(UIViewController *)controller
{
    if ([SFContactCenter canSendMail]) {
        [self showMailComposeWithToRecipients:recipients messageBody:content viewController:controller];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"设备邮件功能不可用", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
        [alert show];
    }
    
}

// 弹出系统邮件界面
- (void)showMailComposeWithToRecipients:(NSArray *)recipients messageBody:(NSString *)content viewController:(UIViewController *)controller
{
    
    _tempRecipients.array = recipients;
    
    MFMailComposeViewController *mailComposeView = [[MFMailComposeViewController alloc] init];
    mailComposeView.mailComposeDelegate = self;
    [mailComposeView setToRecipients:recipients];
    [mailComposeView setMessageBody:content isHTML:NO];
    [controller presentViewController:mailComposeView animated:YES completion:nil];
    
}

/***********************************
 MFMailComposeViewControllerDelegate
 ***********************************/
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result) {
		case MFMailComposeResultSent:
			break;
            
        case MFMailComposeResultCancelled:
			break;
            
		case MFMailComposeResultSaved:
			break;
            
		case MFMailComposeResultFailed:
			break;
            
		default:
			break;
	}
    
    [self clearTempCache];
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}

@end
