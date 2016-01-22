# YPBanner
    Just a few lines of code, you can easily add banner to your app. 
    How to use?
    =======YPBannerView=======
    //Banner item init
    YPBannerItem *item_01 = [[YPBannerItem alloc] initWithImage:[UIImage imageNamed:@"placehold.png"] data:nil];
    YPBannerItem *item_02 = [[YPBannerItem alloc] initWithUrl:@"web_url" 
                                                         data:nil 
                                               andPlaceholder:[UIImage imageNamed:@"placehold.png"]];
    ......
    //default animation
    _bannerView = [[YPBannerView alloc] initWithFrame:parentView.bounds andYPBannerItems:@[item_01,item_02...]];     
    //set animation type and duration
    _bannerView= [[YPBannerView alloc] initWithFrame:parentView.bounds 
                                       YPBannerItems:@[item_01,item_02...] 
                                       animationType:YPBannerAnimationTypeCube 
                                     andTimeDuration:1.5f];
   

