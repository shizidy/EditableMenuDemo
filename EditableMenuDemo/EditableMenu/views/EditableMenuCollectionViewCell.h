//
//  EditableMenuCollectionViewCell.h
//  EditableMenuDemo
//
//  Created by wdyzmx on 2021/12/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditableMenuCollectionViewCell : UICollectionViewCell

- (void)setCellWithViewModel:(id)viewModel indexPath:(NSIndexPath *)indexPath;

- (void)setCellWithSelectedArray:(NSArray *)selectedArray unselectedArray:(NSArray *)unselectedArray indexPath:(NSIndexPath *)indexPath;

- (void)startShakeAnimationAtIndexPath:(NSIndexPath *)indexPath;
- (void)endShakeAnimationAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
