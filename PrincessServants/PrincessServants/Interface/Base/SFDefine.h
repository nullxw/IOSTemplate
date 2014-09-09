//
//  SFDefine.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#ifndef ShadowFiend_SFDefine_h
#define ShadowFiend_SFDefine_h

// ############### UI 通用定义 ################

// 字体

#define FONT_14             [UIFont systemFontOfSize:14.0]
#define FONT_16             [UIFont systemFontOfSize:16.0]

#define FONT_BOLD14         [UIFont boldSystemFontOfSize:14.0]
#define FONT_BOLD16         [UIFont boldSystemFontOfSize:16.0]

// 标题字体
#define FONT_TITLE          [UIFont boldSystemFontOfSize:17.0]
// 子标题字体
#define FONT_SUBTITLE       [UIFont systemFontOfSize:13.0]


// 间距

#define SPACING_3           3.0
#define SPACING_8           8.0
#define SPACING_15          15.0

// 小间距
#define SPACING_SMALL       5.0
// 中间距
#define SPACING_NORMAL      10.0
// 大间距
#define SPACING_LARGE       20.0


// ############### 其他 通用定义 ################

// 媒体类型
typedef enum {
    SFMediaTypeText       = 0,    //文本
    SFMediaTypeImage      = 1,    //静态图片
    SFMediaTypeGIF        = 2,    //动态图片
    SFMediaTypeAudio      = 3,    //语音
    SFMediaTypeVideo      = 4,    //视频
    SFMediaTypeURI        = 5,    //链接
    SFMediaTypeLocation   = 6,    //位置
    SFMediaTypeMood       = 7,    //心情
    SFMediaTypeFile       = 8     //文件
} SFMediaType;

// 性别
typedef enum {
    SFPersonGenderUnknown,
    SFPersonGenderMale,
    SFPersonGenderFemale
} SFPersonGender;


#endif
