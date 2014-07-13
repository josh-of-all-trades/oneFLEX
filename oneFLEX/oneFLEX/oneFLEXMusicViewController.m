//
//  oneFLEXMusicViewController.m
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import "oneFLEXMusicViewController.h"

@interface oneFLEXMusicViewController (){
    IBOutlet UILabel *songTitle;
    IBOutlet UILabel *artist;
    IBOutlet UILabel *album;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIImageView *artword;
}
@property (nonatomic, strong) MPVolumeView *mpview;
@end

@implementation oneFLEXMusicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mp = [MPMusicPlayerController applicationMusicPlayer];
    [self.mp setQueueWithQuery:[MPMediaQuery songsQuery]];
    self.mpview = [[MPVolumeView alloc] init];
    self.mpview.showsVolumeSlider = YES;
    [self registerForMediaPlayerNotifications];
    [self startTimer];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self stopGestureTimer];
    [self stopTimer];
    [self.mp stop];
}

-(void) viewDidAppear:(BOOL)animated {
    [self startTimer];
}

-(void)handleSongChanging:(id) notification{
    songTitle.text = [[self.mp nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
    artist.text = [[self.mp nowPlayingItem] valueForProperty:MPMediaItemPropertyArtist];
    album.text = [[self.mp nowPlayingItem] valueForProperty:MPMediaItemPropertyAlbumTitle];
    artword.image = [[[self.mp nowPlayingItem] valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:artword.image.size];
}

- (void) registerForMediaPlayerNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleSongChanging:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: self.mp];
    [self.mp beginGeneratingPlaybackNotifications];
}

-(IBAction)playPause:(id)sender{
    if ([self.mp playbackState] == MPMusicPlaybackStatePaused) {
        [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.mp play];
    } else {
        [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.mp pause];
    }
    if ([self.mp playbackState] == MPMusicPlaybackStateStopped){
        [playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.mp play];
    }
}

-(IBAction)nextSong:(id)sender{
    [self.mp skipToNextItem];
}

-(IBAction)prevSong:(id)sender {
    NSLog([NSString stringWithFormat:@"%f", self.mp.currentPlaybackTime]);
    if (self.mp.currentPlaybackTime < 5){
        [self.mp skipToPreviousItem];
    } else {
        [self.mp skipToBeginning];
    }
}

- (void) startTimer
{
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:.5
                                                    target:self
                                                  selector:@selector(poll)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void) stopTimer
{
    [self.myTimer invalidate];
}

- (void) startGestureTimer{
    self.gestureTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                         target:self
                                                       selector:@selector(gesturePoll)
                                                       userInfo:nil
                                                        repeats:YES];
}

-(void) stopGestureTimer{
    [self.gestureTimer invalidate];
}

-(void)poll{
    @try {
        NSURL *url = [[NSURL alloc] initWithString:@"https://agent.electricimp.com/G3KN1JnELb0a?STATE"];
        NSError *err = 0;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
        id pollingData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:0
                                                           error:&err];
        if (err) {
            NSLog(@"qq");
        } else {
            NSDictionary *pollingDict = pollingData;
            if ([[pollingDict valueForKey:@"STATE"] integerValue] > 0){
                NSLog(@"beginning polling for gestures");
                [self stopTimer];
                [self startGestureTimer];
            }
            else {
                NSLog(@"qq");
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(exception.reason);
    }
    @finally {
        
    }
}

-(void) gesturePoll{
    @try {
        NSURL *url = [[NSURL alloc] initWithString:@"https://agent.electricimp.com/G3KN1JnELb0a?STATE&GESTURE"];
        NSError *err = 0;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
        id pollingData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:0
                                                           error:&err];
        if (err) {
            NSLog(@"qq");
        } else {
            NSDictionary *pollingDict = pollingData;
            if ([[pollingDict valueForKey:@"STATE"] integerValue] == 1){
                if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == 1) {
                    NSLog(@"there was a gesture for next song");
                    [self nextSong:self.mp];
                } else if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == -1){
                    NSLog(@"there was a gesture for previous song");
                    [self prevSong:self.mp];
                } else if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == 2){
                    [self playPause:self.mp];
                }
                
            } else if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == 2) {
                NSLog(@"in volume mode");
            } else {
                NSLog(@"state invalidated");
                [self stopGestureTimer];
                [self startTimer];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(exception.reason);
    }
    @finally {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
