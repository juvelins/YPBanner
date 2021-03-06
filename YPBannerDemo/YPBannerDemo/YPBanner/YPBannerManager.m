//
//  YPBannerManager.m
//  YPBannerDemo
//
//  Created by yupao on 12/25/15.
//  Copyright © 2015 yupao. All rights reserved.
//

#import "YPBannerManager.h"
#import "SDWebImageManager.h"

@interface YPBannerManager(){
    
}

@property (nonatomic, strong) NSMutableArray *itemQueue;
@property (nonatomic, strong) SDWebImageManager *imageManager;

@end

@implementation YPBannerManager

+ (instancetype)sharedYPBannerManager {
    static dispatch_once_t once_token;
    static YPBannerManager *bannerManager = nil;
    dispatch_once(&once_token, ^{
        bannerManager = [[YPBannerManager alloc] init];
    });
    return bannerManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemQueue = [[NSMutableArray alloc] init];
        _countOfItems = _itemQueue.count;
    }
    return self;
}

- (void)addItems:(NSArray<YPBannerItem *> *)itemArray {
    [itemArray enumerateObjectsUsingBlock:^(YPBannerItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addItem:obj];
    }];
}

- (void)addItem:(YPBannerItem *)item {
    if (!item) {
        return;
    }
    if (!_imageManager) {
        _imageManager = [SDWebImageManager sharedManager];
    }
    item.itemIndex = _itemQueue.count;
    [_itemQueue addObject:item];
    _countOfItems = _itemQueue.count;
    if (_delegate && [_delegate respondsToSelector:@selector(YPBannerManager:addItem:)]) {
        [_delegate YPBannerManager:self addItem:item];
    }
    //下载图片,内存缓存策略
    if (item.itemImgUrl) {
        [_imageManager downloadImageWithURL:[NSURL URLWithString:item.itemImgUrl] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            item.itemImg = image;
        }];
    }
    }

- (void)deleteItem:(YPBannerItem *)item {
    if (!item) {
        return;
    }
    NSInteger itemIndex = [_itemQueue indexOfObject:item];
    if ((itemIndex >= 0) && (itemIndex < _itemQueue.count)) {
        [_itemQueue removeObject:item];
        _countOfItems = _itemQueue.count;
        for (NSInteger i = itemIndex; i < _itemQueue.count; i++) {
            ((YPBannerItem *)(_itemQueue[i])).itemIndex = i;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(YPBannerManager:deleteItem:)]) {
            [_delegate YPBannerManager:self deleteItem:item];
        }
    }
}

- (void)removeAllItems {
    [_itemQueue removeAllObjects];
    _countOfItems = _itemQueue.count;
    if (_delegate && [_delegate respondsToSelector:@selector(YPBannerManager:removeAllItemsWithPlacehold:)]) {
        [_delegate YPBannerManager:self removeAllItemsWithPlacehold:[UIImage imageNamed:@"placehold.png"]];
    }
}

- (YPBannerItem *)itemAtIndex:(NSInteger)index {
    return _itemQueue[index];
}
@end
