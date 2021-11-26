//
//  GPUImageEffectFilter.h
//  PhotoRetoucher
//
//  Created by rayyy on 2021/11/16.
//

#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EffectType) {
    EffectType_Brightness = 1,
    EffectType_Contrast = 2,
    EffectType_Saturation = 3,
    EffectType_Level = 4,
    EffectType_Sharpen = 5,
};

@interface GPUImageEffectFilter : GPUImageFilter

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
