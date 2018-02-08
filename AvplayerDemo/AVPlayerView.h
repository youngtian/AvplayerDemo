//
//  AVPlayerView.h
//  AvplayerDemo
//
//  Created by tianyaxu on 2018/1/25.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView : UIView

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)layer frame:(CGRect)frame;

@end
