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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlaybackIsPreparedToPlayNotification:) name:MediaPlaybackIsPreparedToPlayNotification object:nil];
    
    ZHPlayer *player = [ZHPlayer new];
    
    self.player = player;
    
    player.view.frame = CGRectMake(0, 200, 320, 130);
    
    [player initPlayerWith:[NSURL URLWithString:@"http://software.swwy.com/Oz08NDRyNiY.m3u8"]];
    
    player.shouldAutoplay = false;
    
    [self.view addSubview:player.view];
}

- (void)mediaPlaybackIsPreparedToPlayNotification:(NSNotification *)noti {
    [self.player play];
    [self refresh];
}

- (void)refresh {
    NSLog(@"%lf---%lf",self.player.currentTime,self.player.duration);
    [self performSelector:@selector(refresh) withObject:nil afterDelay:1];
}

@end
