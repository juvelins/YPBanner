//
//  ViewController.m
//  YPBannerDemo
//
//  Created by yupao on 12/25/15.
//  Copyright © 2015 yupao. All rights reserved.
//

#import "ViewController.h"
#import "YPBannerView.h"
#import "Masonry.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) YPBannerView *bannerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _testView = [[UIView alloc] init];
    [self.view addSubview:_testView];
}

- (void)initBannerView {
    YPBannerItem *item_01 = [[YPBannerItem alloc] initWithImage:[UIImage imageNamed:@"placehold.png"] data:nil];
    YPBannerItem *item_02 = [[YPBannerItem alloc] initWithUrl:@"http://img2.3lian.com/img2007/19/33/005.jpg" data:nil andPlaceholder:[UIImage imageNamed:@"placehold.png"]];
    YPBannerItem *item_03 = [[YPBannerItem alloc] initWithUrl:@"http://pic2.ooopic.com/01/03/51/25b1OOOPIC19.jpg" data:nil andPlaceholder:[UIImage imageNamed:@"placehold.png"]];
    //不设置动画，使用默认动画
//    _bannerView = [[YPBannerView alloc] initWithFrame:_testView.bounds andYPBannerItems:@[item_01,item_02,item_03]];
    //设置动画
    _bannerView= [[YPBannerView alloc] initWithFrame:_testView.bounds YPBannerItems:@[item_01,item_02,item_03] animationType:YPBannerAnimationTypeCube andTimeDuration:1.5f];
       [_bannerView setChangePageContrwithimgCurrentimg:@"placehold" andimgOtherimg:@"002"];
    //
    [_testView addSubview:_bannerView];
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bannerView);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_testView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.center.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.5);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initBannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
