//
//  EditViewController.m
//  PhotoRetoucher
//
//  Created by Ray on 2021/11/9.
//

#import "EditViewController.h"
#import "GPUImageEffectFilter.h"

@interface EditViewController ()

@property (nonatomic, strong) UIImage *originImage;
@property (strong, nonatomic) GPUImagePicture *originPicture;
@property (strong, nonatomic) GPUImageEffectFilter *effectFilter;

@end

@implementation EditViewController

- (instancetype)initWithOriginImage:(UIImage *)originImage {
    if (self = [super init]) {
        _originImage = originImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _originPicture = [[GPUImagePicture alloc] initWithImage:_originImage];
    _effectFilter = [[GPUImageEffectFilter alloc] init];
    [_originPicture addTarget:_effectFilter];
    [_effectFilter addTarget:_showView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_showView.bounds];
    [imageView setImage:_originImage];
    [_showView addSubview:imageView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_originPicture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *view in self->_showView.subviews) {
                [view removeFromSuperview];
            }
        });
    }];
}

- (IBAction)brightnessSelected:(id)sender {
    _effectSlider.hidden = NO;
}

- (IBAction)effectSliderChanged:(UISlider *)slider {
    _effectFilter.brightnessAlpha = slider.value;
    [_originPicture processImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
