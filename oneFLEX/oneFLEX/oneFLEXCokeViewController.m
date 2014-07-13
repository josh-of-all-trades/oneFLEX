//
//  oneFLEXCokeViewController.m
//  oneFLEX
//
//  Created by Josh Rojas on 7/12/14.
//  Copyright (c) 2014 Josh Rojas. All rights reserved.
//

#import "oneFLEXCokeViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface oneFLEXCokeViewController () <CLLocationManagerDelegate> {
    IBOutlet UITextField *latField;
    IBOutlet UITextField *longField;
    IBOutlet UITextView *cokeField;
}
@property (nonatomic, strong) CLLocationManager *locManager;
@end

@implementation oneFLEXCokeViewController


- (CLLocationManager *)locManager
{
    if (!_locManager) {
        _locManager = [[CLLocationManager alloc] init];
        _locManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locManager.delegate = self;
    }
    
    return _locManager;
}

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
    [self.locManager startUpdatingLocation];
    
}

-(IBAction)findCokeLocations:(id)sender{
    NSString *lat = latField.text;
    NSString *lon = longField.text;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.cokecce.com/v1/location/search/?latitude=%@&longitude=%@&rangeKilometers=1.0&format=json&apiKey=4njy9fd2wwmy7z8q6abfb577", lat, lon];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSError *err = 0;
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
    id cokeData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:0
                                                    error:&err];
    if (err) {
        cokeField.text = @"qq";
    } else {
        NSDictionary *cokeDict = cokeData;
        cokeField.text = cokeDict.description;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    CLLocation *locationToGeocode = [locations objectAtIndex:0];
    
    [reverseGeocoder reverseGeocodeLocation:locationToGeocode
                          completionHandler:^(NSArray *placemarks, NSError *error){
                              if (!error) {
                                  
                                  
                                  latField.text = [NSString stringWithFormat:@"%.4f", locationToGeocode.coordinate.latitude];
                                  longField.text = [NSString stringWithFormat:@"%.4f", locationToGeocode.coordinate.longitude];
                                  
                              }
                          }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
    latField.text = @"";
    longField.text = @"";
    
    UIAlertView *privaceErrorMessage = [[UIAlertView alloc] initWithTitle:@"No Access"
                                                                  message:@"Sorry but our app does not have access to your location.  Please change this in Settings->Privacy->Location"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    
    [privaceErrorMessage show];
    
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
