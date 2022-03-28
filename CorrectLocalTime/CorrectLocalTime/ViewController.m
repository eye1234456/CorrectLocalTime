//
//  ViewController.m
//  CorrectLocalTime
//
//  Created by Flow on 3/28/22.
//

#import "ViewController.h"
#import "RequestTool.h"
#import "NSDate+Diff.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nowDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *diffNowDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *diffDistanceLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNow];
}
- (IBAction)requestClick:(id)sender {
    [RequestTool requestWithPostUrl:@"https://www.jianshu.com/asimov/pdd_ads/ad" parameters:@{}];
}

- (IBAction)showDateClick:(id)sender {
    [self showNow];
}

- (void)showNow {
    self.nowDateLabel.text = [NSString stringWithFormat:@"本机时间：%@",NSDate.date];
    self.diffNowDateLabel.text = [NSString stringWithFormat:@"校对后的本机时间：%@",NSDate.diff_now];
    self.diffDistanceLabel.text = [NSString stringWithFormat:@"服务器与本机时间差：%@（单位秒）",NSDate.diff_get_distanceStr];
}
@end
