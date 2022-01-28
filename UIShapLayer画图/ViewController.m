//
//  ViewController.m
//  UIShapLayer画图
//
//  Created by 刘忠华 on 2022/1/28.
//

#import "ViewController.h"
#import "DashboardView.h"

///转换成角度
#define RADIANS_TO_DEGREES(x) ((x)/M_PI*180.0)
#define DEGREES_TO_RADIANS(x) ((x)/180.0*M_PI)
@interface ViewController ()
 /**仪表盘view*/
@property (nonatomic, strong) DashboardView *dashboardView;
/**电量**/
@property (nonatomic, assign) NSInteger batteryValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.dashboardView];
    self.batteryValue = 50;
    [self updateBatteryValue];
}

-(void)updateBatteryValue{
    CGFloat angle = ((CGFloat)self.batteryValue/100 - 0.5) * DEGREES_TO_RADIANS(270);
    //指针转动角度
    self.dashboardView.pointerView.transform = CGAffineTransformMakeRotation(angle);
    self.dashboardView.infoLabel.text = [NSString stringWithFormat:@"%ld%%",self.batteryValue];
    self.dashboardView.currentScore = self.batteryValue;
}

- (DashboardView *)dashboardView {
    if (!_dashboardView) {
        CGFloat baseViewWidth = 220;
        CGFloat baseViewHeight = baseViewWidth;
        CGFloat baseViewX = (self.view.frame.size.width - baseViewWidth)/2;
        CGFloat baseViewY = 100;
        _dashboardView = [[DashboardView alloc] initWithFrame:CGRectMake(baseViewX, baseViewY, baseViewWidth, baseViewHeight)];
        _dashboardView.backgroundColor = [UIColor blackColor];
    }
    return _dashboardView;
}

@end
