//
//  FeedDataSource.h
//  foodsta
//
//  Created by constanceh on 7/15/21.
//

#import <Foundation/Foundation.h>
#import "PostCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeedDataSource : NSObject

@property (nonatomic, strong) NSArray *arrayOfPosts; // property that take posts response (array of posts)
- (NSInteger) numberOfSections; // method that returns the number of sections (posts) for the feed
- (NSInteger) numberOfRowsInSection:(NSInteger)section; //  method that returns the number of rows for a section (parameter)
- (PostCellModel*) modelForIndexPath:(NSIndexPath *)indexPath; // method that returns a PostCellModel, pass in index path as parameter
    // containing username/timestamp, location, image, like count, caption, rating of a section


@end

NS_ASSUME_NONNULL_END
