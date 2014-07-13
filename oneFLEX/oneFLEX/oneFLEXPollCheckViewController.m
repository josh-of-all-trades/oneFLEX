//
//  oneFLEXPollCheckViewController.m
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import "oneFLEXPollCheckViewController.h"

@interface oneFLEXPollCheckViewController (){
    IBOutlet UITextView *pollJson;
}

@end

@implementation oneFLEXPollCheckViewController

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
    [self startTimer];
    
    
}

- (void) startTimer
{
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:.05
                                                    target:self
                                                  selector:@selector(poll)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void) stopTimer
{
    [self.myTimer invalidate];
}

-(void)poll{
    @try {
        NSURL *url = [[NSURL alloc] initWithString:@"https://agent.electricimp.com/G3KN1JnELb0a?STATE&FLEX&GYROX"];
        NSError *err = 0;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
        id pollingData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:0
                                                           error:&err];
        if (err) {
            pollJson.text = @"qq";
        } else {
            NSDictionary *pollingDict = pollingData;
            pollJson.text = pollingDict.description;
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
