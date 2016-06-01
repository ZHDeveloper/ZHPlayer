
### ZHPlayer

ZHPlayer是对AVPlayer进行封装，更加简介易用。封装思想参考IJKPlayer的API，可高度定制UI界面。

	//
	//  ZHPlayer.h
	//  ZHPlayer
	//
	//  Created by AdminZhiHua on 16/5/24.
	//  Copyright © 2016年 AdminZhiHua. All rights reserved.
	//
	
	#import <UIKit/UIKit.h>
	
	//缓冲的状态
	typedef NS_ENUM(NSUInteger, MediaLoadState)
	{
	    MediaLoadStateUnknow,
	    MediaLoadStatePlaythroughOK,//缓冲完成
	    MediaLoadStateStalled//正在缓冲
	};
	
	//播放的状态
	typedef NS_ENUM(NSUInteger, MediaPlaybackState)
	{
	    MediaPlaybackStateStopped,//未开始
	    MediaPlaybackStateReadyToPlay,//准备开始
	    MediaPlaybackStatePlaying,//正在播放
	    MediaPlaybackStatePaused,//暂停
	    MediaPlaybackStateInterrupted,//中断状态，暂时未实用
	    MediaPlaybackStateSeeking//快进或快退中。
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
	
	extern NSString *const MediaPlaybackStatusFailedNotification;
	extern NSString *const MediaPlayerLoadStateDidChangeNotification;
	extern NSString *const MediaPlayerPlaybackDidFinishNotification;
	extern NSString *const MediaPlayerPlaybackStatusDidChangeNotification;
	
