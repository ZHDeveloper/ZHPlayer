//
//  ZHPlayerView.m
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZHPlayerView ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation ZHPlayerView

- (void)initPlayerWith:(NSURL *)url {
    
    self.playerItem = [self playerItemWith:url.absoluteString];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
    
}

- (AVPlayerItem *)playerItemWith:(NSString *)urlStr {
    
    if ([urlStr rangeOfString:@"http"].location != NSNotFound)
    {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
        return item;
    }
    else
    {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:urlStr]];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        return item;
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == self.playerItem)
    {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay)
        {
            [self.player play];
        }
        else if (self.playerItem.status == AVPlayerItemStatusFailed)
        {
            
        }
        
    }
    
}

#pragma mark - 布局
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    self.playerLayer.frame = self.layer.bounds;
}

#pragma mark - Getter&Setter 

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    
    if (playerItem) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}


@end
