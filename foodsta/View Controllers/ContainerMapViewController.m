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
#import "PostViewController.h"

@interface ContainerMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, LocationAnnotationViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *arrayOfPosts;
@property (nonatomic, strong) NSArray *arrayOfLocations;
@property (nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *zoomInButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

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
    [self.mapView setShowsScale:YES];
    
    // Add custom annotation views for check-in locations
    [self makeAnnotations];
    
    // Round corners of zooming buttons
    CAShapeLayer *topCorners = [CAShapeLayer layer];
    topCorners.path = [UIBezierPath bezierPathWithRoundedRect: self.zoomInButton.bounds
                                                byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight
                                                      cornerRadii: (CGSize){7.5, 7.5}].CGPath;
    self.zoomInButton.layer.mask = topCorners;
    
    CAShapeLayer *bottomCorners = [CAShapeLayer layer];
    bottomCorners.path = [UIBezierPath bezierPathWithRoundedRect: self.zoomOutButton.bounds
                                                byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                      cornerRadii: (CGSize){7.5, 7.5}].CGPath;
    self.zoomOutButton.layer.mask = bottomCorners;
    
    // Round corners of refresh button
    CAShapeLayer *corners = [CAShapeLayer layer];
    corners.path = [UIBezierPath bezierPathWithRoundedRect: self.refreshButton.bounds
                                                byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                      cornerRadii: (CGSize){7.5, 7.5}].CGPath;
    self.refreshButton.layer.mask = corners;
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
    typeof(self) __weak weakSelf = self;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (posts) {
                    strongSelf.arrayOfPosts = posts;
                    
                    // Fetch array of locations with coordinate properties
                    NSMutableArray *locations = [[NSMutableArray alloc] init];
                    for (Post *post in strongSelf.arrayOfPosts) {
                        if (post.latitude && post.longitude) {
                            double latitude = [post.latitude doubleValue];
                            double longitude = [post.longitude doubleValue];
                            
                            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                            [locations addObject:location];
                        }
                    }
                    strongSelf.arrayOfLocations = locations;
                    
                    // Iterate through each location, get its coordinates, and add LocationAnnotation pins to the map
                    for (int i = 0; i < [strongSelf.arrayOfLocations count]; i++) {
                        CLLocation *location = strongSelf.arrayOfLocations[i];
                        CLLocationCoordinate2D coordinate = [location coordinate];
                        Post *post = strongSelf.arrayOfPosts[i];
                        
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
                            annotation.photo = [strongSelf resizeImage:photo withSize:CGSizeMake(50.0, 50.0)];
                        }
                        
                        // Add annotation to the map
                        [strongSelf.mapView addAnnotation:annotation];
                    }
                    
                } else {
                    NSLog(@"😫😫😫 Error getting feed posts: %@", error.localizedDescription);
                }
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

- (IBAction)onTapRefresh:(id)sender {
    // Re-zoom into user's current location
    MKUserLocation *userLocation = [self.mapView userLocation];
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude),
                                                       MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:YES];
    
    // Get array of all annotations except the user's current location
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if (userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }

    // Remove the pins from the map
    [self.mapView removeAnnotations:pins];
    pins = nil;
    
    // Refresh: add the updated annotations
    [self makeAnnotations];
}

- (IBAction)zoomIn:(id)sender {
    MKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta /= 2.0;
    region.span.longitudeDelta /= 2.0;
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)zoomOut:(id)sender {
    MKCoordinateRegion region = self.mapView.region;
    region.span.latitudeDelta  = MIN(region.span.latitudeDelta  * 2.0, 180.0);
    region.span.longitudeDelta = MIN(region.span.longitudeDelta * 2.0, 180.0);
    [self.mapView setRegion:region animated:YES];
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

// Segue to post when user taps detail disclosure button in annotation view callout
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    LocationAnnotationView *locationAnnotationView = (LocationAnnotationView *)view;
    locationAnnotationView.delegate = self;
    [locationAnnotationView.delegate locationAnnotationView:locationAnnotationView didTap:locationAnnotationView.post];
}


// MARK: LocationAnnotationViewDelegate

- (void)locationAnnotationView:(LocationAnnotationView *)locationAnnotationView didTap:(Post *)post {
    [self performSegueWithIdentifier:@"containerAnnotationPostSegue" sender:post];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Segue from annotation callout detail disclosure button
    if ([[segue identifier] isEqualToString:@"containerAnnotationPostSegue"]) {
        PostViewController *postController = [segue destinationViewController];
        postController.post = sender;
    }
}


@end
