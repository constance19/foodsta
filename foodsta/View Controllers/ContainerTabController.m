//
//  ContainerTabController.m
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import "ContainerTabController.h"

@interface ContainerTabController ()

@property (weak, nonatomic) IBOutlet UITabBar *toggleTabBar;

@end

@implementation ContainerTabController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Hide tab bar
    [self.toggleTabBar setHidden:YES];
        UIView *contentView;
        if ([[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
            contentView = [self.view.subviews objectAtIndex:1];
        } else {
            contentView = [self.view.subviews objectAtIndex:0];
        }
    contentView.frame = self.view.bounds;
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
