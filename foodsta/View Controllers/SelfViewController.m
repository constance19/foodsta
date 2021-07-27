//
//  SelfViewController.m
//  foodsta
//
//  Created by constanceh on 7/14/21.
//

#import "SelfViewController.h"
#import "Post.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "EditProfileViewController.h"
#import "UsernameTimestampCell.h"
#import "LocationNameCell.h"
#import "RatingCell.h"
#import "ImageCell.h"
#import "LikeCell.h"
#import "CaptionCell.h"
#import "FollowViewController.h"
@import Parse;

@interface SelfViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Make profile image view circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    PFUser *user = [PFUser currentUser];
            
    // Set username and bio label
    self.usernameLabel.text = [@"@" stringByAppendingString: user.username];
    self.bioLabel.text = user[@"bio"];
            
    // Set profile image
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    self.profileImage.image = [[UIImage alloc] initWithData:fileData];
    
    // Get query of followings for the current user
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Followers"];
    [followingQuery includeKey:@"userid"];
    [followingQuery includeKey:@"followerid"];
    [followingQuery whereKey:@"followerid" equalTo:user.objectId];
    
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
    
    // Get query of followers for the current user
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Followers"];
    [followerQuery includeKey:@"userid"];
    [followerQuery includeKey:@"followerid"];
    [followerQuery whereKey:@"userid" equalTo:user.objectId];
    
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
    
    // User feed of posted check-ins
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.feedDataSource = [[FeedDataSource alloc] init];
    
    [self loadPosts:20];
}

// TODO: viewWillAppear

- (IBAction)onTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // Logout failed
        if (error) {
            NSLog(@"User logout failed: %@", error.localizedDescription);
        
        // Successful logout, PFUser.current() will now be nil
        } else {
            NSLog(@"User logged out successfully!");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:loginIdentifier];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
}

- (void) loadPosts: (int) numPosts {
    PFUser *currentUser = [PFUser currentUser];
    
    // Construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"liked"];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"image"];
    if (currentUser != nil) {
        [postQuery whereKey:@"author" equalTo:currentUser];
    }
    postQuery.limit = numPosts;

    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (posts) {
                    // Pass posts to data source
                    strongSelf.feedDataSource.arrayOfPosts = posts;
                    
                    [strongSelf.tableView reloadData];
                }
                else {
                    NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
                }
            }
    }];
}

// MARK: UITableViewDataSource

// Returns number of sections the table view should have (number of posts)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.feedDataSource numberOfSections];
}

// Returns number of rows in the section (number of components the post has)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedDataSource numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the model for current indexPath from FeedDataSource
    PostCellModel *model = [self.feedDataSource modelForIndexPath:indexPath];
    
    // Dequeue the cell with identifier based on model returned by FeedDataSource, load model into cell
    switch (model.type) {
        case PostCellModelTypeUsernameTimestamp: {
            UsernameTimestampCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usernameTimestampCell" forIndexPath:indexPath];
            cell.selfUsernameLabel.text = model.data[0];
            cell.selfTimestampLabel.text = model.data[1];
            return cell;
        }
            
        case PostCellModelTypeLocation: {
            LocationNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
            cell.selfLocationView.attributedText = model.data;
            cell.selfLocationView.dataDetectorTypes = UIDataDetectorTypeLink;
            [cell.selfLocationView setFont:[UIFont systemFontOfSize:19]];
            return cell;
        }
        
        case PostCellModelTypeImage: {
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            cell.selfLocationImage.file = model.data;
            [cell.selfLocationImage loadInBackground];
            return cell;
        }
            
        case PostCellModelTypeLikeCount: {
            LikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell" forIndexPath:indexPath];
            NSString *likeCount = [NSString stringWithFormat:@"%@", model.data];
            [cell.selfLikeButton setTitle:likeCount forState:UIControlStateNormal];
            return cell;
        }
            
        case PostCellModelTypeCaption: {
            CaptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"captionCell" forIndexPath:indexPath];
            cell.selfCaptionLabel.text = model.data;
            return cell;
        }
            
        case PostCellModelTypeRating: {
            RatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell" forIndexPath:indexPath];
            cell.selfRatingView.value = [model.data doubleValue];
            return cell;
        }
    }
}


// MARK: UITableViewDelegate

// For separator between sections (posts)
// TODO: fix UI of separator (too thick)
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect sepFrame = CGRectMake(0, tableView.frame.size.height, self.view.bounds.size.width, 1);
    UIView *separatorView =[[UIView alloc] initWithFrame:sepFrame];
    separatorView.backgroundColor = tableView.separatorColor;
    return separatorView;
}

//// For infinite scrolling
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section + 1 == [self.feedDataSource.arrayOfPosts count]) {
//        [self loadPosts:(int)[self.feedDataSource.arrayOfPosts count] + 20];
//    }
//}


#pragma mark - Navigation

// Only segue to followers/following list if the count > 0
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"selfFollowingSegue"] || [identifier isEqualToString:@"selfFollowingCountSegue"]) {
        if ([self.followingCount.text isEqualToString:@"0"]) {
            return NO;
        }
        return YES;
    }
    
    if ([identifier isEqualToString:@"selfFollowerSegue"] || [identifier isEqualToString:@"selfFollowerCountSegue"]) {
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
    
    // Segue to edit profile page
    if ([[segue identifier] isEqualToString:@"editProfileSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        EditProfileViewController *editController = navController.topViewController;
        editController.modalInPresentation = YES;
        
        // Pass back the updated profile picture to refresh the profile tab immediately
        editController.onDismiss = ^(UIViewController *sender, UIImage *profileImage, NSString *bio) {
            self.profileImage.image = profileImage;
            self.bioLabel.text = bio;
        };
    }
    
    // Segue to Following page
    if ([[segue identifier] isEqualToString:@"selfFollowingSegue"] || [[segue identifier] isEqualToString:@"selfFollowingCountSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        FollowViewController *followingController = navController.topViewController;
        followingController.title = @"Following";
        followingController.user = [PFUser currentUser];
        followingController.isFollowing = YES;
    }
    
    // Segue to Followers page
    if ([[segue identifier] isEqualToString:@"selfFollowerSegue"] || [[segue identifier] isEqualToString:@"selfFollowerCountSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        FollowViewController *followerController = navController.topViewController;
        followerController.title = @"Followers";
        followerController.user = [PFUser currentUser];
        followerController.isFollowing = NO;
    }
}


@end
