//
//  ZHPlayer.h
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MediaLoadState)
{
    MediaLoadStateUnknow,
    MediaLoadStatePlaythroughOK,
    MediaLoadStateStalled
};

typedef NS_ENUM(NSUInteger, MediaPlaybackState)
{
    MediaPlaybackStateStopped,//未开始
    MediaPlaybackStatePlaying,
    MediaPlaybackStatePaused,
    MediaPlaybackStateInterrupted,
    MediaPlaybackStateSeeking
};

@interface ZHPlayer : NSObject

- (void)play;

- (void)pause;

- (void)shutdown;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void(^)(BOOL finish))handeler;

- (void)initPlayerWith:(NSURL *)url;

//是否自动播放
@property(nonatomic) BOOL shouldAutoplay;

//当shouldAutoplay为YES有效
@property(nonatomic, assign) NSTimeInterval seekTime;

@property(nonatomic, readonly)  UIView *view;

@property(nonatomic, readonly)  NSTimeInterval currentTime;

@property(nonatomic, readonly)  NSTimeInterval duration;

@property(nonatomic, readonly)  NSTimeInterval playableDuration;

//加载状态
@property(nonatomic, readonly)  MediaLoadState loadState;

//播放状态
@property(nonatomic, readonly)  MediaPlaybackState playbackState;

@end

extern NSString *const MediaPlaybackIsPreparedToPlayNotification;
extern NSString *const MediaPlaybackStatusFailedNotification;
extern NSString *const MediaPlayerLoadStateDidChangeNotification;
extern NSString *const MediaPlayerPlaybackDidFinishNotification;
extern NSString *const MediaPlayerPlaybackStatusDidChangeNotification;

