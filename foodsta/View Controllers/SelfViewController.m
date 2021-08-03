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
#import "ContainerTabController.h"
@import Parse;

@interface SelfViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedMapToggle;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

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
                    strongSelf.followingCount.text = [@" " stringByAppendingString:[NSString stringWithFormat: @"%d", count]];
                } else {
                    strongSelf.followingCount.text = @" 0";
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
                    strongSelf.followerCount.text = [@" " stringByAppendingString:[NSString stringWithFormat: @"%d", count]];
                } else {
                    strongSelf.followerCount.text = @" 0";
                }
            }
    }];
    
    // Round follower count label corners
    CGRect bounds = self.followerCount.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    self.followerCount.layer.mask = maskLayer;
    
    // Round followers label corners
    CGRect bounds2 = self.followersLabel.bounds;
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:bounds2
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                                          cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.frame = bounds2;
    maskLayer2.path = maskPath2.CGPath;
    self.followersLabel.layer.mask = maskLayer2;
    
    // Round following count label corners
    CGRect bounds3 = self.followingCount.bounds;
    UIBezierPath *maskPath3 = [UIBezierPath bezierPathWithRoundedRect:bounds3
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                          cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer3 = [CAShapeLayer layer];
    maskLayer3.frame = bounds3;
    maskLayer3.path = maskPath3.CGPath;
    self.followingCount.layer.mask = maskLayer3;
    
    // Round following label corners
    CGRect bounds4 = self.followingLabel.bounds;
    UIBezierPath *maskPath4 = [UIBezierPath bezierPathWithRoundedRect:bounds4
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                                          cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer4 = [CAShapeLayer layer];
    maskLayer4.frame = bounds4;
    maskLayer4.path = maskPath4.CGPath;
    self.followingLabel.layer.mask = maskLayer4;
}

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

// Switch between map and posts feed
- (IBAction)onTapToggle:(id)sender {
    ContainerTabController *tabController = self.childViewControllers.lastObject;
    
    // Switching to feed view
    if (self.feedMapToggle.selectedSegmentIndex == 0) {
        [tabController setSelectedIndex:0];
        
    // Switching to map view
    } else {
        [tabController setSelectedIndex:1];
    }
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
    
    // Segue from toggle to tab bar controller
    if ([[segue identifier] isEqualToString:@"selfToggleTabSegue"]) {
        ContainerTabController *tabController = [segue destinationViewController];
        tabController.user = [PFUser currentUser];
    }
}


@end
