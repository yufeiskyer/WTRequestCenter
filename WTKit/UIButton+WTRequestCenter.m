//
//  UIButton+WTImageCache.m
//  WTRequestCenter
//
//  Created by songwt on 14-7-30.
//  Copyright (c) 2014年 song. All rights reserved.
//



#import "UIButton+WTRequestCenter.h"
#import "WTNetWorkManager.h"
#import <objc/runtime.h>
#import "UIImage+Nice.h"
#import "NSObject+Nice.h"
@implementation UIButton (WTImageCache)

//设置图片的Operation
static const void * const WTButtonImageOperationKey = @"WT Button Image Operation Key";
//设置背景图的Operation
static const void * const WTButtonBackGroundImageOperationKey = @"WT Button Back Ground Image Operation Key";
-(WTURLSessionDataTask*)wtImageRequestOperation
{

    WTURLSessionDataTask *operation = (WTURLSessionDataTask*)objc_getAssociatedObject(self, WTButtonImageOperationKey);
    return operation;
}

-(void)setWtImageRequestOperation:(WTURLSessionDataTask *)wtImageRequestOperation
{
    [[self wtImageRequestOperation] cancel];
    objc_setAssociatedObject(self, WTButtonImageOperationKey, wtImageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(WTURLSessionDataTask*)wtBackGroundImageRequestOperation
{
    WTURLSessionDataTask *operation = (WTURLSessionDataTask*)objc_getAssociatedObject(self, WTButtonBackGroundImageOperationKey);
    return operation;
}

-(void)setWtBackGroundImageRequestOperation:(WTURLSessionDataTask *)wtBackGroundImageRequestOperation
{
    [[self wtBackGroundImageRequestOperation] cancel];
    objc_setAssociatedObject(self, WTButtonBackGroundImageOperationKey, wtBackGroundImageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



- (void)setImageForState:(UIControlState)state
                 withURL:(NSString *)url
{
    [self setImageForState:state withURL:url placeholderImage:nil];
}
- (void)setImageForState:(UIControlState)state
                 withURL:(NSString *)url
        placeholderImage:(UIImage *)placeholderImage
{
    [self setImage:placeholderImage forState:state];
    
    if (!url) {
        return;
    }
    
    
    NSMutableURLRequest *request = [[WTNetWorkManager sharedKit] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    
    
    WTURLSessionDataTask *operation = [UIImage imageCacheTaskWithURL:url complection:^(UIImage * _Nullable image, NSError * _Nullable error) {
        safeSyncInMainQueue(^{
            [self setImage:image forState:state];
            [self setNeedsLayout];
        });
    }];
    
    /*
     
     */
    [self setWtImageRequestOperation:operation];
    [operation resume];
}

- (void)setBackgroundImage:(UIControlState)state
                   withURL:(NSString *)url
{
    [self setBackgroundImage:state withURL:url placeholderImage:nil];
}

- (void)setBackgroundImage:(UIControlState)state
                 withURL:(NSString *)url
        placeholderImage:(UIImage *)placeholderImage
{
    [self setBackgroundImage:placeholderImage forState:state];
    
    if (!url) {
        return;
    }
    NSMutableURLRequest *request = [[WTNetWorkManager sharedKit] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    
    
    WTURLSessionDataTask *operation = [UIImage imageCacheTaskWithURL:url complection:^(UIImage * _Nullable image, NSError * _Nullable error) {
        safeSyncInMainQueue(^{
            [self setBackgroundImage:image forState:state];
            [self setNeedsLayout];
        });
    }];
    
    [self setWtBackGroundImageRequestOperation:operation];
    [operation resume];
             
}

#pragma MARK - Event
-(void)setOnClick:(dispatch_block_t)block{
    objc_setAssociatedObject(self, "touchUpInside", block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)onClick:(id)sender{
    dispatch_block_t block = objc_getAssociatedObject(self, "touchUpInside");
    if (block) {
        block();
    }
}
@end
