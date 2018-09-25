//
//  ObjectiveC.h
//  Assignment
//
//  Created by Group X on 25/09/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "movecoach.h"
#import <MapKit/MapKit.h>

@interface ObjectiveC : UIViewController<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *batteryprogressView;
@property (weak, nonatomic) IBOutlet UILabel * batteryprogressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelindication;
@property (weak, nonatomic) IBOutlet UILabel * pluggedstatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView * pluggedstatus;
@property (weak, nonatomic) IBOutlet UIView *batteryview;
@property (weak, nonatomic) IBOutlet UILabel *resultText;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;



@end
