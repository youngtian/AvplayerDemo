//
//  ProgressSlider.h
//  AvplayerDemo
//
//  Created by tianyaxu on 2018/1/30.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressSlider : UIControl

@property (nonatomic, assign) CGFloat value;//滑动值
@property (nonatomic, assign) CGFloat sliderPercent;//滑动百分比
@property (nonatomic, assign) CGFloat progressPercent;//缓冲的百分比

@property (nonatomic, assign) BOOL isSliding;//是否正在滑动  如果在滑动的是偶外面监听的回调不应该设置sliderPercent progressPercent 避免绘制混乱
@end
