//
//  Post.m
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import "Post.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic locationTitle;
@dynamic likeCount;
@dynamic commentCount;
@dynamic liked;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postCheckIn: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withLocation: (NSString * _Nullable)location withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.liked = 0;
    
    // add location somehow
    newPost.locationTitle = location;
    
    [newPost saveInBackgroundWithBlock: completion];
}


+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
