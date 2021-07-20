//
//  PostCellModel.h
//  foodsta
//
//  Created by constanceh on 7/15/21.
//

#import <Foundation/Foundation.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PostCellModelType) {
    PostCellModelTypeUsernameTimestamp,
    PostCellModelTypeLocation,
    PostCellModelTypeImage,
    PostCellModelTypeLikeCount,
    PostCellModelTypeCaption,
    PostCellModelTypeRating
};

@interface PostCellModel : NSObject

@property (nonatomic) PostCellModelType type;
@property (nonatomic, strong) id data; // string, image, int, etc.
@property (nonatomic, strong) Post *post;

@end


NS_ASSUME_NONNULL_END
