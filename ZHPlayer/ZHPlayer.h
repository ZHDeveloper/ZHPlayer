//
//  ZHPlayer.h
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHPlayer : NSObject

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (void)shutdown;
- (void)setPauseInBackground:(BOOL)pause;

- (void)initPlayerWith:(NSURL *)url;

@property(nonatomic, readonly)  UIView *view;
@property(nonatomic)            NSTimeInterval currentPlaybackTime;
@property(nonatomic, readonly)  NSTimeInterval duration;
@property(nonatomic, readonly)  NSTimeInterval playableDuration;
@property(nonatomic, readonly)  NSInteger bufferingProgress;

@property(nonatomic, readonly)  BOOL isPreparedToPlay;
//@property(nonatomic, readonly)  IJKMPMoviePlaybackState playbackState;
//@property(nonatomic, readonly)  IJKMPMovieLoadState loadState;

@property(nonatomic, readonly) int64_t numberOfBytesTransferred;

@property(nonatomic, readonly) CGSize naturalSize;
//@property(nonatomic) IJKMPMovieScalingMode scalingMode;
@property(nonatomic) BOOL shouldAutoplay;


@end
