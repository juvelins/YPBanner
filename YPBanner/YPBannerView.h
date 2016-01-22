//
//  YPBannerView.h
//  YPBannerDemo
//
//  Created by yupao on 1/8/16.
//  Copyright © 2016 yupao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBannerManager.h"
typedef NS_OPTIONS(NSInteger, YPBannerAnimationType) {
    YPBannerAnimationTypeFade = 0,
    YPBannerAnimationTypeMoveIn,
    YPBannerAnimationTypePush,
    YPBannerAnimationTypeReveal,
    YPBannerAnimationTypeCube,
    YPBannerAnimationTypeOglFlip,
    YPBannerAnimationTypeSuckEffect,
    YPBannerAnimationTypeRippleEffect,
    YPBannerAnimationTypePageCurl,
    YPBannerAnimationTypePageUnCurl
};

@interface YPBannerView : UIView <YPBannerManagerDelegate>
- (instancetype)initWithFrame:(CGRect)frame
             andYPBannerItems:(NSArray<YPBannerItem *> *)itemArray;
- (instancetype)initWithFrame:(CGRect)frame
                YPBannerItems:(NSArray<YPBannerItem *> *)itemArray
                animationType:(YPBannerAnimationType)type
              andTimeDuration:(NSTimeInterval)duration;
@end
