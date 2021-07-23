//
//  FollowViewController.m
//  foodsta
//
//  Created by constanceh on 7/22/21.
//

#import "FollowViewController.h"
#import "UserCell.h"
#import "ProfileViewController.h"

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *follows;

@end

@implementation FollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadUsers];
}

// Retrieve array of followings or followers
- (void) loadUsers {
    // Construct PFQuery of follow pair PFObjects
    PFQuery *followObjectQuery = [PFQuery queryWithClassName:@"Followers"];
    [followObjectQuery includeKey:@"userid"];
    [followObjectQuery includeKey:@"followerid"];
    
    // Case: Following page
    if (self.isFollowing) {
        [followObjectQuery whereKey:@"followerid" equalTo:self.user.objectId];
    
    // Case: Followers page
    } else {
        [followObjectQuery whereKey:@"userid" equalTo:self.user.objectId];
    }

    // Fetch query of follow PFObjects asynchronously
    [followObjectQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followObjects, NSError * _Nullable error) {
        if (followObjects) {
            // Make array of object ids for followers or followings
            NSMutableArray *followIds = [[NSMutableArray alloc] init];
            for (PFObject *followObject in followObjects) {
                if (self.isFollowing) {
                    [followIds addObject:followObject[@"userid"]];
                } else {
                    [followIds addObject:followObject[@"followerid"]];
                }
            }
            
            // Get query of users with matching object ids for the table view
            PFQuery *followQuery = [PFUser query];
            [followQuery whereKey:@"objectId" containedIn:followIds];
            [followQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> *_Nullable follows, NSError * _Nullable error) {
                if (follows) {
                    self.follows = follows;
                    [self.tableView reloadData];
                } else {
                    NSLog(@"😫😫😫 Error getting follows: %@", error.localizedDescription);
                }
            }];
            
        } else {
            NSLog(@"😫😫😫 Error getting follow objects: %@", error.localizedDescription);
        }
    }];
}


// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.follows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    // Make profile image view circular
    cell.followProfileImage.layer.cornerRadius = cell.followProfileImage.frame.size.height /2;
    cell.followProfileImage.layer.masksToBounds = YES;
    cell.followProfileImage.layer.borderWidth = 0;
    
    // Get and set the username for the cell
    PFUser *user = self.follows[indexPath.row];
    cell.user = user;
    cell.followUsernameLabel.text = [NSString stringWithFormat:@"@%@", user[@"username"]];
    
    // Get and set the profile picture for the cell
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    cell.followProfileImage.image = [[UIImage alloc] initWithData:fileData];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"followProfileSegue"]) {
        UserCell *tappedCell = sender;
                    
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = tappedCell.user;
        profileController.hideBackButton = YES;
    }
}


@end
