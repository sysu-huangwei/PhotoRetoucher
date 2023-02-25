//
//  GLView.h
//  PhotoRetoucher
//
//  Created by rayyyhuang on 2022/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EffectType) {
    EffectType_Brightness = 1,
    EffectType_Contrast = 2,
    EffectType_Saturation = 3,
    EffectType_Level = 4,
    EffectType_Sharpen = 5,
    EffectType_Mean = 6,
    EffectType_Mesh = 7,
    EffectType_Sticker = 8,
};

@interface GLView : UIView

- (void)setInputImage:(UIImage *)image;

- (void)render;

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha;

- (void)setLutImagePath:(NSString *)lutImagePath;

@end

NS_ASSUME_NONNULL_END
