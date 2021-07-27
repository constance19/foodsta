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

@property (nonatomic, strong) NSArray *arrayOfUsers;
@property (nonatomic, strong) NSArray *filteredUsers;

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
    
    // Load in user's recent searches
    PFUser *currentUser = [PFUser currentUser];
    self.filteredUsers = currentUser[@"searches"];
    
    // Fetch and save Parse user query
    [self loadUsers];
}

- (void) loadUsers {
    // Construct PFQuery for users in the Parse database
    PFQuery *userQuery = [PFUser query];
    [userQuery orderByAscending:@"username"];

    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (users) {
                    strongSelf.arrayOfUsers = users;
                    
                } else {
                    NSLog(@"😫😫😫 Error getting users: %@", error.localizedDescription);
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
    [user fetchIfNeeded];
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
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            NSString *username = [NSString stringWithFormat:@"@%@", evaluatedObject.username];
            return [username containsString:searchText];
        }];
        
        // Reset array of user results based on search text matches
        self.filteredUsers = [self.arrayOfUsers filteredArrayUsingPredicate:predicate];

    // If empty search bar, load in recent search history
    } else {
        PFUser *currentUser = [PFUser currentUser];
        self.filteredUsers = currentUser[@"searches"];
    }

    [self.tableView reloadData];
}

// Show cancel button on the far right of the search bar if user has typed
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

// When user clicks cancel button, delete text and hide cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Reset table view to recent search history
    PFUser *currentUser = [PFUser currentUser];
    self.filteredUsers = currentUser[@"searches"];
    [self.tableView reloadData];
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
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
        
        // Add clicked user to Parse recent searches array
        NSMutableArray *searches = currentUser[@"searches"];
        [searches addObject:tappedCell.user];
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
