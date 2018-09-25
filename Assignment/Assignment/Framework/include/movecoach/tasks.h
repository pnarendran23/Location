//
//  tasks.h
//  movecoach
//
//  Created by Group X on 25/09/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface tasks : NSObject<CLLocationManagerDelegate>{
    
}
@property (nonatomic, retain) CLLocationManager *locationManager;
-(NSArray *)getBattery;
-(void)getWeather;
-(void)setForLocation;
-(void)setForWeather;
-(void)getLocation;
@end
