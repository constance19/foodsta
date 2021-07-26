//
//  ContainerTabController.m
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import "ContainerTabController.h"

@interface ContainerTabController ()

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end

@implementation ContainerTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBar setHidden:YES];
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
