//
//  LoginViewController.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end


@implementation LoginViewController

NSString *loginIdentifier = @"LoginViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set placeholder text of username and password text fields
    self.usernameField.placeholder = NSLocalizedString(@"Phone number, username, or email", @"Tells user what to enter for the username field");
    self.passwordField.placeholder = NSLocalizedString(@"Password", @"Tells user to enter a password");
}

- (IBAction)onTapSignup:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        NSString *alertTitle = NSLocalizedString(@"Incomplete information!", @"Alert message title for failed signup");
        NSString *alertMessage = NSLocalizedString(@"Please fill out all text fields!", @"Alert message instructions for failed signup");
        
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
        // optional code for what happens after the alert controller has finished presenting
        
        }];
    }
    [self registerUser];
    
}

- (IBAction)onTapLogin:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        NSString *alertTitle = NSLocalizedString(@"Incomplete information!", @"Alert message title for failed login");
        NSString *alertMessage = NSLocalizedString(@"Please fill out all text fields!", @"Alert message instructions for failed login");
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
        
        }
        [self loginUser];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
//    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        // Error signing up
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            NSString *alertTitle = NSLocalizedString(@"Invalid username!", @"Alert message title for invalid username");
            NSString *alertMessage = NSLocalizedString(@"Enter valid username!", @"Alert message instructions for invalid username");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                           message:alertMessage
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
                        
                            // create an OK action
                            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                               style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                                     // handle response here.
                                                                             }];
                            // add the OK action to the alert controller
                            [alert addAction:okAction];
                            [self presentViewController:alert animated:YES completion:^{
                                // optional code for what happens after the alert controller has finished presenting
                            }];
        
        // Successful sign up
        } else {
            NSLog(@"User registered successfully");
            
            // Add user to its own following list
            PFUser *currentUser = [PFUser currentUser];
            NSMutableArray *following = [[NSMutableArray alloc] init];
            [following addObject: currentUser];
            currentUser[@"following"] = following;

            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error updating following status", error.localizedDescription);
                } else {
                    NSLog(@"Successfully updated following status!");
                    
                }
            }];
            
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"loginSegue" sender:self.signupButton];
        }
    }];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        
        // Error logging in
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            
            NSString *alertTitle = NSLocalizedString(@"Invalid username/password!", @"Alert message title for invalid login");
            NSString *alertMessage = NSLocalizedString(@"Enter valid username and password!", @"Alert message instructions for invalid login");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                           message:alertMessage
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
                        
                            // create an OK action
                            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                               style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                                     // handle response here.
                                                                             }];
                            // add the OK action to the alert controller
                            [alert addAction:okAction];
                            [self presentViewController:alert animated:YES completion:^{
                                // optional code for what happens after the alert controller has finished presenting
                            }];
        
        // Successful log in
        } else {
            NSLog(@"User logged in successfully");
            
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:self.loginButton];
        }
    }];
}

@end
