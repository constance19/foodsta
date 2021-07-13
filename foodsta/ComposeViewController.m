//
//  ComposeViewController.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "ComposeViewController.h"
#import "Post.h"
//#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "LocationsViewController.h"

@interface ComposeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UITextView *captionView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set caption box display
    self.captionView.layer.borderWidth = 1.2f;
    self.captionView.clipsToBounds = YES;
    self.captionView.layer.cornerRadius = 3.0f;
    self.captionView.layer.borderColor = UIColor.blackColor.CGColor;
    
    // Set image view placeholder display
    UIColor *myGray = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.locationImage.layer.backgroundColor = myGray.CGColor;
    
    // Set placeholder text for caption view
    self.captionView.delegate = self;
    self.captionView.text = @"Write a caption...";
    UIColor *myBlack = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.captionView.textColor = myBlack;
    
    // Set button display
    [self.photoButton setFrame:CGRectMake(173, 269, 130, 44)];
}

- (IBAction)onTapPhoto:(id)sender {
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
    self.photoButton.hidden = YES;
}

- (IBAction)onTapShare:(id)sender {
    // Display HUD right before the request is made
//    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
//    // Post the image and caption and show the progress HUD
//    [Post postCheckIn:self.postImage.image withCaption:self.textView.text withCompletion:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"Error posting image", error.localizedDescription);
//
//            // Show the progress HUD while user is waiting for the post request to complete
//            [MBProgressHUD hideHUDForView:self.view animated:TRUE];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            NSLog(@"Successfully posted image!");
////            [self.delegate didPost:post];
//
//            // Hide HUD once the network request comes back (must be done on main UI thread)
//            [MBProgressHUD hideHUDForView:self.view animated:TRUE];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];
}

- (IBAction)onTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

// Delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Set the image view to the selected image (resized?)
    CGSize size = CGSizeMake(300, 300);
    self.locationImage.image = [self resizeImage:editedImage withSize:size];
    self.locationImage.image = editedImage;
    
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

// Clear placeholder text when user begins editing the caption box
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Write a caption..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

// Set placeholder text if caption box is empty
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write a caption...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                         bundle:nil];
    LocationsViewController *locationsController =
               [self.storyboard instantiateViewControllerWithIdentifier:@"locationsController"];

    [self presentViewController:locationsController
                       animated:YES
                     completion:nil];
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
