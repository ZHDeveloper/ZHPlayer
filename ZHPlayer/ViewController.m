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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meidaPlayerLoadStateDidChangeNotification:) name:MeidaPlayerLoadStateDidChangeNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mediaPlaybackIsPreparedToPlayNotification:(NSNotification *)noti {
    NSLog(@"视频准备播放");
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
    }
    
}

- (void)refresh {
    NSLog(@"%lf---%lf",self.player.currentTime,self.player.duration);
    [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
}

#pragma mark - Action
- (IBAction)start:(id)sender {
    
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
    
    [self initPlayerWithSeekTime:90];
}

- (IBAction)play:(id)sender {
    
}

- (IBAction)pause:(id)sender {
    
}






@end
