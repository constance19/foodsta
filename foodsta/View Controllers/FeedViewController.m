//
//  FeedViewController.m
//  Pods
//
//  Created by constanceh on 7/12/21.
//

#import "FeedViewController.h"
//#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "PostCell.h"
//@import Parse;
#import "DateTools.h"
#import "LocationDetailsViewController.h"
#import "MBProgressHUD.h"
#import "FeedDataSource.h"
#import "PostCellModel.h"
#import "UsernameTimestampCell.h"
#import "LocationNameCell.h"
#import "ImageCell.h"
#import "LikeCell.h"
#import "CaptionCell.h"
#import "RatingCell.h"
#import "ProfileViewController.h"
#import "ComposeViewController.h"
#import "Post.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UsernameTimestampCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FeedDataSource *feedDataSource;
@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.feedDataSource = [[FeedDataSource alloc] init];
    
    // Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Get timeline
    [self loadPosts:20];
}

- (void) loadPosts: (int) numPosts {
    // Construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"liked"];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"image"];
    [postQuery includeKey:@"postID"];
    
    // Filter feed to include only posts by following users and current user
    PFUser *currentUser = [PFUser currentUser];
    [postQuery whereKey:@"author" containedIn:currentUser[@"following"]];
    postQuery.limit = numPosts;

    // Fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            // Pass posts to data source
            self.feedDataSource.arrayOfPosts = posts;
            
            [self.tableView reloadData];
        }
        else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}


- (IBAction)onTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // Logout failed
        if (error) {
            NSLog(@"User logout failed: %@", error.localizedDescription);
        
        // Successful logout, PFUser.current() will now be nil
        } else {
            NSLog(@"User logged out successfully!");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:loginIdentifier];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
}


// Makes a network request to get updated data to refresh the tableView
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self loadPosts:20];
    [refreshControl endRefreshing];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

// MARK: UITableViewDatasource

// Returns number of sections the table view should have (number of posts)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.feedDataSource numberOfSections];
}

// Returns number of rows in the section (number of components the post has)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedDataSource numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the model for current indexPath from FeedDataSource
    PostCellModel *model = [self.feedDataSource modelForIndexPath:indexPath];
    
    // Dequeue the cell with identifier based on model returned by FeedDataSource, load model into cell
    switch (model.type) {
        case PostCellModelTypeUsernameTimestamp: {
            UsernameTimestampCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usernameTimestampCell" forIndexPath:indexPath];
            cell.delegate = self;
            
            if ([model.data[0] isKindOfClass:[NSString class]] && [model.data[1] isKindOfClass:[NSString class]] && [model.post isKindOfClass:[Post class]]) {
                cell.usernameLabel.text = model.data[0];
                cell.timestampLabel.text = model.data[1];
                cell.post = model.post;
            }
            return cell;
        }
            
        case PostCellModelTypeLocation: {
            LocationNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
            if ([model.data isKindOfClass: [NSMutableAttributedString class]]) {
                cell.locationView.attributedText = model.data;
                cell.locationView.dataDetectorTypes = UIDataDetectorTypeLink;
                [cell.locationView setFont:[UIFont systemFontOfSize:19]];
            }
            return cell;
        }
        
        case PostCellModelTypeImage: {
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            if ([model.data isKindOfClass:[PFFileObject class]]) {
                cell.locationImage.file = model.data;
                [cell.locationImage loadInBackground];
            }
            return cell;
        }
            
        case PostCellModelTypeLikeCount: {
            LikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell" forIndexPath:indexPath];
            
            if ([model.post isKindOfClass:[Post class]] && [model.data isKindOfClass:[NSNumber class]]) {
                cell.post = model.post;
            
                // Set like count
                NSString *likeCount = [NSString stringWithFormat:@"%@", model.data];
//            [cell.likeButton setTitle:likeCount forState:UIControlStateNormal];
            
                // Set selected state for like button if current user has already liked the post
                PFUser *currentUser = [PFUser currentUser];
                Post *currentPost = model.post;
                NSArray *liked = currentUser[@"liked"];
            
                // TODO: fix, containsObject does not return true when the user already liked the current post
                if ([liked containsObject:currentPost.objectId]) {
                    [cell.likeButton setSelected:YES];
                    [cell.likeButton setTitle:likeCount forState:UIControlStateSelected];
                } else {
                    [cell.likeButton setTitle:likeCount forState:UIControlStateNormal];
                }
            }
            return cell;
        }
            
        case PostCellModelTypeCaption: {
            CaptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"captionCell" forIndexPath:indexPath];
            if ([model.data isKindOfClass:[NSString class]]) {
                cell.captionLabel.text = model.data;
            }
            return cell;
        }
            
        case PostCellModelTypeRating: {
            RatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell" forIndexPath:indexPath];
            if ([model.data isKindOfClass:[NSNumber class]]) {
                cell.ratingView.value = [model.data doubleValue];
            }
            return cell;
        }
    }
}


// MARK: UITableViewDelegate

// For separator between sections (posts)
// TODO: fix UI of separator (too thick)
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect sepFrame = CGRectMake(0, tableView.frame.size.height, self.view.bounds.size.width, 1);
    UIView *separatorView =[[UIView alloc] initWithFrame:sepFrame];
    separatorView.backgroundColor = tableView.separatorColor;
    return separatorView;
}

// //For infinite scrolling
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section + 1 == [self.feedDataSource.arrayOfPosts count]){
//        [self loadPosts:(int)[self.feedDataSource.arrayOfPosts count] + 20];
//    }
//}


// MARK: UsernameTimestampCellDelegate
-(void)usernameTimestampCell:(UsernameTimestampCell *) usernameTimestampCell didTap: (PFUser *)user {
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Segue from username label to profile page
    if ([[segue identifier] isEqualToString:@"profileSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = sender;
    }
    
    // Segue from Check In button to compose page
    if ([[segue identifier] isEqualToString:@"composeSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        ComposeViewController *composeController = navController.topViewController;
        composeController.modalInPresentation = YES;
    }
}


@end
