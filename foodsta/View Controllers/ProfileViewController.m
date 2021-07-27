//
//  ProfileViewController.m
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import "ProfileViewController.h"
#import "FollowViewController.h"
#import "ContainerTabController.h"
@import Parse;

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedMapToggle;
@property (weak, nonatomic) IBOutlet UIView *toggleContainer;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Make profile image view circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    // Set username and bio labels
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.bioLabel.text = self.user[@"bio"];

    // Set profile image
    PFFileObject *profileImageFile = self.user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    self.profileImage.image = [[UIImage alloc] initWithData:fileData];

    // If clicked profile is current user, hide follow button
    PFUser *currentUser = [PFUser currentUser];
    if ([self.user[@"username"] isEqualToString:currentUser.username]) {
        self.followButton.hidden = YES;

    // Set following status for non-current users
    } else {
        [self.followButton setSelected:NO];
        
        // Query to determine whether current user follows the profile user
        PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
        [query includeKey:@"userid"];
        [query includeKey:@"followerid"];
        [query whereKey:@"userid" equalTo:self.user.objectId];
        [query whereKey:@"followerid" equalTo:[PFUser currentUser].objectId];
        
        typeof(self) __weak weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable follows, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;  // strong by default
                if (strongSelf) {
                    if (follows != nil) {
                        // Current user does not follow the profile user
                        if (follows.count == 0) {
                            [strongSelf.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                            
                        // Current user is following the profile user
                        } else {
                            [strongSelf.followButton setTitle:@"Following" forState:UIControlStateNormal];
                            [strongSelf.followButton setSelected:YES];
                        }
                        
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }
        }];
    }
    
    // Get query of followings for the profile user
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Followers"];
    [followingQuery includeKey:@"userid"];
    [followingQuery includeKey:@"followerid"];
    [followingQuery whereKey:@"followerid" equalTo:self.user.objectId];
    
    // Set following count
    typeof(self) __weak weakSelf = self;
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable following, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (following != nil) {
                    int count = following.count;
                    strongSelf.followingCount.text = [NSString stringWithFormat: @"%d", count];
                } else {
                    strongSelf.followingCount.text = @"0";
                }
            }
    }];
    
    // Get query of followers for the profile user
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Followers"];
    [followerQuery includeKey:@"userid"];
    [followerQuery includeKey:@"followerid"];
    [followerQuery whereKey:@"userid" equalTo:self.user.objectId];
    
    // Set follower count
    [followerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followers, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (followers != nil) {
                    int count = followers.count;
                    strongSelf.followerCount.text = [NSString stringWithFormat: @"%d", count];
                } else {
                    strongSelf.followerCount.text = @"0";
                }
            }
    }];
    
    // Hide back button if profile is presented from map annotation post
    if (self.hideBackButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (IBAction)onTapToggle:(id)sender {
    // Switching to feed view
    if (self.feedMapToggle.selectedSegmentIndex == 0) {
        [self.tabBarController setSelectedIndex:0];
        
//        ContainerTabController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"containerTabController"];
//        tbc.selectedIndex = 0;

        
    // Switching to map view
    } else {
        [self.tabBarController setSelectedIndex:1];
        
//        ContainerTabController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"containerTabController"];
//        tbc.selectedIndex = 1;
    }
}

- (IBAction)onTapFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    PFUser *profileUser = self.user;
    
    // Determine whether the current user follows the profile user
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query includeKey:@"userid"];
    [query includeKey:@"followerid"];
    [query whereKey:@"userid" equalTo:self.user.objectId];
    [query whereKey:@"followerid" equalTo:[PFUser currentUser].objectId];
    
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable follows, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (follows != nil) {
                    // Follow: add a Parse object with a follower relationship and increment follower count
                    if (follows.count == 0) {
                        PFObject *followPair = [PFObject objectWithClassName:@"Followers"];
                        followPair[@"userid"] = self.user.objectId;
                        followPair[@"followerid"] = currentUser.objectId;

                        [followPair saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"Successfully followed");
                                  
                            } else {
                                // There was a problem, check error.description
                                NSLog(@"%@", error.localizedDescription);
                            }
                        }];
                        
                        // Increment follower count immediately
                        int updateCount = [self.followerCount.text intValue];
                        updateCount++;
                        strongSelf.followerCount.text = [NSString stringWithFormat: @"%d", updateCount];
                        
                    // Unfollow: remove the Parse object for the follower relationship and decrement follower count
                    } else {
                        PFObject *followPair = follows[0];
                        [query getObjectInBackgroundWithId:followPair.objectId block:^(PFObject *followPair, NSError *error) {
                            // Delete follow pair object from Parse
                            [followPair deleteInBackground];
                        }];
                        
                        // Decrement follower count immediately
                        int updateCount = [self.followerCount.text intValue];
                        updateCount--;
                        strongSelf.followerCount.text = [NSString stringWithFormat: @"%d", updateCount];
                    }
                }
            }
    }];
    
    // Toggle display of follow/following button
    if ([self.followButton isSelected]) {
        [self.followButton setSelected:NO];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    } else {
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setSelected:YES];
    }
}


#pragma mark - Navigation

// Only segue to followers/following page if the count > 0
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"followingSegue"] || [identifier isEqualToString:@"followingCountSegue"]) {
        if ([self.followingCount.text isEqualToString:@"0"]) {
            return NO;
        }
        return YES;
    }
    
    if ([identifier isEqualToString:@"followerSegue"] || [identifier isEqualToString:@"followerCountSegue"]) {
        if ([self.followerCount.text isEqualToString:@"0"]) {
            return NO;
        }
        return YES;
    }
    return YES;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Segue to Following page
    if ([[segue identifier] isEqualToString:@"followingSegue"] || [[segue identifier] isEqualToString:@"followingCountSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        FollowViewController *followingController = navController.topViewController;
        followingController.title = @"Following";
        followingController.user = self.user;
        followingController.isFollowing = YES;
    }
    
    // Segue to Followers page
    if ([[segue identifier] isEqualToString:@"followerSegue"] || [[segue identifier] isEqualToString:@"followerCountSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        FollowViewController *followerController = navController.topViewController;
        followerController.title = @"Followers";
        followerController.user = self.user;
        followerController.isFollowing = NO;
    }
    
    // Segue from toggle to tab controller
    if ([[segue identifier] isEqualToString:@"toggleTabSegue"]) {
        ContainerTabController *tabController = [segue destinationViewController];
        tabController.user = self.user;
//        tabController.toggleIndex = self.feedMapToggle.selectedSegmentIndex;
    }
}

@end
