//
//  ProfileViewController.m
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import "ProfileViewController.h"
@import Parse;

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

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
        PFUser *currentUser = [PFUser currentUser];
        NSArray *following = currentUser[@"following"];

        // If current user follows clicked user, follow button should be selected
        if ([following containsObject:self.user.objectId]) {
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            [self.followButton setSelected:YES];
        
        // If current user does not follow clicked user, follow button should be unselected
        } else {
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)onTapFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    PFUser *profileUser = self.user;
    
    // Initialize current user's following array if necessary
    if (currentUser[@"following"] == nil) {
        currentUser[@"following"] = [[NSMutableArray alloc] init];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error updating following status", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated following status!");
            }
        }];
    }

    // Toggle following status for user
    // Unfollow clicked user
    if ([currentUser[@"following"] containsObject:profileUser.objectId]) {
        NSMutableArray *following = currentUser[@"following"];
        [following removeObject: profileUser.objectId];
        currentUser[@"following"] = following;
    
    // Follow clicked user
    } else {
        NSMutableArray *following = currentUser[@"following"];
        [following addObject: profileUser.objectId];
        currentUser[@"following"] = following;
    }
    
    // Save new following data to Parse
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating following status", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated following status!");
            
        }
    }];
    
    // Toggle display of button
    if ([self.followButton isSelected]) {
        [self.followButton setSelected:NO];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    } else {
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setSelected:YES];
    }
    
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
