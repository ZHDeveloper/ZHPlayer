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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZHPlayer *player = [ZHPlayer new];
    
    player.view.frame = CGRectMake(0, 200, 320, 130);
    
    [self.view addSubview:player.view];
    
    [player initPlayerWith:[NSURL URLWithString:@"http://software.swwy.com/Oz08NDRyNiY.m3u8"]];
    
//    ZHPlayerView *player  = [ZHPlayerView new];
//    player.frame = CGRectMake(0, 200, 320, 130);
//    
//    [self.view addSubview:player];
//    
//    [player initPlayerWith:[NSURL URLWithString:@"http://software.swwy.com/Oz08NDRyNiY.m3u8"]];
}

@end
