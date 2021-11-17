//
//  GPUImageEffectFilter.h
//  PhotoRetoucher
//
//  Created by rayyy on 2021/11/16.
//

#if __cplusplus
extern "C" {
#endif
#import <GPUImage/GPUImage.h>
#if __cplusplus
}
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EffectType) {
    EffectType_Brightness = 1,
    EffectType_Sharpen = 2,
};

@interface GPUImageEffectFilter : GPUImageFilter

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
