//
//  Post.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;

@property (nonatomic, strong) NSNumber *liked;
@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong) NSString *locationUrl;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;


+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (void) postCheckIn: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withLocation: (NSString * _Nullable)location withUrl: (NSString * _Nullable)url withRating: (NSNumber * _Nullable)rating withLatitude: (NSNumber * _Nullable)latitude withLongitude: (NSNumber * _Nullable)longitude withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
