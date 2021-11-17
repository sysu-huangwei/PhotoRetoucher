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

@interface GPUImageEffectFilter : GPUImageFilter

@property (nonatomic, assign) float brightnessAlpha;

@end

NS_ASSUME_NONNULL_END
