//
//  MapViewController.m
//  foodsta
//
//  Created by constanceh on 7/20/21.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Post.h"
@import Parse;

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *arrayOfPosts;
@property (nonatomic, strong) NSArray *arrayOfLocations;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:sfRegion animated:false];
    
    // Add annotations for check-in locations
    [self makeAnnotations];
}

- (void)makeAnnotations {
    // Construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"latitude"];
    [postQuery includeKey:@"longitude"];
    
    // Only include posts by following users and current user
    PFUser *currentUser = [PFUser currentUser];
    [postQuery whereKey:@"author" containedIn:currentUser[@"following"]];

    // Fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            // Fetch array of posts
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
            
            // Iterate through each location, get its coordinates, and add pins to the map along with location titles
            for (int i = 0; i < [self.arrayOfLocations count]; i++) {
                CLLocation *location = self.arrayOfLocations[i];
                CLLocationCoordinate2D coordinate = [location coordinate];
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:coordinate];
                
                Post *post = self.arrayOfPosts[i];
                NSString *locationName = post.locationTitle;
                [annotation setTitle:locationName]; //You can set the subtitle too
                [self.mapView addAnnotation:annotation];
            }
        }
        else {
            NSLog(@"😫😫😫 Error getting posts: %@", error.localizedDescription);
        }
    }];
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
