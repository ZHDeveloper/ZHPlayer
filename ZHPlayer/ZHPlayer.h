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

//- (void)prepareToPlay;
- (void)play;
- (void)pause;
//- (void)stop;
//- (BOOL)isPlaying;
//- (void)shutdown;
//- (void)setPauseInBackground:(BOOL)pause;

//是否自动播放

- (void)initPlayerWith:(NSURL *)url;

@property(nonatomic) BOOL shouldAutoplay;
@property(nonatomic, readonly)  UIView *view;
@property(nonatomic, readonly)  NSTimeInterval currentTime;
@property(nonatomic, readonly)  NSTimeInterval duration;
@property(nonatomic, readonly)  NSTimeInterval playableDuration;

//@property(nonatomic, readonly)  BOOL isPreparedToPlay;
@property(nonatomic, readonly)  MeidaPlaybackState playbackState;
@property(nonatomic, readonly)  MediaLoadState loadState;

//@property(nonatomic, readonly) int64_t numberOfBytesTransferred;
//
//@property(nonatomic, readonly) CGSize naturalSize;
//@property(nonatomic) IJKMPMovieScalingMode scalingMode;

@end

extern NSString *const MediaPlaybackIsPreparedToPlayNotification;
extern NSString *const MediaPlaybackStatusFailedNotification;
extern NSString *const MeidaPlayerLoadStateDidChangeNotification;
