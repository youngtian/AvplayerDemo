//
//  ViewController.m
//  AvplayerDemo
//
//  Created by tianyaxu on 2018/1/24.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"
#import "UIViewExt.h"
#import "NSString+time.h"
#import "ProgressSlider.h"

@interface ViewController ()
{
    AVPlayer *_player;
    AVPlayerView *_playerView;
    BOOL _isPlay;
    CGFloat _currentTime;
    CGFloat _totalTime;
    CGFloat _progressLoaded;
}

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4"]];
    
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    
    _playerView = [[AVPlayerView alloc] initWithPlayerLayer:playerLayer frame:CGRectMake(0, 150, self.view.bounds.size.width, 200)];
    [self.view addSubview:_playerView];
    
    [self initPlayerSubViews];
    
    [self addNotification];
}

// 添加通知
- (void)addNotification {
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientaionAction:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // 前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

// 进入前台事件
- (void)enterForegroundNotification {
    if (_player != nil) {
        [_player play];
    }
}

// 进入后台事件
- (void)enterBackgroundNotification {
    if (_player != nil) {
        [_player pause];
    }
}

// 监听屏幕的旋转事件
- (void)orientaionAction:(NSNotification *)noti {
    if ([self isOrientationLandscape]) {
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _playerView.frame = self.view.bounds;
    } else {
        _playerView.frame = CGRectMake(0, 150, self.view.bounds.size.width, 200);
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    [self.bottomView removeFromSuperview];
    _bottomView = nil;
    self.bottomView.hidden = NO;
}

// 播放结束事件
- (void)playbackFinished:(NSNotification *)noti {
    UIButton *playBtn = [_bottomView viewWithTag:500];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    _isPlay = NO;
    [_player seekToTime:CMTimeMake(0, 1)];
}

- (void)initPlayerSubViews {
    
    self.bottomView.hidden = NO;
   
    __weak typeof (self) weskSelf = self;
    // 观察视频的播放进度
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        __strong typeof (self) strongSelf = weskSelf;
        AVPlayerItem *item = strongSelf->_player.currentItem;
        NSInteger currentTime = item.currentTime.value / item.currentTime.timescale;
        
        UILabel *label = [weskSelf.bottomView viewWithTag:501];
        label.text = [NSString convertTime:currentTime];
        [label sizeToFit];
        
        UILabel *totalLabel = [weskSelf.bottomView viewWithTag:502];
        totalLabel.text = [NSString convertTime:CMTimeGetSeconds(item.duration)];
        [totalLabel sizeToFit];
        
        strongSelf->_currentTime = currentTime;
        strongSelf->_totalTime = CMTimeGetSeconds(item.duration);
        
        ProgressSlider *slider = [weskSelf.bottomView viewWithTag:503];
        if (!slider.isSliding) {
            slider.sliderPercent = currentTime / strongSelf->_totalTime;
        }
    }];
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _playerView.height - 60, _playerView.width, 60)];
        _bottomView.backgroundColor = [UIColor blackColor];
        _bottomView.alpha = 0.5;
        [_playerView addSubview:_bottomView];
        
        // 播放按钮
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = CGRectMake(20, 19, 22, 22);
        if (_isPlay) {
            [playBtn setBackgroundImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
        } else {
            [playBtn setBackgroundImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        }
        
        [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        playBtn.tag = 500;
        [_bottomView addSubview:playBtn];
        
        UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(playBtn.right + 20, 20, 0, 0)];
        currentLabel.font = [UIFont systemFontOfSize:16];
        currentLabel.tag = 501;
        currentLabel.textColor = [UIColor whiteColor];
        [_bottomView addSubview:currentLabel];
        currentLabel.text = [NSString convertTime:_currentTime];
        [currentLabel sizeToFit];
        
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
        totalLabel.font = [UIFont systemFontOfSize:16];
        totalLabel.textColor = [UIColor whiteColor];
        totalLabel.tag = 502;
        [_bottomView addSubview:totalLabel];
        totalLabel.text = [NSString convertTime:_totalTime];
        [totalLabel sizeToFit];
        
        // 横屏按钮
        UIButton *largeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        largeBtn.frame = CGRectMake(_bottomView.width - 45, 19, 22, 22);
        if ([self isOrientationLandscape]) {
            [largeBtn setBackgroundImage:[UIImage imageNamed:@"player_window_iphone.png"] forState:UIControlStateNormal];
        } else {
            [largeBtn setBackgroundImage:[UIImage imageNamed:@"player_fullScreen_iphone.png"] forState:UIControlStateNormal];
        }
        
        [largeBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:largeBtn];
        
        totalLabel.right = largeBtn.left - 20;
        
        CGFloat width = totalLabel.left - 10 - currentLabel.right - 10;
        ProgressSlider *proSlider = [[ProgressSlider alloc] initWithFrame:CGRectMake(currentLabel.right + 10, 15, width, 30)];
        proSlider.tag = 503;
        proSlider.progressPercent = _progressLoaded;
        [_bottomView addSubview:proSlider];
        
        [proSlider addTarget:self action:@selector(sliderValueAction:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _bottomView;
}

// 快进事件
- (void)sliderValueAction:(ProgressSlider *)slider {
    if (_player.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = slider.sliderPercent * CMTimeGetSeconds(_player.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        [_player seekToTime:seekTime completionHandler:^(BOOL finished) {
        }];
    }
}

// 播放事件
- (void)playAction:(UIButton *)playBtn {
    if (_isPlay) {
        [_player pause];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    } else {
        [_player play];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
    }
    _isPlay = !_isPlay;
}

// 放大事件
- (void)btnAction:(UIButton *)btn {
    if ([self isOrientationLandscape]) {
        [self forceOrientation:UIInterfaceOrientationPortrait];
    } else {
        [self forceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

#pragma mark -KVO observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) { // 观察视频的缓存进度
        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);
    
        ProgressSlider *slider = [self.bottomView viewWithTag:503];
        if (!slider.isSliding) {
            slider.progressPercent = loadedTime / totalTime;
            _progressLoaded = loadedTime / totalTime;
        }
        
    } else if ([keyPath isEqualToString:@"status"]) { // 观察视频的状态
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [_player play];
            _isPlay = YES;
            UIButton *playBtn = [_bottomView viewWithTag:500];
            [playBtn setBackgroundImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
        } else {
            NSLog(@"load error");
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        // 缓存不够，视频加载不出来的通知
        NSLog(@"buffer empty");
    }
}

// 获取视频缓存的进度
- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem {
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

// 切换横竖屏
- (void)forceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

// 判断是否是横屏状态
- (BOOL)isOrientationLandscape {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    }
    return NO;
}

#pragma mark -Screen Rotate
// 设置是否支持旋转屏幕
- (BOOL)shouldAutorotate {
    return YES;
}

// 支持旋转的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape; 只支持横向
    return UIInterfaceOrientationMaskAll; // 支持全部
}

// 默认显示的方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
