//
//  oneFLEXSecondViewController.m
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import "oneFLEXSecondViewController.h"

@interface oneFLEXSecondViewController (){
    IBOutlet UILabel *movTitle;
    IBOutlet UILabel *movRating;
    IBOutlet UILabel *releaseDate;
    IBOutlet UILabel *audScore;
    IBOutlet UILabel *criticScore;
    IBOutlet UITextView *synopsis;
    IBOutlet UIImageView *movPoster;
}
@property (nonatomic, strong) NSNumber *totalNumMovies;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSDictionary *moviesDict;
@end

@implementation oneFLEXSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [[NSURL alloc] initWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=16&page=1&country=us&apikey=7mavkhdyrunwesxuwmuz4qqa"];
    NSError *err = 0;
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
    id moviesData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:&err];
    if (err) {
        NSLog(@"qq");
    } else {
        self.moviesDict = moviesData;
        self.totalNumMovies = [NSNumber numberWithLong:[[self.moviesDict valueForKey:@"total"] integerValue]];
        self.count = @(0);
        [self updateDataLabels];
    }
    [self startTimer];
}

-(void) viewDidAppear:(BOOL)animated{
    [self startTimer];
}

-(void) viewDidDisappear:(BOOL)animated {
    [self stopTimer];
    [self stopGestureTimer];
}

-(void) updateDataLabels{
    NSDictionary *movieInfo = [[self.moviesDict valueForKey:@"movies"] objectAtIndex:self.count.intValue];
    NSLog([movieInfo description]);
    movRating.text = [movieInfo valueForKey:@"mpaa_rating"];
    synopsis.text = [movieInfo valueForKey:@"synopsis"];
    movTitle.text = [movieInfo valueForKey:@"title"];
    releaseDate.text = [[movieInfo valueForKey:@"release_dates"] valueForKey:@"theater"];
    audScore.text = [NSString stringWithFormat:@"%ld", [[[movieInfo valueForKey:@"ratings"] valueForKey:@"audience_score"] integerValue]];
    criticScore.text = [NSString stringWithFormat:@"%ld", [[[movieInfo valueForKey:@"ratings"] valueForKey:@"critics_score"] integerValue]];
    NSURL *imageUrl = [NSURL URLWithString:[[movieInfo valueForKey:@"posters"] valueForKey:@"original"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *poster = [UIImage imageWithData:imageData];
    movPoster.image = poster;

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
                    self.count = [NSNumber numberWithInt:((self.count.intValue + 1)%self.totalNumMovies.intValue)];
                    [self updateDataLabels];
                } else if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == -1){
                    NSLog(@"there was a gesture for previous song");
                    self.count = [NSNumber numberWithInt:((self.count.intValue - 1)%self.totalNumMovies.intValue)];
                    [self updateDataLabels];
                }
            } else if ([[pollingDict valueForKey:@"GESTURE"] integerValue] == 2){
                NSLog(@"finger mode active");
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

@end
