//
//  AVPlayerView.m
//  AvplayerDemo
//
//  Created by tianyaxu on 2018/1/25.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "AVPlayerView.h"

@interface AVPlayerView() {
    AVPlayerLayer *_player;
}

@end

@implementation AVPlayerView

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)layer frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _player = layer;
        _player.backgroundColor = [UIColor blackColor].CGColor;
        _player.videoGravity = AVLayerVideoGravityResizeAspect;
        _player.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_player];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    _player.bounds = layer.bounds;
//    _player.position = CGPointMake(layer.position.x, layer.position.y - self.frame.origin.y);
    
    _player.anchorPoint = CGPointMake(0, 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
