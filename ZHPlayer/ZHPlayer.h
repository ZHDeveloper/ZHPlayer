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

typedef NS_ENUM(NSUInteger, MeidaPlaybackState)
{
    MeidaPlaybackStateUnknow,
    MeidaPlaybackStatePlay,
    MeidaPlaybackStatePause,
};

@interface ZHPlayer : NSObject

- (void)play;
- (void)pause;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void(^)(BOOL finish))handeler;

- (void)initPlayerWith:(NSURL *)url;

//是否自动播放
@property(nonatomic) BOOL shouldAutoplay;

//当shouldAutoplay为YES有效
@property (nonatomic,assign) NSTimeInterval seekTime;

@property(nonatomic, readonly)  UIView *view;

@property(nonatomic, readonly)  NSTimeInterval currentTime;

@property(nonatomic, readonly)  NSTimeInterval duration;

@property(nonatomic, readonly)  NSTimeInterval playableDuration;

@property(nonatomic, readonly)  MeidaPlaybackState playbackState;

@property(nonatomic, readonly)  MediaLoadState loadState;

@end

extern NSString *const MediaPlaybackIsPreparedToPlayNotification;
extern NSString *const MediaPlaybackStatusFailedNotification;
extern NSString *const MediaPlayerLoadStateDidChangeNotification;
extern NSString *const MediaPlayerPlaybackDidFinishNotification;
