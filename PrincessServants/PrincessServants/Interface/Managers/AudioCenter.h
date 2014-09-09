//
//  AudioCenter.h
//  ShadowFiend
//
//  Created by tixa on 14-6-30.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
#import <AudioToolbox/AudioToolbox.h>
//#import "iFlyMSC/IFlyRecognizeControl.h"

@interface AudioCenter : SFObject
{
    SystemSoundID _updateSoundID;
    SystemSoundID _messageSoundID;
    SystemSoundID _shakeSoundID;
}

//@property (nonatomic, strong) IFlyRecognizeControl *iFlyRecognizeControl;

+ (instancetype)defaultCenter;

- (void)playUpdateSound;             // 下拉刷新提示音
- (void)playMessageSound;            // 新消息提示音
- (void)playShakeSound;              // 摇动提示音
- (void)playVibrateSound;            // 震动

@end
