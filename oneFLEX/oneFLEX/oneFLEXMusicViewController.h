//
//  oneFLEXMusicViewController.h
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface oneFLEXMusicViewController : UIViewController
@property (nonatomic, strong) MPMusicPlayerController *mp;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSTimer *gestureTimer;
@end
