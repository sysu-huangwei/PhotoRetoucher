//
//  EditViewController.m
//  PhotoRetoucher
//
//  Created by Ray on 2021/11/9.
//

#import "EditViewController.h"
#import "UIView+Toast.h"



@interface EditViewController ()

@property (nonatomic, strong) UIImage *originImage;
//@property (strong, nonatomic) GPUImagePicture *originPicture;
//@property (strong, nonatomic) GPUImageFilter *smallImageFilter;
//@property (strong, nonatomic) GPUImageEffectFilter *effectFilter;

@property (assign, nonatomic) EffectType currentSelectedEffectType;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *effectAlpha;

@property (strong, nonatomic) NSArray *lutImagePaths;
@property (assign, nonatomic) NSUInteger currintLutIndex;

@end

@implementation EditViewController


- (void)setInputImage:(UIImage *)originImage {
    _originImage = originImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_showView.bounds];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [imageView setImage:_originImage];
//    [_showView addSubview:imageView];
    
//    _originPicture = [[GPUImagePicture alloc] initWithImage:_originImage];
//    _effectFilter = [[GPUImageEffectFilter alloc] init];
//    [_originPicture addTarget:_effectFilter];
//    [_effectFilter addTarget:_showView];
//
//    _smallImageFilter = [[GPUImageFilter alloc] init];
//    float smallEdge = fminf(_originImage.size.width, _originImage.size.height);
//    float ratio = 360.0f / smallEdge;
//    [_smallImageFilter forceProcessingAtSize: CGSizeMake(roundf(_originImage.size.width * ratio), roundf(_originImage.size.height * ratio))];
//    [_smallImageFilter useNextFrameForImageCapture];
//    [_originPicture addTarget:_smallImageFilter];
    
//    _originPicture.framebufferForOutput
    
    
//    [_effectFilter setStickerImagePath:stickerPath];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _effectAlpha = [NSMutableDictionary dictionaryWithDictionary: @{
        @(EffectType_Brightness) : @(0.0),
        @(EffectType_Contrast) : @(0.0),
        @(EffectType_Saturation) : @(0.0),
        @(EffectType_Level) : @(1.0),
        @(EffectType_Sharpen) : @(0.0),
        @(EffectType_Mean) : @(0.0),
    }];
    
    _lutImagePaths = @[
        @"",
        [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"LutResource/brunch1.png"],
        [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"LutResource/brunch2.png"],
        [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"LutResource/brunch3.png"],
        [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"LutResource/brunch4.png"],
    ];
    _currintLutIndex = 0;
    
    NSString *stickerPath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"makeup/makeup.png"];
    
    [_showView setInputImage:_originImage];
    [_showView render];
//    [_originPicture processImageUpToFilter:_effectFilter withCompletionHandler:^(UIImage *processedImage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (UIView *view in self->_showView.subviews) {
//                [view removeFromSuperview];
//            }
//        });
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_showView releaseGL];
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
            _effectSlider.maximumValue = 0.99;
            _effectSlider.minimumValue = 0.01;
            _effectSlider.value = [_effectAlpha[@(EffectType_Level)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"锐化"]) {
            _currentSelectedEffectType = EffectType_Sharpen;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = 0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Sharpen)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"模糊"]) {
            _currentSelectedEffectType = EffectType_Mean;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = 0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Mean)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"形变"]) {
           _currentSelectedEffectType = EffectType_Mesh;
           _effectSlider.maximumValue = 1.0;
           _effectSlider.minimumValue = 0;
           _effectSlider.value = _effectAlpha[@(EffectType_Mesh)] ? [_effectAlpha[@(EffectType_Mesh)] floatValue] : 0.5;
        } else if ([button.currentTitle isEqualToString:@"贴纸"]) {
           _currentSelectedEffectType = EffectType_Sticker;
           _effectSlider.maximumValue = 1.0;
           _effectSlider.minimumValue = 0;
           _effectSlider.value = _effectAlpha[@(EffectType_Sticker)] ? [_effectAlpha[@(EffectType_Sticker)] floatValue] : 1.0;
        }
        _effectSlider.hidden = NO;
        _effectSliderLabel.hidden = NO;
        _effectSliderLabel.text = [NSString stringWithFormat:@"%d", (int)(_effectSlider.value * 100)];
        [_currentSelectedButton setBackgroundColor:UIColor.systemTealColor];
        [button  setBackgroundColor:UIColor.systemOrangeColor];
        _currentSelectedButton = button;
    }
}


- (IBAction)effectSliderChanged:(UISlider *)slider {
    _effectAlpha[@(_currentSelectedEffectType)] = @(slider.value);
    _effectSliderLabel.text = [NSString stringWithFormat:@"%d", (int)(slider.value * 100)];
    [_showView setEffectAlpha:_currentSelectedEffectType alpha:slider.value];
    [_showView render];
}

- (IBAction)showViewGesture:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        _currintLutIndex = _currintLutIndex == _lutImagePaths.count - 1 ? 0 : _currintLutIndex + 1;
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        _currintLutIndex = _currintLutIndex == 0 ? _lutImagePaths.count - 1 : _currintLutIndex - 1;
    }
    [_showView setLutImagePath:_lutImagePaths[_currintLutIndex]];
    [_showView render];
//    [_originPicture processImage];
}

- (IBAction)saveImage:(id)sender {
    UIImage *image = [_showView saveImage];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}


-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error) {
        [self.view makeToast:@"保存失败"];
    }else {
        [self.view makeToast:@"保存成功"];
    }
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
