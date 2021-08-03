//
//  ContainerFeedViewController.m
//  foodsta
//
//  Created by constanceh on 7/26/21.
//

#import "ContainerFeedViewController.h"
#import "ContainerTabController.h"
#import "FeedDataSource.h"
#import "UsernameTimestampCell.h"
#import "LocationNameCell.h"
#import "RatingCell.h"
#import "ImageCell.h"
#import "LikeCell.h"
#import "CaptionCell.h"
@import Parse;

@interface ContainerFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *likeDictionary;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ContainerFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the user passed from the profile page
    ContainerTabController *tabController = self.tabBarController;
    self.user = tabController.user;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.feedDataSource = [[FeedDataSource alloc] init];
    
    // Fetch posts by current profile's user
    [self loadPosts];
    
    // Initialize dictionary storing like cells
    self.likeDictionary = [[NSMutableDictionary alloc] init];
    
    // Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
}

- (void) loadPosts {
    // Construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"liked"];
    [postQuery includeKey:@"locationTitle"];
    [postQuery includeKey:@"image"];
    
    PFUser *profileUser = self.user;
    if (profileUser != nil) {
        [postQuery whereKey:@"author" equalTo:profileUser];
    }

    // Fetch data asynchronously
    typeof(self) __weak weakSelf = self;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;  // strong by default
            if (strongSelf) {
                if (posts) {
                    // Pass posts to data source
                    strongSelf.feedDataSource.arrayOfPosts = posts;
                    
                    [strongSelf.tableView reloadData];
                }
                else {
                    NSLog(@"😫😫😫 Error getting profile timeline: %@", error.localizedDescription);
                }
            }
    }];
}

// Makes a network request to get updated data to refresh the tableView
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self loadPosts];
    [refreshControl endRefreshing];
}


// MARK: UITableViewDataSource

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
            
            // Set username and timestamp labels
            if ([model.data[0] isKindOfClass:[NSString class]] && [model.data[1] isKindOfClass:[NSString class]] && [model.post isKindOfClass:[Post class]]) {
                cell.containerUsernameLabel.text = model.data[0];
                cell.containerTimestampLabel.text = model.data[1];
                cell.post = model.post;
            }
            return cell;
        }
            
        case PostCellModelTypeLocation: {
            LocationNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
            
            // Set location view text that links to Yelp webpage
            if ([model.data isKindOfClass: [NSMutableAttributedString class]]) {
                cell.containerLocationView.attributedText = model.data;
                cell.containerLocationView.dataDetectorTypes = UIDataDetectorTypeLink;
                [cell.containerLocationView setFont:[UIFont systemFontOfSize:19 weight:UIFontWeightLight]];
            }
            return cell;
        }
        
        case PostCellModelTypeImage: {
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            
            // Convert file to image and set it to the image view
            if ([model.data isKindOfClass:[PFFileObject class]] && [model.post isKindOfClass: [Post class]]) {
                cell.post = model.post;
                
                PFFileObject *imageFile = model.data;
                if (imageFile) {
                    NSURL *url = [NSURL URLWithString: imageFile.url];
                    NSData *fileData = [NSData dataWithContentsOfURL: url];
                    UIImage *photo = [[UIImage alloc] initWithData:fileData];
                    cell.containerLocationImage.image = photo;
                }
            }
            
            // Get the index path for the Like Cell below
            NSInteger likeSection = indexPath.section;
            NSInteger likeRow = indexPath.row + 1;
            NSIndexPath *likeIndexPath = [NSIndexPath indexPathForRow:likeRow inSection:likeSection];
            
            // Dequeue Like Cell, store it in the dictionary, and set it as the Image Cell's delegate
            LikeCell *likeCell = [tableView dequeueReusableCellWithIdentifier:@"likeCell" forIndexPath:likeIndexPath];
            NSString *key = [@(likeSection) stringValue];
            [self.likeDictionary setObject:likeCell forKey:key];
            cell.delegate = likeCell;
            
            return cell;
        }
            
        case PostCellModelTypeLikeCount: {
            NSString *likeKey = [@(indexPath.section) stringValue];
            LikeCell *cell;
            
            // If post has an image, the Like Cell has already been dequeued and stored in the dictionary
            if ([self.likeDictionary objectForKey:likeKey]) {
                cell = [self.likeDictionary objectForKey:likeKey];
                [self.likeDictionary removeObjectForKey:likeKey];
            
            // If post does not has an image, need to dequeue the Like Cell
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell" forIndexPath:indexPath];
            }
            
            [cell.containerLikeButton setSelected:NO];
            
            // Set selected state for like button if current user has already liked the post
            if ([model.post isKindOfClass:[Post class]] && [model.data isKindOfClass:[NSNumber class]]) {
                cell.post = model.post;
            
                // Set like count for like button
                PFUser *currentUser = [PFUser currentUser];
                Post *currentPost = model.post;
                NSArray *liked = currentUser[@"liked"];
                NSString *likeCount = [@" " stringByAppendingString: [NSString stringWithFormat:@"%@", model.data]];
            
                // Set selected state for like button
                if ([liked containsObject:currentPost.objectId]) {
                    [cell.containerLikeButton setSelected:YES];
                    [cell.containerLikeButton setTitle:likeCount forState:UIControlStateSelected];
                } else {
                    [cell.containerLikeButton setTitle:likeCount forState:UIControlStateNormal];
                }
            }
            return cell;
        }
            
        case PostCellModelTypeCaption: {
            CaptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"captionCell" forIndexPath:indexPath];
            
            // Set caption label
            if ([model.data isKindOfClass:[NSString class]]) {
                cell.containerCaptionLabel.text = model.data;
            }
            return cell;
        }
            
        case PostCellModelTypeRating: {
            RatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell" forIndexPath:indexPath];
            
            // Set rating
            if ([model.data isKindOfClass:[NSNumber class]]) {
                cell.containerRatingView.value = [model.data doubleValue];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
