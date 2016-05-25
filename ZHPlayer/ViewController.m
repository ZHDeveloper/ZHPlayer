//
//  ViewController.m
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ViewController.h"
#import "ZHPlayer.h"

@interface ViewController ()

@property (nonatomic,strong) ZHPlayer *player;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self installNotifications];
}

#pragma mark - Notification
- (void)installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlaybackIsPreparedToPlayNotification:) name:MediaPlaybackIsPreparedToPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlaybackStatusFailedNotification:) name:MediaPlaybackStatusFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meidaPlayerLoadStateDidChangeNotification:) name:MediaPlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerPlaybackDidFinishNotification:) name:MediaPlayerPlaybackDidFinishNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mediaPlaybackIsPreparedToPlayNotification:(NSNotification *)noti {
    NSLog(@"视频准备播放");
    [self autoRefresh];
}

- (void)mediaPlaybackStatusFailedNotification:(NSNotification *)noti {
    if (self.player)
    {
        NSLog(@"视频加载失败！");
    }
}

- (void)meidaPlayerLoadStateDidChangeNotification:(NSNotification *)noti {
    
    if (self.player && self.player.loadState == MediaLoadStateStalled)
    {
        NSLog(@"进入缓冲");
    }
    else if (self.player && self.player.loadState == MediaLoadStatePlaythroughOK)
    {
        NSLog(@"缓冲完成！");
        [self autoRefresh];
    }
    
}

- (void)mediaPlayerPlaybackDidFinishNotification:(NSNotification *)noti {
    NSLog(@"播放结束");
}

#pragma mark - Action
- (IBAction)start:(id)sender {
    
    if (self.player) {
        [self destory:nil];
    }
    
    [self initPlayerWithSeekTime:0];
    
}



- (void)initPlayerWithSeekTime:(NSTimeInterval)time {
    
    ZHPlayer *player = [ZHPlayer new];
    
    self.player = player;
    
    player.seekTime = time;
    
    player.view.frame = self.contentView.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    [player initPlayerWith:[NSURL URLWithString:@"http://software.swwy.com/Oz08NDRyNiY.m3u8"]];
    
    player.shouldAutoplay = YES;
    
    [self.contentView addSubview:player.view];
}

- (IBAction)SecondStart:(id)sender {
    
    if (self.player) {
        [self destory:nil];
    }

    [self initPlayerWithSeekTime:90];
}

- (IBAction)play:(id)sender {
    [self.player play];
}

- (IBAction)pause:(id)sender {
    [self.player pause];
}

- (IBAction)slideBegain:(UISlider *)sender {
    [self cancelAutoRefresh];
}

- (IBAction)sliderValueChange:(UISlider *)sender {
    
}

- (IBAction)slideEndAction:(UISlider *)sender {
    
    [self.player seekToTime:sender.value completionHandler:nil];
    
}

- (IBAction)destory:(id)sender {
    [self.player shutdown];
    self.player = nil;
}

- (void)cancelAutoRefresh {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoRefresh) object:nil];
}

- (void)autoRefresh {
    
    NSTimeInterval duration = self.player.duration;
    NSInteger intDuration = duration + 0.5;
    
    if (intDuration > 0) {
        self.slider.maximumValue = duration;
    } else {
        self.slider.maximumValue = 1.0f;
    }
    
    NSTimeInterval position = self.player.currentTime;
    NSInteger intPosition = position + 0.5;
    if (intPosition > 0) {
        self.slider.value = position;
    } else {
        self.slider.value = 0.0f;
    }

    self.startTimeLabel.text = [self dateStringWiht:position];
    self.endTimeLabel.text = [self dateStringWiht:duration];
    
    NSTimeInterval playableDuration = self.player.playableDuration;
    
    self.cacheProgress.progress = playableDuration/duration;
    
    [self performSelector:@selector(autoRefresh) withObject:nil afterDelay:1];
}

- (NSString *)dateStringWiht:(CGFloat)second {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSString *timeString = [formatter stringFromDate:date];
    
    return timeString;
}


@end
