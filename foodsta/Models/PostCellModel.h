//
//  PostCellModel.h
//  foodsta
//
//  Created by constanceh on 7/15/21.
//

#import <Foundation/Foundation.h>

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

@property PostCellModelType type;
@property id data; // string, image, int, etc.

@end


NS_ASSUME_NONNULL_END
