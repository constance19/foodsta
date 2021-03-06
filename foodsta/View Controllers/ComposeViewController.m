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

@interface ComposeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UITextView *captionView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ComposeViewController

static NSString *const captionPlaceholder = @"Write a caption...";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Location text field
    self.textField.delegate = self;
    
    // Set placeholder text for check-in location if user hasn't selected one
    self.textField.placeholder = NSLocalizedString(@"Search Yelp..", @"Tells the user the search bar is linked to Yelp");
    
    // Set check-in location if user already selected one
    if (self.locationSelected) {
        self.textField.text = self.location.name;
    }
    
    // Set previously saved rating value if necessary
    self.ratingView.value = self.ratingValue;
    
    // Set caption box display
    self.captionView.layer.borderWidth = 0.8f;
    self.captionView.clipsToBounds = YES;
    self.captionView.layer.cornerRadius = 5.0f;
    UIColor *textGray = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1];
    self.captionView.layer.borderColor = textGray.CGColor;
    
    // Set previously saved caption or placeholder text
    if (self.hasCaption) {
        self.captionView.text = self.caption;
    } else {
        // Set placeholder text for caption view
        self.captionView.delegate = self;
        self.captionView.text = captionPlaceholder;
        UIColor *myBlack = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        self.captionView.textColor = myBlack;
    }
    
    // Dismiss keyboard upon tapping
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];

    // Set image view placeholder display
    UIColor *myGray = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.locationImage.layer.backgroundColor = myGray.CGColor;
    self.locationImage.image = nil;
    
    // Set previously saved post image if necessary
    if (self.hasImage) {
        self.locationImage.image = self.postImage;
        self.photoButton.hidden = YES;
    }
    
    // Set select photo button display
    [self.photoButton setFrame:CGRectMake(173, 269, 130, 44)];
    
    // Only show cancel button if presented modally
    if (self.hideCancelButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void)dismissKeyboard {
    [self.captionView resignFirstResponder];
}

// Prompt user with pop-up menu with options for either taking a photo or selecting from photo library
- (IBAction)onTapPhoto:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIColor *myGreen = [UIColor colorWithRed:0.462 green:0.648 blue:0.642 alpha:1];
    alert.view.tintColor = myGreen;
    
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

- (IBAction)onTapShare:(id)sender {
    
    // If user did not enter a location, present alert message
    if ([self.textField.text length] == 0) {
        NSString *alertTitle = NSLocalizedString(@"Missing location!", @"Alert message title for missing location");
        NSString *alertMessage = NSLocalizedString(@"Please enter a check-in location!", @"Alert message instructions for missing location");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                       message:alertMessage
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
        if ([caption isEqualToString:captionPlaceholder]) {
            caption = @"";
        }
        
        //Display HUD right before the request is made
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
        
        // Configure HUD UI
        hud.mode = MBProgressHUDModeDeterminate;
        hud.square = YES;
        hud.animationType = YES;
        hud.label.text = @"Posting...";
        hud.label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        UIColor *myGreen = [UIColor colorWithRed:0.462 green:0.648 blue:0.642 alpha:1];
        hud.contentColor = myGreen;
        
        // Post the image and caption and show the progress HUD
        typeof(self) __weak weakSelf = self;
        [Post postCheckIn:self.locationImage.image withCaption:caption withLocation:self.textField.text withUrl: self.location.yelpURL withRating:@(self.ratingView.value) withLatitude: self.location.latitude withLongitude: self.location.longitude withCompletion:^(BOOL succeeded, NSError *error) {
            typeof(weakSelf) strongSelf = weakSelf;  // strong by default
                if (strongSelf) {
                    if (error) {
                        NSLog(@"Error posting check-in", error.localizedDescription);
                        // Show the progress HUD while user is waiting for the post request to complete
                        [MBProgressHUD hideHUDForView:self.view animated:TRUE];
                        
                        // Dismiss modal vc to go back to home feed
                        if (self.modalInPresentation) {
                            [strongSelf dismissViewControllerAnimated:YES completion:nil];
                        }
                    } else {
                        NSLog(@"Successfully posted check-in!");
                        // Hide HUD once the network request comes back (must be done on main UI thread)
                        [MBProgressHUD hideHUDForView:self.view animated:TRUE];
                        strongSelf.tabBarController.selectedIndex = 0;
                        
                        // Dismiss modal vc to go back to home feed
                        if (self.modalInPresentation) {
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                        }
                    }
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
    self.photoButton.hidden = YES;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: UITextViewDelegate

// Clear placeholder text when user begins editing the caption box
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:captionPlaceholder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

// Set placeholder text if caption box is empty
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = captionPlaceholder;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

// MARK: UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Save previously entered rating, caption, and/or image before searching for Yelp location
    if ([[segue identifier] isEqualToString:@"yelpLocationSegue"]) {
        LocationsViewController *locationController = [segue destinationViewController];
        
        // Pass rating value to Yelp search vc
        locationController.ratingValue = self.ratingView.value;
        
        // Pass caption to Yelp search vc if user typed anything
        if (![self.captionView.text isEqualToString:captionPlaceholder] && ![self.captionView.text isEqualToString:@""]) {
            locationController.caption = self.captionView.text;
        }
        
        // Pass post image to Yelp search vc if user selected one
        if (self.locationImage.image) {
            locationController.postImage = self.locationImage.image;
        }
    }
}


@end
