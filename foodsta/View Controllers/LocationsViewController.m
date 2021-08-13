//
//  LocationsViewController.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "ComposeViewController.h"
#import "MBProgressHUD.h"

@interface LocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *locationBar;
@property (strong, nonatomic) NSMutableArray *arrayOfLocations;

@end

@implementation LocationsViewController

NSString *locationsIdentifier = @"locationsController";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    // Set placeholder text of search bars
    self.searchBar.placeholder = NSLocalizedString(@"Cafes, pasta, delivery, etc.", @"Location search suggestions");
    self.locationBar.placeholder = NSLocalizedString(@"Location..", @"User guidance to enter location");
}

-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
    [self.locationBar resignFirstResponder];
}

- (IBAction)onTapSearch:(id)sender {
    // Dismiss keyboard
    [self dismissKeyboard];
    
    // Process the search term and location to be compatible with the Yelp API, i.e. converting spaces to +
    NSString *rawTerm = self.searchBar.text;
    NSString *term = [rawTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *rawLocation = self.locationBar.text;
    NSString *location = [rawLocation stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    NSMutableURLRequest *requestData = [[NSMutableURLRequest alloc] init];
    NSString *str = [NSString stringWithFormat: @"https://api.yelp.com/v3/businesses/search?term=%@&location=%@&radius=10000", term, location];
    [requestData setURL:[NSURL URLWithString:str]];

    [requestData setHTTPMethod:@"GET"];
    NSString * APIParameter = @"Bearer VBHv7Qs9aw5kipARCA1zXH41do80z9YJmy5YJpVM3hw2GXXlF-vimVhtyBO-s-W5o5VzdkLbuucudqeQ777ZxQf1DS0EtMmUo8ZIqmDjvzvi1fK3tOsh-llc1nPsYHYx";


    [requestData setHTTPMethod:@"GET"];
    [requestData setValue:APIParameter forHTTPHeaderField:@"Authorization"];
    [requestData setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestData setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    //Display HUD right before the request is made
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
    // Configure HUD UI
    hud.mode = MBProgressHUDModeDeterminate;
    hud.square = YES;
    hud.animationType = YES;
    hud.label.text = @"Searching...";
    hud.label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIColor *myGreen = [UIColor colorWithRed:0.462 green:0.648 blue:0.642 alpha:1];
    hud.contentColor = myGreen;
    
    typeof(self) __weak weakSelf = self;
    [[session dataTaskWithRequest:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                NSArray *businesses = jsonArray[@"businesses"]; // array of dictionaries, each dictionary = business with 16 key/value pairs
                NSArray *locations = [Location locationsWithDictionaries:businesses];
                strongSelf.arrayOfLocations = locations;

                for (Location *loc in locations) {
                    NSLog(@"%@", loc.name);
                    NSLog(@"%@", loc.address);
                    NSLog(@"%@", loc.imageURL);
                }
        
                // Reload table view on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.tableView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
                });
            }
        }] resume];
}

// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    // Get and set the location
    Location *location = self.arrayOfLocations[indexPath.row];
    cell.location = location;
    cell.nameLabel.text = location.name;
    cell.addressLabel.text = location.address;
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: location.imageURL];
    cell.restaurantImage.image = [UIImage imageWithData: imageData];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Pass selected Yelp location and previously entered rating, caption, and/or post image if necessary
    if ([[segue identifier] isEqualToString:@"locationSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Location *location = self.arrayOfLocations[indexPath.row];
        
        ComposeViewController *composeController = [segue destinationViewController];
        
        // Pass selected Yelp location back to compose vc
        composeController.location = location;
        composeController.locationSelected = 1;
        
        // Pass previously entered rating back to compose vc
        composeController.ratingValue = self.ratingValue;
        
        // Save previously entered caption if necessary
        if (self.caption) {
            composeController.caption = self.caption;
            composeController.hasCaption = 1;
        } else {
            composeController.hasCaption = 0;
        }
        
        // Save previously selected image if necessary
        if (self.postImage) {
            composeController.postImage = self.postImage;
            composeController.hasImage = 1;
        } else {
            composeController.hasImage = 0;
        }
    }
 
}


@end
