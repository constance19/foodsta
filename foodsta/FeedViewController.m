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
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Get timeline
    [self loadPosts:20];
}

- (IBAction)onTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        
        // Logout failed
        if (error) {
            NSLog(@"User logout failed: %@", error.localizedDescription);
        
        // Successful logout
        } else {
            NSLog(@"User logged out successfully!");
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window.rootViewController = loginViewController;
        }
    }];
}

- (void) loadPosts: (int) numPosts {
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"liked"];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"image"];
    postQuery.limit = numPosts;

    // fetch data asynchronously
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];

    // Get and set the post
    Post *post = self.arrayOfPosts[indexPath.row];
    cell.post = post;
    
    // Set the location
//    cell.locationLabel.text = post.locationTitle;
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
//    cell.imageView.file = post.image;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

// Makes a network request to get updated data
// Updates the tableView with the new data
// Hides the RefreshControl
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self loadPosts:20];
    [refreshControl endRefreshing];
}

// For infinite scrolling
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.arrayOfPosts count]){
        [self loadPosts: (int)[self.arrayOfPosts count]+20];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"locationDetailSegue"]) {
        UILabel *tappedLabel = sender;
        LocationDetailsViewController *locationController = [segue destinationViewController];
        // how to access the PostCell that the tapped label is in? need to get the PostCell.post.locationUrl property to pass through segue
//        locationController.yelpUrl = tappedLabel.tag;
    }
}


@end
