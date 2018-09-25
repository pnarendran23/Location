//
//  ObjectiveC.m
//  Assignment
//
//  Created by Group X on 25/09/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

#import "ObjectiveC.h"

@interface ObjectiveC ()

@end

@implementation ObjectiveC
@synthesize batteryview;
@synthesize batteryprogressView;
@synthesize batteryprogressLabel;
@synthesize spinner;
@synthesize levelindication;
@synthesize pluggedstatus;
@synthesize pluggedstatusLabel;
@synthesize resultText;
@synthesize mapView;
@synthesize locationView;
tasks *Tasks; //Created a global object; ARC doesn't wait until the Location manager's delegate methods are called in the Framework.
NSTimer *t;
int progress;
NSString *plugged;
- (void)viewDidLoad {
    [super viewDidLoad];
    [spinner setHidden:true];
    //Passing data can be done also using Delegate. In this project, I've used Post notification to pass the data from the library. Notifications are a bit easier to code and offer the advantage that multiple objects can observe one notification. Here, the call is happening once in each class. So, I would've also implemented Delegate.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedCurrentLocation:)
                                                 name:@"currentLocation"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedWeather:)
                                                 name:@"currentweather"
                                               object:nil];
    Tasks = [[tasks alloc] init];
    [batteryview setHidden:true];
    [resultText setHidden:true];
    [locationView setHidden:true];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated{
    [spinner setHidden:true];
    [batteryview setHidden:true];
    [resultText setHidden:true];
    [locationView setHidden:true];
    [t invalidate];
}

-(void)receivedCurrentLocation:(NSNotification *) notification{
    
    NSLog(@"%@",notification.userInfo);
    double latitude = [notification.userInfo[@"latitude"] floatValue]; //Converting dictionary data to double
    double longitude = [notification.userInfo[@"longitude"] floatValue]; //Converting dictionary data to double
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //This can also be done using a custom view Annotation method available in the MapView delegate. I choose this approach because I wanted to use a simple view and also there is only one marker which will be placed on the Map view.
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    marker.coordinate = currentLocation.coordinate;
    marker.title = @"Current Location";
    marker.subtitle = [NSString stringWithFormat:@"Latitude : %@  Longitude : %@",notification.userInfo[@"latitude"],notification.userInfo[@"longitude"]];
    [self.mapView addAnnotation:marker];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
}

-(void)receivedWeather:(NSNotification *) notification{
    NSLog(@"%@",notification.userInfo);
    [resultText setText:notification.userInfo[@"weather"]];
    [spinner setHidden:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)location:(id)sender {
    //This uses CLLocationManager to get the current location of the device. It can also be done using requestLocation() method using CLLocationManager. But it is way slower than the startUpdatingLocation()
    
    // Once the Location has been updated, then checking it whether the Boolean value fromLocation is true or false.
    //If it is true, then the system assumes that the next step should be sending back those values to the View controllers.
    // If it is not true, then the system assumes that the next step should be storing the retrieved values and proceeding to the weather API Call
    [Tasks setForLocation];
    [Tasks getLocation];
    [batteryview setHidden:true];
    [resultText setHidden:true];
    [locationView setHidden:false];
    [Tasks getLocation];

}

- (IBAction)battery:(id)sender {
    // This uses Device class to get the device attributes.
    // Enables battery monitoring property of the device object to read battery charge level and battery state.
    //Battery state normally returns the enum property of the current state. We can also use notifies to change Label texts dynamically when the charger gets connected or disconnected.
    // Battery level property returns the current battery level.
    
    [t invalidate];
    tasks *c = [[tasks alloc] init];
    [batteryview setHidden:false];
    [resultText setHidden:true];
    [locationView setHidden:true];
    progress = 0;
    plugged = @"";
    NSArray *a = [c getBattery];
    //NSLog(@"%@",[c getBattery]);
    NSString *temp = a[0];
    progress = [temp intValue];
    plugged = a[1];
    if([[plugged lowercaseString] isEqualToString:@"charging"] || [[plugged lowercaseString] isEqualToString:@"full"]){
        [pluggedstatus setImage:[UIImage imageNamed:@"plugged"]];
    }else{
        [pluggedstatus setImage:[UIImage imageNamed:@"unplugged"]];
    }
    
    if(progress == 0){
        [pluggedstatusLabel setText:[NSString stringWithFormat:@"Battery is %@ and charge level is empty",plugged]];
    }else if(progress == 100 && ([[plugged lowercaseString] isEqualToString:@"charging"] || [[plugged lowercaseString] isEqualToString:@"full"])){
        [pluggedstatusLabel setText:[NSString stringWithFormat:@"Battery is full and connected to power"]];
    }else if(progress == 100 && !([[plugged lowercaseString] isEqualToString:@"charging"] || [[plugged lowercaseString] isEqualToString:@"full"])){
        [pluggedstatusLabel setText:[NSString stringWithFormat:@"Battery is full and not connected to power"]];
    }else{
        [pluggedstatusLabel setText:[NSString stringWithFormat:@"Battery is %@ and %d%% charge is left",plugged,progress]];
    }
    
    
    [batteryprogressView setProgress:0 animated:NO];
    [batteryprogressLabel setText:@"0%"];
    t =[NSTimer scheduledTimerWithTimeInterval: 0.015f
                                                target: self
                                              selector: @selector(progressupdate)
                                              userInfo: nil
                                               repeats: YES];
}

-(void)progressupdate{
    if(batteryprogressView.progress< (int)progress/100){
        [batteryprogressView setProgress:(batteryprogressView.progress+=0.010) animated:YES];
        int currentValue = (int)(batteryprogressView.progress * 100);
        
        if(currentValue < 5){
            [levelindication setImage:[UIImage imageNamed:@"level1.png"]];
            [batteryprogressView setProgressTintColor:[UIColor redColor]];
        }else if(currentValue >= 5 && currentValue <= 25 ){
            [levelindication setImage:[UIImage imageNamed:@"level1.png"]];
            [batteryprogressView setProgressTintColor:[UIColor orangeColor]];
        }else if(currentValue > 25 && currentValue <= 50){
            [levelindication setImage:[UIImage imageNamed:@"level2.png"]];
            [batteryprogressView setProgressTintColor:[UIColor colorWithRed:1 green:212/255 blue:118/255 alpha:1]];
        }else if(currentValue > 50 && currentValue <= 90){
            [levelindication setImage:[UIImage imageNamed:@"level3.png"]];
            [batteryprogressView setProgressTintColor:[UIColor yellowColor]];
        }else if(currentValue > 90 && currentValue <= 100){
            [levelindication setImage:[UIImage imageNamed:@"level4.png"]];
            [batteryprogressView setProgressTintColor:[UIColor greenColor]];
        }
        [batteryprogressLabel setText:[NSString stringWithFormat:@"%d%%",(int)(batteryprogressView.progress * 100)] ];
    }
    else{
        [t invalidate];
        t = nil;
    }
}

- (IBAction)weather:(id)sender {
    //In this, there are lot more solutions available via onine. Yahoo uses yql to query the result, openweathermap, accuweather, wunderground etc., I've used Forecast.io for getting weather information. It is very easier to implement, free for 1000 requests in a day and also contains historical data.
    
    //Synchronous call is made since the request is very simple. Network can also be done using Alamofire(swift) which is very powerful in the recent times.
    
    //Response receives in the form of NSData.
    
    //After serialising the JSON from the NSData, Dictionary contains all the received data in the form of JSON
    
    //For the current record, I've used just two fields from the JSON. One is temperature(in Fahrenheit) and the other one is summary of the weather.
    
    [resultText setText:@""];
    [spinner setHidden:false];
    [resultText setTextAlignment:NSTextAlignmentCenter];
    [batteryview setHidden:true];
    [resultText setHidden:false];
    [locationView setHidden:true];
    [Tasks setForWeather];
    [Tasks getLocation];
}

-(NSString *)getBattery{
    [Tasks setForLocation];
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    
    int state = [myDevice batteryState];

    NSLog(@"battery status: %d",state); // 0 unknown, 1 unplegged, 2 charging, 3 full
    NSString *plug_state = @"";
    
    if([myDevice batteryState] == UIDeviceBatteryStateFull){
        plug_state = @"Full";
    }else if([myDevice batteryState] == UIDeviceBatteryStateUnplugged){
        plug_state = @"Unplug";
    }else if([myDevice batteryState] == UIDeviceBatteryStateUnknown){
         plug_state = @"Unknown";
    }else if([myDevice batteryState] == UIDeviceBatteryStateCharging){
        plug_state = @"Charging";
    }
    
    double batLeft = (float)[myDevice batteryLevel] * 100;
    NSLog(@"battery left: %f", batLeft);
    
    NSString *battery_string = [NSString stringWithFormat:@"Charger is %@ and %d%% charge is left",plug_state,(int)batLeft];
    
    return battery_string;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
