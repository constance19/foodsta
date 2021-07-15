//
//  LocationDetailsViewController.m
//  foodsta
//
//  Created by constanceh on 7/13/21.
//

#import "LocationDetailsViewController.h"
#import "WebKit/WebKit.h"

@interface LocationDetailsViewController ()

@property (weak, nonatomic) IBOutlet WKWebView *locationWebView;

@end

@implementation LocationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url=[NSURL URLWithString:self.yelpUrl];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.locationWebView loadRequest:request];
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
