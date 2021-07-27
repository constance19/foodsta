//
//  ContainerMapViewController.m
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import "ContainerMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Post.h"
#import "LocationAnnotation.h"
#import "LocationAnnotationView.h"
#import "ContainerTabController.h"

@interface ContainerMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *arrayOfPosts;
@property (nonatomic, strong) NSArray *arrayOfLocations;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ContainerMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the user passed from the profile page
    ContainerTabController *tabController = self.tabBarController;
    self.user = tabController.user;
    
    // CLLocationManager to access user's location while app is in use
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    // Add custom annotation views for check-in locations
    [self makeAnnotations];
}

- (void)makeAnnotations {
    PFUser *profileUser = self.user;
    
    // Construct PFQuery of posts
    PFQuery *postQuery = [Post query];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"latitude"];
    [postQuery includeKey:@"longitude"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"likeCount"];
    
    // Filter feed to include only posts by the profile user
    [postQuery whereKey:@"author" equalTo:profileUser];
    
    // Fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.arrayOfPosts = posts;
            
            // Fetch array of locations with coordinate properties
            NSMutableArray *locations = [[NSMutableArray alloc] init];
            for (Post *post in self.arrayOfPosts) {
                if (post.latitude && post.longitude) {
                    double latitude = [post.latitude doubleValue];
                    double longitude = [post.longitude doubleValue];
                    
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                    [locations addObject:location];
                }
            }
            self.arrayOfLocations = locations;
            
            // Iterate through each location, get its coordinates, and add LocationAnnotation pins to the map
            for (int i = 0; i < [self.arrayOfLocations count]; i++) {
                CLLocation *location = self.arrayOfLocations[i];
                CLLocationCoordinate2D coordinate = [location coordinate];
                Post *post = self.arrayOfPosts[i];
                
                // Set the coordinate and post for the annotation
                LocationAnnotation *annotation = [[LocationAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.post = post;
                
                // Set the post image for the annotation
                PFFileObject *imageFile = post.image;
                if (imageFile) {
                    NSURL *url = [NSURL URLWithString: imageFile.url];
                    NSData *fileData = [NSData dataWithContentsOfURL: url];
                    UIImage *photo = [[UIImage alloc] initWithData:fileData];
                    annotation.photo = [self resizeImage:photo withSize:CGSizeMake(50.0, 50.0)];
                }
                
                // Add annotation to the map
                [self.mapView addAnnotation:annotation];
            }
            
        } else {
            NSLog(@"😫😫😫 Error getting feed posts: %@", error.localizedDescription);
        }
    }];
}

// Resizing input post image to fit the annotation pin callout
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];

    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;

    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}


// MARK: MKMapViewDelegate

// Zooms into user's current location as the map region center
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:YES];
}

// Creates a pin with a callout for each LocationAnnotation on the map
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // No annotation view needed for user's location
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
        
    // Add custom annotation view for post locations
    } else {
        LocationAnnotationView *annotationView = (LocationAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        
        // Make a pin with pop-up containing image and details button
        if (annotationView == nil) {
            annotationView = [[LocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            annotationView.canShowCallout = true;
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        // Set post image (if present) as annotation view's callout image
        LocationAnnotation *locationAnnotation = annotation;
        if (locationAnnotation.photo) {
            UIImageView *calloutImage = (UIImageView*)annotationView.leftCalloutAccessoryView;
            calloutImage.image = locationAnnotation.photo;
        }
        
        // Set Post property of LocationAnnotationView
        annotationView.post = locationAnnotation.post;
        
        return annotationView;
    }
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
