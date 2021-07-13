//
//  LocationsViewController.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"

@interface LocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *arrayOfLocations;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
}

- (IBAction)onTapSearch:(id)sender {
    NSString *term = self.searchBar.text;
//    NSString *location = @"sf";

    NSMutableURLRequest *requestData = [[NSMutableURLRequest alloc] init];
    NSString *str = [NSString stringWithFormat: @"https://api.yelp.com/v3/businesses/search?term=%@&location=sf&radius=10000", term];
    [requestData setURL:[NSURL URLWithString:str]];

    [requestData setHTTPMethod:@"GET"];
    // Insert your API KEY Below in the form: @"Bearer <APIKEY>"
    NSString * APIParameter = @"Bearer VBHv7Qs9aw5kipARCA1zXH41do80z9YJmy5YJpVM3hw2GXXlF-vimVhtyBO-s-W5o5VzdkLbuucudqeQ777ZxQf1DS0EtMmUo8ZIqmDjvzvi1fK3tOsh-llc1nPsYHYx";


    [requestData setHTTPMethod:@"GET"];
    [requestData setValue:APIParameter forHTTPHeaderField:@"Authorization"];
    [requestData setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestData setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];


    [[session dataTaskWithRequest:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        NSArray *businesses = jsonArray[@"businesses"]; // array of dictionaries, each dictionary = business with 16 key/value pairs
        NSArray *locations = [Location locationsWithDictionaries:businesses];
        self.arrayOfLocations = locations;

        for (Location *loc in locations) {
//            NSLog(@"%@, %@, %@", loc.name, loc.address, loc.imageURL);
            NSLog(@"%@", loc.name);
            NSLog(@"%@", loc.address);
            NSLog(@"%@", loc.imageURL);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }] resume];
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
