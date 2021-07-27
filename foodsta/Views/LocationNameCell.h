//
//  LocationNameCell.h
//  foodsta
//
//  Created by constanceh on 7/16/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *locationView;

@property (weak, nonatomic) IBOutlet UITextView *selfLocationView;

@property (weak, nonatomic) IBOutlet UITextView *containerLocationView;

@end

NS_ASSUME_NONNULL_END
