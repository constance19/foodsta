//
//  FollowViewController.m
//  foodsta
//
//  Created by constanceh on 7/22/21.
//

#import "FollowViewController.h"
#import "UserCell.h"

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *following;

@end

@implementation FollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.following = self.user[@"following"];
    [self loadUsers];
}

- (void) loadUsers {
    // Construct PFQuery
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"objectId"];
    [userQuery includeKey:@"username"];
    [userQuery includeKey:@"profileImage"];
    
    // Filter feed to include only posts by following users and current user
    PFUser *currentUser = [PFUser currentUser];
    [userQuery whereKey:@"objectId" containedIn:self.user[@"following"]];

    // Fetch data asynchronously
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            // Pass posts to data source
            self.following = users;
            
            [self.tableView reloadData];
        }
        else {
            NSLog(@"😫😫😫 Error getting followings: %@", error.localizedDescription);
        }
    }];
}

// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.following.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    // Make profile image view circular
    cell.followProfileImage.layer.cornerRadius = cell.followProfileImage.frame.size.height /2;
    cell.followProfileImage.layer.masksToBounds = YES;
    cell.followProfileImage.layer.borderWidth = 0;
    
    // Get and set the username and profile picture for the cell
    PFUser *user = self.following[indexPath.row];
    cell.user = user;
    cell.followUsernameLabel.text = [NSString stringWithFormat:@"@%@", user[@"username"]];
    
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    cell.followProfileImage.image = [[UIImage alloc] initWithData:fileData];
    
    return cell;
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
