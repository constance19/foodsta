//
//  ComposeViewController.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "ComposeViewController.h"
#import "Post.h"
#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "LocationsViewController.h"
#import "HCSStarRatingView.h"

@interface ComposeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UITextView *captionView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set caption box display
    self.captionView.layer.borderWidth = 1.2f;
    self.captionView.clipsToBounds = YES;
    self.captionView.layer.cornerRadius = 3.0f;
    self.captionView.layer.borderColor = UIColor.blackColor.CGColor;

    // Set image view placeholder display
    UIColor *myGray = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.locationImage.layer.backgroundColor = myGray.CGColor;
    self.locationImage.image = nil;
    
    // Set placeholder text for caption view
    self.captionView.delegate = self;
//    self.captionView.text = @"Write a caption...";
    self.captionView.text = NSLocalizedString(@"Write a caption...", @"Tells the user to enter a caption");
    UIColor *myBlack = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.captionView.textColor = myBlack;
    
    // Set button display
    [self.photoButton setFrame:CGRectMake(173, 269, 130, 44)];
    
    // Set placeholder text for check-in location if user hasn't selected one
    self.searchBar.placeholder = @"Search Yelp..";
    
    // Set check-in location if user already selected one
    if (self.locationSelected) {
        self.searchBar.text = self.location.name;
    }
}

- (IBAction)onTapPhoto:(id)sender {
    // Instantiate a UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // Present camera on iPhone
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    // For Xcode simulator, present photo library
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    self.photoButton.hidden = YES;
}

- (IBAction)onTapShare:(id)sender {
    
    // If user did not enter a location, present alert message
    if ([self.searchBar.text length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing location!"
                                                                       message:@"Please enter a check-in location!"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else {
        // If user did not enter a caption, don't post placeholder caption
        NSString *caption = self.captionView.text;
        if ([caption isEqualToString:@"Write a caption..."]) {
            caption = @"";
        }
        
        //Display HUD right before the request is made
       [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
        
        // Post the image and caption and show the progress HUD
        [Post postCheckIn:self.locationImage.image withCaption:caption withLocation:self.searchBar.text withUrl: self.location.yelpURL withRating:@(self.ratingView.value) withCompletion:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error posting check-in", error.localizedDescription);
                // Show the progress HUD while user is waiting for the post request to complete
                [MBProgressHUD hideHUDForView:self.view animated:TRUE];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"Successfully posted check-in!");
                // Hide HUD once the network request comes back (must be done on main UI thread)
                [MBProgressHUD hideHUDForView:self.view animated:TRUE];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (IBAction)onTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
    self.locationImage.image = [self resizeImage:editedImage withSize:size];
    self.locationImage.image = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: UITextViewDelegate

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

// MARK: UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    LocationsViewController *locationsController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationsController"];
    [self presentViewController:locationsController animated:YES completion:nil];
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
