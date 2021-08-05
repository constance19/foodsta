//
//  TabController.m
//  foodsta
//
//  Created by constanceh on 8/5/21.
//

#import "TabController.h"
#import "ComposeViewController.h"

@interface TabController () <UITabBarControllerDelegate>

@end

@implementation TabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = viewController;
    
    // Hide cancel button on compose vc if presented by tab bar button
    if ([navController.topViewController isMemberOfClass:[ComposeViewController class]]) {
        ComposeViewController *composeController = navController.topViewController;
        composeController.hideCancelButton = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"tabCheckInSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        ComposeViewController *composeController = navController.topViewController;
        composeController.hideCancelButton = YES;
    }
}
*/

@end
