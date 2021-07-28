//
//  SearchViewController.m
//  foodsta
//
//  Created by constanceh on 7/19/21.
//

#import "SearchViewController.h"
#import "UserCell.h"
#import "ProfileViewController.h"
@import Parse;

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *filteredUsers;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.searchBar becomeFirstResponder];
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.placeholder = NSLocalizedString(@"Search for user...", @"Tells the user to search for a user");
    
    // Set title label to "Recent"
    self.titleLabel.text = NSLocalizedString(@"Recent", @"Tells the user the displayed users are recent searches");
    
    // Fetch recently searched users and load into table view
    [self loadRecentSearches];
    
    // Fetch and save Parse user query
    [self loadUsers];
}

// Fetch and save users in the Parse database
- (void) loadUsers {
    // Construct PFQuery for all users in the Parse database
    PFQuery *userQuery = [PFUser query];
    [userQuery orderByAscending:@"username"];
    [userQuery includeKey:@"username"];

    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (users) {
                    strongSelf.allUsers = users;
                    
                } else {
                    NSLog(@"😫😫😫 Error getting users: %@", error.localizedDescription);
                }
            }
    }];
}

// Fetch current user's recent search history
- (void) loadRecentSearches {
    // Retrieve objectIds for user's recent searches
    PFUser *currentUser = [PFUser currentUser];
    NSArray *searchIds = currentUser[@"searches"];
    
    // Construct PFQuery to fetch Parse users for recent searches
    PFQuery *userQuery = [PFUser query];
    [userQuery orderByAscending:@"username"];
    [userQuery includeKey:@"username"];
    [userQuery whereKey:@"objectId" containedIn:searchIds];

    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (users) {
                    strongSelf.filteredUsers = users;
                    [self.tableView reloadData];
                    
                } else {
                    NSLog(@"😫😫😫 Error getting recently searched users: %@", error.localizedDescription);
                }
            }
    }];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}


// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    // Make profile image view circular
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height /2;
    cell.profileImage.layer.masksToBounds = YES;
    cell.profileImage.layer.borderWidth = 0;
    
    // Get and set the username for the cell
    PFUser *user = self.filteredUsers[indexPath.row];
    cell.user = user;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    
    // Get and set the profile picture for the cell
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    cell.profileImage.image = [[UIImage alloc] initWithData:fileData];
    
    return cell;
}


// MARK: UISearchBarDelegate

// Filtering of users for search bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // If search bar is not empty, set title label to "Results" and find user matches
    if (searchText.length != 0) {
        self.titleLabel.text = NSLocalizedString(@"Results", @"Tells the user the displayed users are search results");
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            NSString *username = [NSString stringWithFormat:@"@%@", evaluatedObject.username];
            return [username containsString:searchText];
        }];
        
        // Reset array of user results based on search text matches
        self.filteredUsers = [self.allUsers filteredArrayUsingPredicate:predicate];

    // If empty search bar, set title label to "Recent" and load in recent search history
    } else {
        self.titleLabel.text = NSLocalizedString(@"Recent", @"Tells the user the displayed users are recent searches");
        [self loadRecentSearches];
    }

    [self.tableView reloadData];
}

// Show cancel button on the far right of the search bar if user has typed
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

// When user clicks cancel button, delete text, hide cancel button, and show recent search history
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Configure search bar UI
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    // Set title label to "Recent" and load in recent search history
    self.titleLabel.text = NSLocalizedString(@"Recent", @"Tells the user the displayed users are recent searches");
    [self loadRecentSearches];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"searchProfileSegue"]) {
        // Pass clicked user to profile view controller
        UserCell *tappedCell = sender;
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = tappedCell.user;
        
        // Initialize Parse recent searches array if necessary
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser[@"searches"] == nil) {
            currentUser[@"searches"] = [[NSMutableArray alloc] init];
        }
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error updating recent searches", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated recent searches!");
            }
        }];
        
        // Add clicked user to recent search history and save to Parse
        NSMutableArray *searches = currentUser[@"searches"];
        [searches insertObject:tappedCell.user.objectId atIndex:0];
        currentUser[@"searches"] = searches;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error updating recent searches", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated recent searches!");
            }
        }];
    }
}


@end
