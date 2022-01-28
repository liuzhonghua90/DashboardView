//
//  DashboardView.m
//  DashboardDemo
//
//  Created by AXAET_APPLE on 17/1/6.
//  Copyright © 2017年 axaet. All rights reserved.
//

#import "DashboardView.h"

static CGFloat kDefaultRingWidth = 5;
static CGFloat kDefaultDialLength = 10;
static CGFloat kDefaultDialPieceCount = 15;

@interface DashboardView()

{
    CGPoint _center; // 中心点
    CGFloat _radius; // 外环半径
    NSInteger _dialCount; // 刻度线的个数
    
}
///电量背景图
@property (nonatomic, strong) UIImageView *paoImgView;
///当前电量
@property (nonatomic, strong) UILabel *titleLabel;
///当前刻度数组
@property (nonatomic, strong) NSMutableArray *currentDials;

@end

@implementation DashboardView

- (CGFloat)ringWidth {
    return _ringWidth ? _ringWidth : kDefaultRingWidth;
}

- (CGFloat)dialLength {
    return _dialLength ? _dialLength : kDefaultDialLength;
}

- (NSInteger)dialPieceCount {
    return _dialPieceCount ? _dialPieceCount : kDefaultDialPieceCount;
}

///set方法更新电量（由于要给刻度对象CAShapeLayer设置当前进度颜色，所以在此我用一个数组临时存放起来）
-(void)setCurrentScore:(NSInteger)currentScore {
    _currentScore = currentScore;
    for (int i = 0; i< self.currentDials.count; i++) {
        CAShapeLayer *dialItemLayer = self.currentDials[i];
        if (i<=currentScore*60/100) {//60/100因为最大值是100，但是所有刻度只有60个，因此需按比例来计算
            //设置当前刻度颜色
            dialItemLayer.strokeColor = [UIColor cyanColor].CGColor;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _radius = self.bounds.size.width / 2 - self.ringWidth / 2;
    _dialCount = 4 * self.dialPieceCount;
    
    // 添加外环
    [self addCircleLayer];
    [self addSubview:self.pointerView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.paoImgView];
    [self addSubview:self.infoLabel];

    return self;
}

/**
 大致思路：
 在页面上绘制CALayer，这个CALayer上由两部分组层，一个外环CAShapeLayer，另一个刻度环CAShapeLayer,绘制完成后添加到CALayer上，最后将CALayer再添加到self.layer上
 1.绘制外环CAShapeLayer(带有渐变色)
 1.1先绘制一个普通的CAShapeLayer
 a.绘制CAShapeLayer需要通过UIBezierPath来实现路径（点和线）的连接，具体参数：中心点、半径、起点、终点、顺时针
 b.path设置好后，将其赋值给CAShapeLayer属性path，由此一个图形就出来了
 1.2在普通的CAShapeLayer上实现渐变色
 a.也是需要再创建一个CALayer，然后在其基础上创建两个CAGradientLayer来实现渐变色，设置其属性渐变颜色，
 b.之后将两个创建好的CAGradientLayer添加在CALayer上
 c.最后CALayer再添加到self.layer上
 2.刻度环CAShapeLayer
 2.1创建CAShapeLayer刻度，添加到最开始的CALayer上
 2.2利用UIBezierPath将起来的线在CAShapeLayer串联
 
 3.绘制文字
 3.通过CGContextRef执行上下文，将所有点通过drawReact方法显示出来
 总体来说还是有些复杂，具体看代码
 **/

- (void)addCircleLayer {
    CGFloat startAngle = M_PI_2 + (M_PI / 4); // 开始角度
    CGFloat endAngle = M_PI * 2 + (M_PI / 4); // 结束角度
    BOOL clockwise = YES; // 顺时针

    CALayer *containerLayer = [CALayer layer];

    // 环形Layer层
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = self.ringWidth;
    circleLayer.lineCap = kCALineCapRound;
    circleLayer.lineJoin = kCALineJoinRound;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    circleLayer.shadowColor = [UIColor yellowColor].CGColor; // 阴影颜色
    circleLayer.shadowOffset = CGSizeMake(1, 1); // 阴影偏移量
    circleLayer.shadowOpacity = 0.5; // 阴影透明度
    circleLayer.shadowRadius = 5;
    
    // path
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:_center radius:_radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    circleLayer.path = circlePath.CGPath;

    [containerLayer addSublayer:circleLayer];
    [self.currentDials removeAllObjects];
    for (int i = 0; i <= _dialCount; i++) {
        [self containerLayer:containerLayer addDialWithIndex:i]; // 添加刻度
    }
    [self.layer addSublayer:containerLayer];

    // 渐变层
    CALayer *gradientLayer = [CALayer new];// 渐变层的组合

    // 生成左边渐变色
    CAGradientLayer *leftLayer = [CAGradientLayer layer];
    leftLayer.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
    leftLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor redColor].CGColor];
    [gradientLayer addSublayer:leftLayer];
    // 生成右边渐变色
    CAGradientLayer *rightLayer = [CAGradientLayer layer];
    rightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    rightLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor cyanColor].CGColor];
    [gradientLayer addSublayer:rightLayer];
    // 添加遮罩层
    [gradientLayer setMask:circleLayer];
    
    [self.layer addSublayer:gradientLayer];
}

- (void)containerLayer:(CALayer *)containerLayer addDialWithIndex:(NSInteger)index {
    CAShapeLayer *dialItemLayer = [CAShapeLayer layer]; // 刻度层
    dialItemLayer.lineWidth = 4;
    dialItemLayer.lineCap = kCALineCapSquare;
    dialItemLayer.lineJoin = kCALineJoinRound;
    dialItemLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    dialItemLayer.fillColor = [UIColor clearColor].CGColor;

    // path
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat outsideRadius = _radius - self.ringWidth / 2 - 10; // 刻度 外点半径
    CGFloat insideRadius = outsideRadius - self.dialLength + 5; // 刻度 内点半径

    if (index % self.dialPieceCount == 0) {
        insideRadius -= 5;
    }
    //存储所有的刻度
    [self.currentDials addObject:dialItemLayer];
    
    CGFloat angle = M_PI_2 + M_PI / 4 - index * (M_PI_2 + M_PI/4) *2 / _dialCount;// 角度
    CGPoint insidePoint = CGPointMake(_center.x - (insideRadius * sin(angle)), _center.y - (insideRadius * cos(angle)));// 刻度内点
    CGPoint outsidePoint = CGPointMake(_center.x - (outsideRadius * sin(angle)), _center.y - (outsideRadius * cos(angle)));// 刻度外点

    [path moveToPoint:insidePoint];
    [path addLineToPoint:outsidePoint];
    
    dialItemLayer.path = path.CGPath;
    [containerLayer addSublayer:dialItemLayer];
}

// 绘制文字
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 0.5);
    UIFont *font = [UIFont boldSystemFontOfSize:9.0];
    UIColor *foregroundColor = [UIColor whiteColor];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: foregroundColor};

    CGFloat outsideRadius = _radius - self.ringWidth/2 - 10;// 刻度外点半径
    CGFloat insideRadius = outsideRadius - self.dialLength; // 刻度内点半径

    // 需要显示的文字数组
    NSArray *textArr = @[@"0", @"25", @"50", @"75", @"100"];
    // 计算所得各个文字显示的位置相对于其insidePoint的偏移量,
    NSArray *xOffsetArr = @[@(5), @(5), @(80), @(140), @(100)];
    NSArray *yOffsetArr = @[@(-15), @(-70), @(-80), @(0), @(110)];

    for (int i = 0; i < textArr.count; i++) {
        CGFloat angle =  M_PI_2 + M_PI / 4 - 5 * i * (M_PI_2 + M_PI/4) *2 / _dialCount;
        CGPoint insidePoint = CGPointMake(_center.x - (insideRadius * sin(angle)), _center.y - (insideRadius * cos(angle)));
        CGFloat xOffset = [xOffsetArr[i] floatValue];
        CGFloat yOffset = [yOffsetArr[i] floatValue];
        CGRect rect = CGRectMake(insidePoint.x + xOffset, insidePoint.y + yOffset, 60, 20);
        NSString *text = textArr[i];
        [text drawInRect:rect withAttributes:attributes];
    }
}


#pragma mark - PointerView
- (UIImageView *)pointerView {
    if (!_pointerView) {
        _pointerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needle.png"]];
        _pointerView.frame =  CGRectMake(_center.x - 10, _center.y - self.bounds.size.width/5, 20, self.bounds.size.width/3);
        _pointerView.contentMode = UIViewContentModeScaleAspectFill;
        _pointerView.layer.anchorPoint = CGPointMake(0.5f, 0.8f); // 锚点
        _pointerView.transform = CGAffineTransformMakeRotation(-(M_PI/2 + M_PI_4));
    }
    return _pointerView;
}

#pragma mark - InfoLabe;
- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_center.x - 50, _center.y + 65, 100, 30)];
        _infoLabel.font = [UIFont boldSystemFontOfSize:17];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.text = @"0";
    }
    return _infoLabel;
}


#pragma mark - InfoLabe;
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_center.x - 50, _center.y + 35, 100, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"可用电量";
    }
    return _titleLabel;
}

- (UIImageView *)paoImgView {
    if (!_paoImgView) {
        _paoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_center.x - 32, _center.y + 60, 68, 32)];
        _paoImgView.image = [UIImage imageNamed:@"charge_pao"];
    }
    return _paoImgView;
}

-(NSMutableArray *)currentDials {
    if (!_currentDials) {
        _currentDials = [[NSMutableArray alloc] init];
    }
    return _currentDials;
}

@end
