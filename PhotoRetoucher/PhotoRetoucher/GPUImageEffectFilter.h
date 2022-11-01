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
    EffectType_Mean = 6,
};

@interface GPUImageEffectFilter : GPUImageFilter

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha;

- (void)setLutImagePath:(NSString *)lutImagePath;

- (void)setBGRASmallImageData:(unsigned char *)data width:(size_t)width height:(size_t)height bytesPerRow:(size_t)bytesPerRow;

@end

NS_ASSUME_NONNULL_END
