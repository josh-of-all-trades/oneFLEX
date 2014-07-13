//
//  oneFLEXFirstViewController.m
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import "oneFLEXFirstViewController.h"

@interface oneFLEXFirstViewController (){
    IBOutlet UITextView *scoresField;
}

@end

@implementation oneFLEXFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [[NSURL alloc] initWithString:@"http://api.espn.com/v1/sports/soccer/fifa.world/athletes?apikey=3ed4y6mbk53qn3hjgwwjk5c3"];
    NSError *err = 0;
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
    id sportsData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:&err];
    if (err) {
        scoresField.text = @"qq";
    } else {
        NSDictionary *sportsDict = sportsData;
        scoresField.text = ((NSArray *)sportsDict[@"sports"]).description;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
