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
    // Retrieve Parse Search objects for user's recent searches
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *searchQuery = [PFQuery queryWithClassName:@"Search"];
    [searchQuery includeKey:@"userId"];
    [searchQuery includeKey:@"searchId"];
    [searchQuery whereKey:@"userId" equalTo:currentUser.objectId];
    [searchQuery orderByDescending:@"createdAt"];
    
    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable searchObjects, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (searchObjects) {
                    // Make array of object IDs for searched users
                    NSMutableArray *searchIds = [[NSMutableArray alloc] init];
                    for (PFObject *searchObject in searchObjects) {
                        [searchIds addObject:searchObject[@"searchId"]];
                    }
                    
                    // Make array of searched PFUsers
                    NSMutableArray *searchUsers = [[NSMutableArray alloc] init];
                    for (NSString *searchId in searchIds) {
                        PFQuery *userQuery = [PFUser query];
                        [userQuery whereKey:@"objectId" equalTo:searchId];
                        NSArray *searchObject = [userQuery findObjects];
                        [searchUsers addObject:searchObject[0]];
                    }
                    
                    // Load recent search history into table view
                    strongSelf.filteredUsers = searchUsers;
                    [self.tableView reloadData];
    
                } else {
                    NSLog(@"😫😫😫 Error getting search objects: %@", error.localizedDescription);
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
        PFUser *searchUser = tappedCell.user;
        profileController.user = searchUser;
        
        // Determine whether the searched user is already in recent search history
        PFUser *currentUser = [PFUser currentUser];
        PFQuery *searchedQuery = [PFQuery queryWithClassName:@"Search"];
        [searchedQuery includeKey:@"userId"];
        [searchedQuery includeKey:@"searchId"];
        [searchedQuery whereKey:@"userId" equalTo:currentUser.objectId];
        [searchedQuery whereKey:@"searchId" equalTo:searchUser.objectId];
        
        typeof(self) __weak weakSelf = self;
        [searchedQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable searched, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;  // strong by default
                if (strongSelf) {
                    // If in recent search history, remove old Parse Search object
                    if (searched != nil && searched.count != 0) {
                        PFObject *searchObject = searched[0];
                        [searchedQuery getObjectInBackgroundWithId:searchObject.objectId block:^(PFObject *search, NSError *error) {
                            // Delete search object from Parse
                            [search deleteInBackground];
                        }];
                    }
                }
        }];
        
        // Remove oldest Search object if recent search history is full
        PFQuery *limitQuery = [PFQuery queryWithClassName:@"Search"];
        [limitQuery includeKey:@"userId"];
        [limitQuery includeKey:@"searchId"];
        [limitQuery whereKey:@"userId" equalTo:currentUser.objectId];
        [limitQuery orderByAscending:@"createdAt"];
        
        [limitQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable searchHistory, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;  // strong by default
                if (strongSelf) {
                    
                    // If recent search history is full, remove oldest search
                    if (searchHistory.count == 10) {
                        PFObject *oldestSearch = searchHistory[0];
                        [limitQuery getObjectInBackgroundWithId:oldestSearch.objectId block:^(PFObject *search, NSError *error) {
                            // Delete search object from Parse
                            [search deleteInBackground];
                        }];
                    }
                }
        }];
                        
        // Add newly searched user to recent search history and save to Parse
        PFObject *search = [PFObject objectWithClassName:@"Search"];
        search[@"userId"] = currentUser.objectId;
        search[@"searchId"] = searchUser.objectId;

        [search saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Successfully added to search history");
                                      
            } else {
                // There was a problem, check error.description
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}


@end
