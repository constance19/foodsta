//
//  FeedDataSource.m
//  foodsta
//
//  Created by constanceh on 7/15/21.
//

#import "FeedDataSource.h"
#import "Post.h"
#import "DateTools.h"

@implementation FeedDataSource

// Returns number of sections (number of posts) for the feed table view
- (NSInteger) numberOfSections {
    return self.arrayOfPosts.count;
}

// Returns number of rows for the input section (number of components in the input post)
- (NSInteger) numberOfRowsInSection:(NSInteger)section {
    Post *post = self.arrayOfPosts[section];
    int count = 6;
    
    // Decrement number of rows if the post (section) does not have an image
    if ([post objectForKey:@"image"] == nil) {
        count--;
    }
    
    // Decrement number of rows if the post (section) does not have a caption
    if ([post[@"caption"] isEqualToString:@""]) {
        count--;
    }
    
    NSLog(@"%d", count);
    return count;
}

// Returns the model (post component) for the input index path
- (PostCellModel*) modelForIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    // Get the corresponding post using the section number
    Post *post = self.arrayOfPosts[section];
    PostCellModel *model = [[PostCellModel alloc] init];
    
    // Username and timestamp cell
    if (row == 0) {
        model.type = PostCellModelTypeUsernameTimestamp;
        
        PFUser *user = post[@"author"];
        NSString *username = [NSString stringWithFormat:@"@%@", user.username];
        
        // Format and set createdAtString, convert Date to String using DateTool relative time
        NSDate *createdAt = post.createdAt;
        NSString *timestamp = createdAt.shortTimeAgoSinceNow;
        
        NSArray *strings = [[NSArray alloc] initWithObjects:username, timestamp, nil];
        model.data = strings;
    }
    
    // Location cell
    if (row == 1) {
        model.type = PostCellModelTypeLocation;
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:post.locationTitle];
        [str addAttribute: NSLinkAttributeName value: post.locationUrl range: NSMakeRange(0, str.length)];
        model.data = str;
    }
    
    // Rating cell
    if (row == 2) {
        model.type = PostCellModelTypeRating;
        model.data = post.rating;
    }
    
    // Case: if post doesn't have an image
    if ([post objectForKey:@"image"] == nil) {
        // Like cell
        if (row == 3) {
            model.type = PostCellModelTypeLikeCount;
            model.data = post.likeCount;
        }
        
        // If post has a caption, also add caption cell
        if (![post[@"caption"] isEqualToString:@""]) {
            if (row == 4) {
                model.type = PostCellModelTypeCaption;
                model.data = post.caption;
            }
        }
        
    // Case: post has an image
    } else {
        // Image cell
        if (row == 3) {
            model.type = PostCellModelTypeImage;
            model.data = post.image;
        }
        
        // Like cell
        if (row == 4) {
            model.type = PostCellModelTypeLikeCount;
            model.data = post.likeCount;
        }
        
        // If post has a caption, also add caption cell
        if (![post[@"caption"] isEqualToString:@""]) {
            // Caption cell
            if (row == 5) {
                model.type = PostCellModelTypeCaption;
                model.data = post.caption;
            }
        }
    }
        
    return model;
}

@end
