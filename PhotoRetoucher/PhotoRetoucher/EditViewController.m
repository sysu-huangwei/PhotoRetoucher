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
@property (strong, nonatomic) GPUImageFilter *smallImageFilter;
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_showView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:_originImage];
    [_showView addSubview:imageView];
    
    _originPicture = [[GPUImagePicture alloc] initWithImage:_originImage];
    _effectFilter = [[GPUImageEffectFilter alloc] init];
    [_originPicture addTarget:_effectFilter];
    [_effectFilter addTarget:_showView];

    _smallImageFilter = [[GPUImageFilter alloc] init];
    float smallEdge = fminf(_originImage.size.width, _originImage.size.height);
    float ratio = 360.0f / smallEdge;
    [_smallImageFilter forceProcessingAtSize: CGSizeMake(roundf(_originImage.size.width * ratio), roundf(_originImage.size.height * ratio))];
    [_smallImageFilter useNextFrameForImageCapture];
    [_originPicture addTarget:_smallImageFilter];
    
//    _originPicture.framebufferForOutput
    
    _effectAlpha = [NSMutableDictionary dictionaryWithDictionary: @{
        @(EffectType_Brightness) : @(0.0),
        @(EffectType_Contrast) : @(0.0),
        @(EffectType_Saturation) : @(0.0),
        @(EffectType_Level) : @(1.0),
        @(EffectType_Sharpen) : @(0.0),
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_originPicture processImageWithCompletionHandler:^{
        glFlush();
        GLubyte *byteBuffer =  _smallImageFilter.framebufferForOutput.byteBuffer;
        NSUInteger bytesPerRow =  _smallImageFilter.framebufferForOutput.bytesPerRow;
        CGFloat widthf = _smallImageFilter.framebufferForOutput.size.width;
        CGFloat heightf = _smallImageFilter.framebufferForOutput.size.height;
        size_t width = _smallImageFilter.framebufferForOutput.byteBufferWidth;
        size_t height = _smallImageFilter.framebufferForOutput.byteBufferHeight;
        [_effectFilter setBGRASmallImageData:byteBuffer width:width height:height bytesPerRow:bytesPerRow];
        [_originPicture removeTarget:_smallImageFilter];
        [_smallImageFilter setEnabled:NO];

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
        } else if ([button.currentTitle isEqualToString:@"饱和度"]) {
            _currentSelectedEffectType = EffectType_Saturation;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = -1.0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Saturation)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"色阶"]) {
            _currentSelectedEffectType = EffectType_Level;
            _effectSlider.maximumValue = 9.99;
            _effectSlider.minimumValue = 0.01;
            _effectSlider.value = [_effectAlpha[@(EffectType_Level)] floatValue];
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
