//
//  EditableMenuViewController.m
//  EditableMenuDemo
//
//  Created by wdyzmx on 2021/12/2.
//

#import "EditableMenuViewController.h"
#import "EditableMenuCollectionViewCell.h"

@interface EditableMenuViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>
/// collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, assign) NSInteger startSection;
@property (nonatomic, assign) NSInteger endSection;
@property (nonatomic, assign) NSInteger startItem;
@property (nonatomic, assign) NSInteger endItem;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSMutableArray *unselectedArray;
@end

@implementation EditableMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:self.collectionView];
    
    self.startSection = 0;
    self.endSection = 0;
    self.startItem = 0;
    self.endItem = 0;
    self.selectedArray = [NSMutableArray arrayWithArray:self.params[@"selectedArray"]];
    self.unselectedArray = [NSMutableArray arrayWithArray:self.params[@"unselectedArray"]];
    // Do any additional setup after loading the view.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.selectedArray.count;
    } else {
        return self.unselectedArray.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditableMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([EditableMenuCollectionViewCell class]) forIndexPath:indexPath];
    [cell setCellWithSelectedArray:self.selectedArray unselectedArray:self.unselectedArray indexPath:indexPath];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"起点item section==%ld row==%ld", sourceIndexPath.section, sourceIndexPath.item);
    NSLog(@"终点item section==%ld row==%ld", destinationIndexPath.section, destinationIndexPath.item);
    self.startItem = sourceIndexPath.item;
    self.endItem = destinationIndexPath.item;
    // 更新数据
    [self updateDataSource];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (KScreenWidth - 10 * 6) / 5;
    return CGSizeMake(width, ItemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, ItemHeight);
}

#pragma mark - UICollectionViewDelegate 创建区头视图和区尾视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ItemHeight)];
        if (indexPath.section == 0) {
            label.text = @"    已选择的";
        } else {
            label.text = @"    未选择的";
        }
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSIndexPath *startIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:1];
        NSIndexPath *endIndexPath = [NSIndexPath indexPathForItem:self.selectedArray.count inSection:0];
        [self.selectedArray insertObject:self.unselectedArray[indexPath.item] atIndex:endIndexPath.item];
        [self.unselectedArray removeObjectAtIndex:indexPath.item];
        [self.collectionView moveItemAtIndexPath:startIndexPath toIndexPath:endIndexPath];
    } else {
        NSIndexPath *startIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
        NSIndexPath *endIndexPath = [NSIndexPath indexPathForItem:self.unselectedArray.count inSection:1];
        [self.unselectedArray insertObject:self.selectedArray[indexPath.item] atIndex:endIndexPath.item];
        [self.selectedArray removeObjectAtIndex:indexPath.item];
        [self.collectionView moveItemAtIndexPath:startIndexPath toIndexPath:endIndexPath];
    }
}

#pragma mark - 长按手势longPress
- (void)longPress:(UILongPressGestureRecognizer *)press {
    // 获取长按点point
    CGPoint point = [press locationInView:self.collectionView];
    // 获取手势所在的indexPath信息，从而获取indexPath.row indexPath.section
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (press.state == UIGestureRecognizerStateBegan) {
        self.startSection = indexPath.section;
        self.startItem = indexPath.item;
        // collectionView开始移动item
        [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        [self startShakeAnimationAtIndexPath:indexPath];
    } else if (press.state == UIGestureRecognizerStateChanged) {
        // collectionView正在移动item
        [self.collectionView updateInteractiveMovementTargetPosition:point];
    } else if (press.state == UIGestureRecognizerStateEnded) {
        self.endSection = indexPath.section;
        [self.collectionView endInteractiveMovement];
        [self endShakeAnimationAtIndexPath:indexPath];
    } else {
        [self.collectionView cancelInteractiveMovement];
        [self endShakeAnimationAtIndexPath:indexPath];
    }
}

- (void)startShakeAnimationAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numOfSections = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < numOfSections; i++) {
        NSInteger section = i;
        NSMutableArray *tmpArray = section == 0 ? self.selectedArray : self.unselectedArray;
        for (int i = 0; i < tmpArray.count; i++) {
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
            EditableMenuCollectionViewCell *tmpCell = (EditableMenuCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:tmpIndexPath];
            [tmpCell startShakeAnimationAtIndexPath:tmpIndexPath];
        }
    }
}

- (void)endShakeAnimationAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numOfSections = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < numOfSections; i++) {
        NSInteger section = i;
        NSMutableArray *tmpArray = section == 0 ? self.selectedArray : self.unselectedArray;
        for (int i = 0; i < tmpArray.count; i++) {
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
            EditableMenuCollectionViewCell *tmpCell = (EditableMenuCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:tmpIndexPath];
            [tmpCell endShakeAnimationAtIndexPath:tmpIndexPath];
        }
    }
}

#pragma mark - 更新数据源dataSource
- (void)updateDataSource {
    if (self.startSection == self.endSection) {
        // 同一section内部的编辑
        NSInteger numOfSections = [self.collectionView numberOfSections];
        for (NSInteger i = 0; i < numOfSections; i++) {
            if (self.startSection == i) {
                NSMutableArray *tmpArray = self.startSection == 0 ? self.selectedArray : self.unselectedArray;
                id obj = [tmpArray objectAtIndex:self.startItem];
                [tmpArray removeObjectAtIndex:self.startItem];
                [tmpArray insertObject:obj atIndex:self.endItem];
                
            }
        }
    } else {
        // 不同section内部的编辑
        NSInteger numOfSections = [self.collectionView numberOfSections];
        id obj = nil;
        for (NSInteger i = 0; i < numOfSections; i++) {
            if (self.startSection == i) {
                NSMutableArray *tmpArray = self.startSection == 0 ? self.selectedArray : self.unselectedArray;
                obj = [tmpArray objectAtIndex:self.startItem];
                [tmpArray removeObjectAtIndex:self.startItem];
            }
        }
        for (NSInteger i = 0; i < numOfSections; i++) {
            if (self.endSection == i) {
                NSMutableArray *tmpArray = self.endSection == 0 ? self.selectedArray : self.unselectedArray;
                [tmpArray insertObject:obj atIndex:self.endItem];
            }
        }
    }
//    for (NSString *str in self.selectedArray) {
//        NSLog(@"%@", str);
//    }
//    NSLog(@"=============================================");
//    for (NSString *str in self.unselectedArray) {
//        NSLog(@"%@", str);
//    }
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        [_collectionView registerClass:[EditableMenuCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([EditableMenuCollectionViewCell class])];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        // 添加长按手势
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_collectionView addGestureRecognizer:_longPress];
    }
    return _collectionView;
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
