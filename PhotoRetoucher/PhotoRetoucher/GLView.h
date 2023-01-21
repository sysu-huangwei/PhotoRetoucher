//
//  GLView.h
//  PhotoRetoucher
//
//  Created by rayyyhuang on 2022/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLView : UIView

- (void)setInputImage:(UIImage *)image;

- (void)render;

@end

NS_ASSUME_NONNULL_END
