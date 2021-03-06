//
//  YPBannerView.m
//  YPBannerDemo
//
//  Created by yupao on 1/8/16.
//  Copyright © 2016 yupao. All rights reserved.
//

#import "YPBannerView.h"
#define VIEW_WIDTH self.bounds.size.width
#define VIEW_HEIGHT self.bounds.size.height
#define LEFT_IMAGE_ORGIN CGPointMake(VIEW_WIDTH*0, 0)
#define CENTER_IMAGE_ORGIN CGPointMake(VIEW_WIDTH*1, 0)
#define RIGHT_IMAGE_ORGIN CGPointMake(VIEW_WIDTH*2, 0)
#define TIMERINTERVAL 5.0f

@interface YPBannerView(){
    NSArray *animationTypeArray;
}
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *bannerView;
@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, assign) NSInteger centerImageIndex;
@property (nonatomic, strong) YPBannerManager *bannerManager;
@property (nonatomic, strong) NSTimer *bannerTimer;
@property (nonatomic, strong) CATransition *bannerAnimation;
@end
@implementation YPBannerView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        animationTypeArray = @[kCATransitionFade,kCATransitionMoveIn,kCATransitionPush,kCATransitionReveal  //公开动画
                               ,@"cube",@"oglFlip",@"suckEffect",@"rippleEffect",@"pageCurl",@"pageUnCurl"  //私有动画
                               ];
        [self initBannerView];
        [self initGestureView];
        [self initPageControl];
        [self initBannerTimer];
        _bannerManager = [YPBannerManager sharedYPBannerManager];
        [_bannerManager setDelegate:(id<YPBannerManagerDelegate> _Nullable)self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
             andYPBannerItems:(NSArray<YPBannerItem *> *)itemArray {
    self = [self initWithFrame:frame];
    if (self) {
        [_bannerManager addItems:(NSArray<YPBannerItem *> *)itemArray];
        _centerImageIndex = 0;
        _bannerAnimation = [self createDefaultAnimation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                YPBannerItems:(NSArray<YPBannerItem *> *)itemArray
                animationType:(YPBannerAnimationType)type
              andTimeDuration:(NSTimeInterval)duration {
    self = [self initWithFrame:(CGRect)frame andYPBannerItems:itemArray];
    if (self) {
        _bannerAnimation = [self createAnimationByType:type
                                        beginDirection:kCATransitionFromLeft
                                        timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                       andTimeDuration:duration
                            ];
    }
    return self;
}
#pragma mark - subview init methods
- (void)initBannerView {
    _bannerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
    [_bannerView setBounces:NO];
    [_bannerView setShowsHorizontalScrollIndicator:NO];
    [_bannerView setShowsVerticalScrollIndicator:NO];
    [_bannerView setPagingEnabled:YES];
    [_bannerView setContentOffset:CENTER_IMAGE_ORGIN];
    [_bannerView setContentSize:CGSizeMake(VIEW_WIDTH*3.0f, VIEW_HEIGHT)];
    [_bannerView setDelegate:(id<UIScrollViewDelegate> _Nullable)self];
    [_bannerView setOpaque:YES];
    [self addSubview:_bannerView];
    [self bringSubviewToFront:_bannerView];
    
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_IMAGE_ORGIN.x, LEFT_IMAGE_ORGIN.y, VIEW_WIDTH   , VIEW_HEIGHT)];
    _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CENTER_IMAGE_ORGIN.x, CENTER_IMAGE_ORGIN.y, VIEW_WIDTH   , VIEW_HEIGHT)];
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(RIGHT_IMAGE_ORGIN.x, RIGHT_IMAGE_ORGIN.y, VIEW_WIDTH   , VIEW_HEIGHT)];
    [_bannerView addSubview:_leftImageView];
    [_bannerView addSubview:_centerImageView];
    [_bannerView addSubview:_rightImageView];
}

- (void)initGestureView {
    _gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
    [_gestureView setUserInteractionEnabled:YES];
    [_gestureView setBackgroundColor:[UIColor clearColor]];
    [_gestureView setOpaque:NO];
    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeOnBanner:)];
    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeOnBanner:)];
    [_leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [_gestureView addGestureRecognizer:_leftSwipe];
    [_gestureView addGestureRecognizer:_rightSwipe];

    [self addSubview:_gestureView];
    [self bringSubviewToFront:_gestureView];
}

- (void)initPageControl {
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(VIEW_WIDTH/2.0f-20, VIEW_HEIGHT-20.f, 40, 20)];
    [_pageControl setNumberOfPages:[_bannerManager countOfItems]];
    [self addSubview:_pageControl];
    [self bringSubviewToFront:_pageControl];
}

#pragma mark - NSTimer related
- (void)initBannerTimer {
    _bannerTimer = [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL
                                                    target:self
                                                  selector:@selector(timeUp)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)pauseTimer {
    [_bannerTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    [_bannerTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:TIMERINTERVAL]];
}

- (void)timeUp {
    [self didSwipeOnBanner:_leftSwipe];
}

- (void)ajustImageIndex {
    NSInteger countOfItems = _bannerManager.countOfItems;
    NSInteger centerIndex= _centerImageIndex;
    NSInteger leftIndex= (centerIndex == 0)?((countOfItems-1)):(centerIndex-1);
    NSInteger rightIndex= (centerIndex == countOfItems-1)?(0):(centerIndex+1)%(countOfItems);
    _leftImageView.image = [_bannerManager itemAtIndex:leftIndex].itemImg;
    _centerImageView.image = [_bannerManager itemAtIndex:centerIndex].itemImg;
    _rightImageView.image = [_bannerManager itemAtIndex:rightIndex].itemImg;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self pauseTimer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resumeTimer];
}

#pragma mark - animation related
- (CATransition *)createAnimationByType:(YPBannerAnimationType)type
                         beginDirection:(NSString *)direction
                         timingFunction:(CAMediaTimingFunction *)function
                        andTimeDuration:(NSTimeInterval)duration {
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.subtype = direction;
    transition.timingFunction = function;
    transition.type = animationTypeArray[type];
    return transition;
}

- (CATransition *)createDefaultAnimation {
    CATransition * transition = [self createAnimationByType:YPBannerAnimationTypePush
                                             beginDirection:kCATransitionFromLeft
                                             timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                            andTimeDuration:0.7f];
    return transition;
}

#pragma mark - uiswipegesture
- (void)didSwipeOnBanner:(UISwipeGestureRecognizer *)reg {
    NSInteger countOfItems = _bannerManager.countOfItems;
    if (reg.direction == UISwipeGestureRecognizerDirectionLeft) {//scroll to right direction
        _centerImageIndex = (_centerImageIndex == countOfItems)? 0: (_centerImageIndex+1)%countOfItems;
        if (_bannerAnimation) {
            _bannerAnimation.subtype = kCATransitionFromRight;
            [self.layer addAnimation:_bannerAnimation forKey:nil];
        }
        [_bannerView setContentOffset:RIGHT_IMAGE_ORGIN animated:NO];
    }
    if (reg.direction == UISwipeGestureRecognizerDirectionRight) {//scroll to left direction
        _centerImageIndex = (_centerImageIndex == 0)?(countOfItems -1):(_centerImageIndex-1)%countOfItems;
        if (_bannerAnimation) {
            _bannerAnimation.subtype = kCATransitionFromLeft;
            [self.layer addAnimation:_bannerAnimation forKey:nil];
        }
        [_bannerView setContentOffset:LEFT_IMAGE_ORGIN animated:NO];
    }
    [self ajustImageIndex];
    _pageControl.currentPage = _centerImageIndex;
    [_bannerView setContentOffset:CENTER_IMAGE_ORGIN];
    [self resumeTimer];
}

#pragma mark -YPBannerManagerDelegate
- (void)YPBannerManager:(YPBannerManager *)manager addItem:(YPBannerItem *)item {
    [_pageControl setNumberOfPages:manager.countOfItems];
    _centerImageIndex = 0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
