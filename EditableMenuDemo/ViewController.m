//
//  ViewController.m
//  EditableMenuDemo
//
//  Created by wdyzmx on 2021/12/2.
//

#import "ViewController.h"
#import "EditableMenuViewController.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.view addSubview:self.button];
    self.button.center = self.view.center;
    self.button.backgroundColor = UIColor.redColor;
    [self.button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.button setTitle:@"跳转" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}

- (void)buttonAction:(UIButton *)btn {
    EditableMenuViewController *viewController = [[EditableMenuViewController alloc] init];
//    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.params = @{
        @"selectedArray": @[@"关注",@"推荐", @"视频", @"家居", @"汽车", @"军事", @"美食"],
        @"unselectedArray": @[@"搞笑", @"热点", @"房产", @"科技", @"健康", @"财经", @"历史", @"小说"],
    };
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
