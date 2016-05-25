//
//  ZHPlayer.m
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ZHPlayer ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

//防止缓冲时循环调用方法导致无法释放内存
@property (nonatomic,assign) BOOL stop;

@end

@implementation ZHPlayer

- (instancetype)init {
    if ([super init])
    {
        [self setView:[UIView new]];
    }
    return self;
}

- (void)initPlayerWith:(NSURL *)url {
    
    self.playerItem = [self playerItemWith:url.absoluteString];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
}

- (AVPlayerItem *)playerItemWith:(NSString *)urlStr {
    
    if ([urlStr rangeOfString:@"http"].location != NSNotFound)
    {//网络视频播放
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
        return item;
    }
    else
    {//播放本地视频
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:urlStr]];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        return item;
    }
    
}

#pragma mark - Operation
- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)shutdown {
    
    [self pause];
    
    self.stop = YES;
    
    [self.view removeFromSuperview];
    [self.view removeObserver:self forKeyPath:@"frame"];
    
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    self.view = nil;
}

- (void)seekToTime:(NSTimeInterval)position completionHandler:(void (^)(BOOL finish))handeler {
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        CMTime time = CMTimeMake(position, 1);
        
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
            if (handeler)
            {
                handeler(finished);
            }
            
            [self play];
            
            self.playbackState = MediaPlaybackStateSeeking;
        }];
        
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == self.playerItem)
    {
        if ([keyPath isEqualToString:@"status"])
        {
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay)
            {
                [self playerItemStatusReadyToPlay];
            }
            else if (self.playerItem.status == AVPlayerItemStatusFailed)
            {//视频加载失败
                [self postNotification:MediaPlaybackStatusFailedNotification];
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"])
        {
            self.playableDuration = [self availableDuration];
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (self.playerItem.playbackBufferEmpty)
            {
                self.loadState = MediaLoadStateStalled;
                [self bufferingSomeSecond];
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            if (self.playerItem.playbackLikelyToKeepUp && self.loadState == MediaLoadStateStalled)
            {
                self.loadState = MediaLoadStatePlaythroughOK;
            }
            self.playbackState = MediaPlaybackStatePlaying;
        }
        
    }
    else if (object == self.view)
    {
        self.playerLayer.frame = self.view.bounds;
    }

}

- (void)playerItemStatusReadyToPlay {
    
    if (self.playbackState == MediaPlaybackStateSeeking) return;
    
    self.playbackState = MediaPlaybackStateReadyToPlay;
    
    if (self.shouldAutoplay)
    {
        if (self.seekTime > 0)
        {
            [self seekToTime:self.seekTime completionHandler:nil];
            return;
        }
        
        [self play];

    }
}

- (void)bufferingSomeSecond {
    
    [self pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self play];
        
        if (!self.playerItem.isPlaybackLikelyToKeepUp && !self.stop)
        {
            [self bufferingSomeSecond];
        }
        
    });
    
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)postNotification:(NSString *)noti {
    [[NSNotificationCenter defaultCenter] postNotificationName:noti object:self];
}

#pragma mark - NSNotification
- (void)moviePlayDidEnd:(NSNotification *)noti {
    [self postNotification:MediaPlayerPlaybackDidFinishNotification];
}

#pragma mark - Getter&Setter
- (void)setView:(UIView *)view {
    _view = view;
    [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setPlayableDuration:(NSTimeInterval)playableDuration {
    _playableDuration = playableDuration;
}

- (NSTimeInterval)duration {
    CMTime durationTime =  self.playerItem.duration;
    return CMTimeGetSeconds(durationTime);
}

- (NSTimeInterval)currentTime {
    CMTime positionTime = self.playerItem.currentTime;
    return CMTimeGetSeconds(positionTime);
}

- (void)setLoadState:(MediaLoadState)loadState {
    _loadState = loadState;
    [self postNotification:MediaPlayerLoadStateDidChangeNotification];
}

- (void)setPlaybackState:(MediaPlaybackState)playbackState {
    _playbackState = playbackState;
    //发送通知，播放状态发生改变
    [self postNotification:MediaPlayerPlaybackStatusDidChangeNotification];
}

- (void)dealloc {
    NSLog(@"ZHPlayer has dealloc!");
}

@end

NSString *const MediaPlaybackStatusFailedNotification = @"MediaPlaybackStatusFailedNotification";
NSString *const MediaPlayerLoadStateDidChangeNotification = @"MediaPlayerLoadStateDidChangeNotification";
NSString *const MediaPlayerPlaybackDidFinishNotification = @"MediaPlayerPlaybackDidFinishNotification";
NSString *const MediaPlayerPlaybackStatusDidChangeNotification = @"MediaPlayerPlaybackStatusDidChangeNotification";
