//
//  EditableMenuCollectionViewCell.m
//  EditableMenuDemo
//
//  Created by wdyzmx on 2021/12/2.
//

#import "EditableMenuCollectionViewCell.h"
#import "EditableMenuDefine.h"

@interface EditableMenuCollectionViewCell ()
/// label
@property (nonatomic, strong) UILabel *label;
@end

@implementation EditableMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setSubviews];
        [self setSubviewsConstraints];
    }
    return self;
}

- (void)setSubviews {
    CGFloat width = (KScreenWidth - 10 * 6) / 5;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    self.label.backgroundColor = [UIColor orangeColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.textColor = [UIColor whiteColor];
    self.label.userInteractionEnabled = YES;
    [self.contentView addSubview:self.label];
}

- (void)setSubviewsConstraints {
    
}

- (void)setCellWithViewModel:(id)viewModel indexPath:(NSIndexPath *)indexPath {
    
}

- (void)setCellWithSelectedArray:(NSArray *)selectedArray unselectedArray:(NSArray *)unselectedArray indexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.label.text = selectedArray[indexPath.item];
    } else {
        self.label.text = unselectedArray[indexPath.item];
    }
}

- (void)startShakeAnimationAtIndexPath:(NSIndexPath *)indexPath {
    [self startShakeAnimationWithView:self.contentView indexPath:indexPath];
}

- (void)endShakeAnimationAtIndexPath:(NSIndexPath *)indexPath {
    [self endShakeAnimationWithView:self.contentView indexPath:indexPath];
}

- (void)startShakeAnimationWithView:(UIView *)view indexPath:(NSIndexPath *)indexPath {
    // 关键帧动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = .5;
    animation.repeatCount = MAXFLOAT;
    if (indexPath.item % 2 == 0) {
        animation.values = @[[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:-M_PI / 180 * 4], [NSNumber numberWithDouble:0], [NSNumber numberWithDouble:M_PI / 180 * 4], [NSNumber numberWithDouble:0]];
    } else {
        animation.values = @[[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:M_PI / 180 * 4], [NSNumber numberWithDouble:0], [NSNumber numberWithDouble:-M_PI / 180 * 4], [NSNumber numberWithDouble:0]];
    }
    [view.layer addAnimation:animation forKey:@"animationShake"];
}

- (void)endShakeAnimationWithView:(UIView *)view indexPath:(NSIndexPath *)indexPath {
    [view.layer removeAnimationForKey:@"animationShake"];
}

@end
