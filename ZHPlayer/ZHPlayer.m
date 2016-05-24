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

- (void)seekToTime:(NSTimeInterval)position completionHandler:(void (^)(BOOL finish))handeler {
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        CMTime time = CMTimeMake(position, 1);
        
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
            if (handeler)
            {
                handeler(finished);
            }
            
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
                if (self.shouldAutoplay)
                {
                    if (self.seekTime > 0)
                    {
                        [self seekToTime:self.seekTime completionHandler:^(BOOL finish) {
                            [self play];
                        }];
                    }
                    else
                    {
                        [self play];
                    }
                }
                [self postNotification:MediaPlaybackIsPreparedToPlayNotification];
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
                [self postNotification:MediaPlayerLoadStateDidChangeNotification];
                [self bufferingSomeSecond];
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            if (self.playerItem.playbackLikelyToKeepUp && self.loadState == MediaLoadStateStalled)
            {
                self.loadState = MediaLoadStatePlaythroughOK;
                [self postNotification:MediaPlayerLoadStateDidChangeNotification];
            }
        }
        
    }
    else if (object == self.view)
    {
        self.playerLayer.frame = self.view.bounds;
    }

}

- (void)bufferingSomeSecond {
    
    [self pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self play];
        
        if (!self.playerItem.isPlaybackLikelyToKeepUp)
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
    if (_view)
    {
        [view removeObserver:self forKeyPath:@"frame"];
    }
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
}

@end

NSString *const MediaPlaybackIsPreparedToPlayNotification = @"MediaPlaybackIsPreparedToPlayNotification";
NSString *const MediaPlaybackStatusFailedNotification = @"MediaPlaybackStatusFailedNotification";
NSString *const MediaPlayerLoadStateDidChangeNotification = @"MediaPlayerLoadStateDidChangeNotification";
NSString *const MediaPlayerPlaybackDidFinishNotification = @"MediaPlayerPlaybackDidFinishNotification";
