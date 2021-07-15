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

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *arrayOfPosts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
    postQuery.limit = numPosts;

    // Fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            // do something with the data fetched
            self.arrayOfPosts = posts;
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
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
}


// Makes a network request to get updated data to refresh the tableView
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self loadPosts:20];
    [refreshControl endRefreshing];
}

// MARK: UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    // Get and set the post
    Post *post = self.arrayOfPosts[indexPath.row];
    cell.post = post;
    
    // Reset image view so cell doesn't display a previously posted image
    cell.locationImage.image = nil;
    
    // Load in post image if present
    if ([post objectForKey:@"image"]) {
        cell.locationImage.file = post[@"image"];
        [cell.locationImage loadInBackground];
    }

    // TODO: Hide image view if user didn't attach an image for the post or make image required
//    if ([post objectForKey:@"image"] == nil) {
//        cell.locationImage.hidden = YES;
//    }
    
    // Set the location
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:post.locationTitle];
    [str addAttribute: NSLinkAttributeName value: post.locationUrl range: NSMakeRange(0, str.length)];
    cell.locationView.attributedText = str;
    cell.locationView.dataDetectorTypes = UIDataDetectorTypeLink;
    [cell.locationView setFont:[UIFont systemFontOfSize:19]];
        
    // Set the caption
    cell.captionLabel.text = post.caption;
    
    // Format and set createdAtString, convert Date to String using DateTool relative time
    NSDate *createdAt = post.createdAt;
    cell.timestampLabel.text = createdAt.shortTimeAgoSinceNow;
    
    // Set like count
    NSString *likeCount = [NSString stringWithFormat:@"%@", post.likeCount];
    [cell.likeButton setTitle:likeCount forState:UIControlStateNormal];
    
    // Set rating view
    cell.ratingView.value = [post.rating doubleValue];

    PFUser *user = post[@"author"];
    if (user != nil) {
        // User found! update username label with username
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
        
    } else {
        // No user found, set default username
        cell.usernameLabel.text = @"@Default_Name";
    }
    return cell;
}


// MARK: UITableViewDelegate

// For infinite scrolling
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfPosts count]){
        [self loadPosts: (int)[self.arrayOfPosts count]+20];
    }
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
