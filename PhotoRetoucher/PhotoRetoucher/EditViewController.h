//
//  EditViewController.h
//  PhotoRetoucher
//
//  Created by Ray on 2021/11/9.
//

#import "ViewController.h"
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditViewController : ViewController

@property (strong, nonatomic) IBOutlet GPUImageView *showView;

- (instancetype)initWithOriginImage:(UIImage *)originImage;

@end

NS_ASSUME_NONNULL_END
