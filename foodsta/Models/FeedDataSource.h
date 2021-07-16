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

@property (nonatomic, strong) NSArray *arrayOfPosts; // posts response from FeedViewController
- (NSInteger) numberOfSections;
- (NSInteger) numberOfRowsInSection:(NSInteger)section;
- (PostCellModel*) modelForIndexPath:(NSIndexPath *)indexPath; // returns username/timestamp, location, rating, image, like count, or caption depending on the input index path


@end

NS_ASSUME_NONNULL_END
