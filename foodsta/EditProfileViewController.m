//
//  EditProfileViewController.m
//  foodsta
//
//  Created by constanceh on 7/14/21.
//

#import "EditProfileViewController.h"
#import "Post.h"
#import "MBProgressHUD.h"
@import Parse;

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *updatePictureButton;
@property (weak, nonatomic) IBOutlet UITextField *bioField;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // make profile image view circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    // Set existing profile picture and bio
    PFUser *user = [PFUser currentUser];
    PFFileObject *profileImageFile = user[@"profileImage"];
    NSURL *url = [NSURL URLWithString: profileImageFile.url];
    NSData *fileData = [NSData dataWithContentsOfURL: url];
    self.profileImage.image = [[UIImage alloc] initWithData:fileData];
    
    self.bioField.text = user[@"bio"];
}

- (IBAction)onTapDone:(id)sender {
    //Display HUD right before the requests are made
   [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
    // Set profile image of current user
    PFUser *user = [PFUser currentUser];
    PFFileObject *profileImageFile = [Post getPFFileFromImage:self.profileImage.image];
    user[@"profileImage"] = profileImageFile;
    NSLog(@"%@", user[@"profileImage"]);
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating profile image", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated profile image!");
        }
    }];
    
    // Set bio of current user
    user[@"bio"] = self.bioField.text;
    NSLog(@"%@", user[@"bio"]);
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error updating bio", error.localizedDescription);
        } else {
            NSLog(@"Successfully updated bio!");
        }
    }];
    
    // Show the progress HUD while user is waiting for the post request to complete
    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
    
    // Dismiss to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


- (IBAction)onTapUpdate:(id)sender {
    // Instantiate a UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
        
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}


// Delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Set the image view to the selected image (resized?)
    CGSize size = CGSizeMake(300, 300);
    self.profileImage.image = [self resizeImage:editedImage withSize:size];
    self.profileImage.image = editedImage;
    
    // Make profile image circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height /2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Resize each photo before uploading to Parse (Parse has a limit of 10MB per file)
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
