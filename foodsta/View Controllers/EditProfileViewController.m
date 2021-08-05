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
    
    // Make profile image view circular
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
    
    // Dismiss keyboard upon tapping
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
}

-(void)dismissKeyboard {
    [self.bioField resignFirstResponder];
}

- (IBAction)onTapDone:(id)sender {
    //Display HUD right before the request is made
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
    // Configure HUD UI
    hud.mode = MBProgressHUDModeDeterminate;
    hud.square = YES;
    hud.animationType = YES;
    hud.label.text = @"Updating...";
    hud.label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIColor *myGreen = [UIColor colorWithRed:0.462 green:0.648 blue:0.642 alpha:1];
    hud.contentColor = myGreen;
    
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
    
    // Dismiss to go back to profile page
    typeof(self) __weak weakSelf = self;
    [self dismissViewControllerAnimated:YES completion: ^ {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                // Pass back the updated profile picture to the parent view controller (profile tab)
                self.onDismiss(self, self.profileImage.image, self.bioField.text);
            }
    }];
}

- (IBAction)onTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

// Prompt user with pop-up menu with options for either taking a photo or selecting from photo library
- (IBAction)onTapUpdate:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];

    // Camera for user to take a photo
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Instantiate a UIImagePickerController
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    
    // Photo library for user to select a photo
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Instantiate a UIImagePickerController
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];

    // Cancel option
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];

    // Don't include camera action for Xcode simulator
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:camera];
    }
    [alert addAction:library];
    [alert addAction:cancelAction];
    
    // Present pop-up menu with appropriate action options
    [self presentViewController:alert animated:YES completion:nil];
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

// MARK: UIImagePickerControllerDelegate
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
