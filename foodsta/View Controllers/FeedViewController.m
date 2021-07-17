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
#import "imageCell.h"
#import "likeCell.h"
#import "captionCell.h"
#import "ratingCell.h"
#import "ProfileViewController.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>
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
            cell.usernameLabel.text = model.data[0];
            cell.timestampLabel.text = model.data[1];
            return cell;
        }
            
        case PostCellModelTypeLocation: {
            LocationNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
            cell.locationView.attributedText = model.data;
            cell.locationView.dataDetectorTypes = UIDataDetectorTypeLink;
            [cell.locationView setFont:[UIFont systemFontOfSize:19]];
            return cell;
        }
        
        case PostCellModelTypeImage: {
            imageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            cell.locationImage.file = model.data;
            [cell.locationImage loadInBackground];
            return cell;
        }
            
        case PostCellModelTypeLikeCount: {
            likeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell" forIndexPath:indexPath];
            NSString *likeCount = [NSString stringWithFormat:@"%@", model.data];
            [cell.likeButton setTitle:likeCount forState:UIControlStateNormal];
            return cell;
        }
            
        case PostCellModelTypeCaption: {
            captionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"captionCell" forIndexPath:indexPath];
            cell.captionLabel.text = model.data;
            return cell;
        }
            
        case PostCellModelTypeRating: {
            ratingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell" forIndexPath:indexPath];
            cell.ratingView.value = [model.data doubleValue];
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

// For infinite scrolling
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row + 1 == [self.feedDataSource.arrayOfPosts count]){
        [self loadPosts: (int)[self.feedDataSource.arrayOfPosts count]+20];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"profileSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.feedDataSource.arrayOfPosts[indexPath.section];
                    
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileController = navController.topViewController;
        profileController.user = post[@"author"];
    }
}


@end
