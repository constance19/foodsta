//
//  LocationsViewController.h
//  foodsta
//
//  Created by constanceh on 7/12/21.
//

#import <UIKit/UIKit.h>

@interface LocationsViewController : UIViewController

extern NSString *locationsIdentifier;

@property (nonatomic) double ratingValue;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *postImage;

@end

