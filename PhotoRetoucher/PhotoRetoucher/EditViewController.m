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

@property (assign, nonatomic) EffectType currentSelectedEffectType;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *effectAlpha;

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
    
    _effectAlpha = [NSMutableDictionary dictionaryWithDictionary: @{
        @(EffectType_Brightness) : @(0.0),
        @(EffectType_Contrast) : @(0.0),
        @(EffectType_Sharpen) : @(0.0),
    }];
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

- (IBAction)clickSomeEffectButton:(UIButton *)button {
    if ([button isEqual:_currentSelectedButton]) {
        [button setBackgroundColor:UIColor.systemTealColor];
        _currentSelectedButton = nil;
        _effectSlider.hidden = YES;
    } else {
        if ([button.currentTitle isEqualToString:@"亮度"]) {
            _currentSelectedEffectType = EffectType_Brightness;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = -1.0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Brightness)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"对比度"]) {
            _currentSelectedEffectType = EffectType_Contrast;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = -1.0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Contrast)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"锐化"]) {
            _currentSelectedEffectType = EffectType_Sharpen;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = 0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Sharpen)] floatValue];
        }
        _effectSlider.hidden = NO;
        [_currentSelectedButton setBackgroundColor:UIColor.systemTealColor];
        [button  setBackgroundColor:UIColor.systemOrangeColor];
        _currentSelectedButton = button;
    }
}


- (IBAction)effectSliderChanged:(UISlider *)slider {
    _effectAlpha[@(_currentSelectedEffectType)] = @(slider.value);
    [_effectFilter setEffectAlpha:_currentSelectedEffectType alpha:slider.value];
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
