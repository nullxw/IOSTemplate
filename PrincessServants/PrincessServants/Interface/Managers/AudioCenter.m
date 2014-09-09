//
//  AudioCenter.m
//  ShadowFiend
//
//  Created by tixa on 14-6-30.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "AudioCenter.h"
#import "SFConfigCenter.h"

@interface AudioCenter ()

@end

@implementation AudioCenter

static AudioCenter *defaultManagerInstance = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateSoundID = 0;
        _messageSoundID = 0;
        _shakeSoundID = 0;
    }
    return self;
}

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultManagerInstance = [[self alloc] init];
        });
    }
    return defaultManagerInstance;
}



#pragma mark - SystemSound

// 播放下拉刷新提示音
- (void)playUpdateSound
{
    if ([[SFConfigCenter defaultCenter] isOpenSound]) {
        if (_updateSoundID == 0) {  // 还未注册系统音
            NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"update_finished" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(filePath), &_updateSoundID);
        }
        AudioServicesPlaySystemSound(_updateSoundID);
    }
    
}

// 播放新消息提示音
- (void)playMessageSound
{
    NSString *key = @"LastPlaySound";
    NSDate *lastPlayDate = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (lastPlayDate && -[lastPlayDate timeIntervalSinceNow] < 5.0) { // 5秒内不重复播放
        return;
    }
    
    BOOL openSound = [[SFConfigCenter defaultCenter] isOpenSound];
    BOOL openVibrate = [[SFConfigCenter defaultCenter] isOpenVibrate];
    if (openSound || openVibrate) {
        if (_messageSoundID == 0) { // 还未注册系统音
            NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"message" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(filePath), &_messageSoundID);
        }
        
        if (openSound && openVibrate) { // 声音+震动
            AudioServicesPlayAlertSound(_messageSoundID);
        } else if (openSound) {
            AudioServicesPlaySystemSound(_messageSoundID);
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:key];
    }
    
}

// 播放摇动提示音
- (void)playShakeSound
{
    if ([[SFConfigCenter defaultCenter] isOpenSound]) {
        if (_shakeSoundID == 0) { // 还未注册系统音
            NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"shake" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(filePath), &_shakeSoundID);
        }
        AudioServicesPlaySystemSound(_shakeSoundID);
    }
    
}

// 播放震动音
- (void)playVibrateSound
{
    if ([[SFConfigCenter defaultCenter] isOpenVibrate]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark - Property

//- (IFlyRecognizeControl *)iFlyRecognizeControl
//{
//    if (!_iFlyRecognizeControl) {
//        NSString *initParam = [NSString stringWithFormat:@"server_url=%@,appid=%@", IFLY_ENGINE_URL, IFLY_APPID];
//        _iFlyRecognizeControl = [[IFlyRecognizeControl alloc] initWithOrigin:IFLY_CONTROL_ORIGIN initParam:initParam];
//        [_iFlyRecognizeControl setEngine:@"sms" engineParam:nil grammarID:nil];
//        [_iFlyRecognizeControl setSampleRate:16000];
//    }
//    return _iFlyRecognizeControl;
//}


@end
