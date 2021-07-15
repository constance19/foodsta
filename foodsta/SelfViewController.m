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
@import Parse;

@interface SelfViewController () 

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end

@implementation SelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // make profile image view circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    PFUser *user = [PFUser currentUser];
            
    // Set username label
    self.usernameLabel.text = [@"@" stringByAppendingString: user.username];
    
    // Set bio
    self.bioLabel.text = user[@"bio"];
            
    // Set profile image
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    self.profileImage.image = [[UIImage alloc] initWithData:fileData];
}

- (IBAction)onTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        
        // Logout failed
        if (error) {
            NSLog(@"User logout failed: %@", error.localizedDescription);
        
        // Successful logout
        } else {
            NSLog(@"User logged out successfully!");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
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
