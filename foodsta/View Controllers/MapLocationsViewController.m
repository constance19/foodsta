//
//  MapLocationsViewController.m
//  foodsta
//
//  Created by constanceh on 7/24/21.
//

#import "MapLocationsViewController.h"
#import "MapLocationCell.h"
#import "Post.h"
#import "DateTools.h"
#import "ProfileViewController.h"

@interface MapLocationsViewController () <UITableViewDelegate, UITableViewDataSource, MapLocationCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MapLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapLocationCell"];
    Post *post = self.arrayOfPosts[indexPath.row];
    
    // Get and set the location with Yelp link for the cell
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:post.locationTitle];
    [str addAttribute: NSLinkAttributeName value: post.locationUrl range: NSMakeRange(0, str.length)];
    cell.locationView.attributedText = str;
    cell.locationView.dataDetectorTypes = UIDataDetectorTypeLink;
    [cell.locationView setFont:[UIFont systemFontOfSize:19]];
    
    // Format and set createdAtString, convert Date to String using DateTool relative time
    NSDate *createdAt = post.createdAt;
    NSString *timestamp = createdAt.shortTimeAgoSinceNow;
    cell.timestampLabel.text = timestamp;
    
    // Make profile image view circular
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height /2;
    cell.profileImage.layer.masksToBounds = YES;
    cell.profileImage.layer.borderWidth = 0;
    
    // Get and set the username for the cell
    PFUser *user = post.author;
    cell.user = user;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user[@"username"]];
    
    // Get and set the profile picture for the cell
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    cell.profileImage.image = [[UIImage alloc] initWithData:fileData];
    
    // Set delegate for username label to profile segue
    cell.delegate = self;
    
    return cell;
}


// MARK: MapLocationCellDelegate
-(void)mapLocationCell:(MapLocationCell *) mapLocationCell didTap: (PFUser *)user {
    [self performSegueWithIdentifier:@"mapProfileSegue" sender:user];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Segue from username label to profile page
    if ([[segue identifier] isEqualToString:@"mapProfileSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = sender;
    }
}


@end
