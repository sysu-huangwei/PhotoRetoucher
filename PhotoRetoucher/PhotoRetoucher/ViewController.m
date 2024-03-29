//
//  ViewController.m
//  PhotoRetoucher
//
//  Created by rayyy on 2021/11/8.
//

#import "ViewController.h"
#import "EditViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, nonnull) EditViewController* editViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _editViewController = [[EditViewController alloc] init];
    _editViewController.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (IBAction)openAlbum:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(image.imageOrientation != UIImageOrientationUp){
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    [_editViewController setInputImage:image];
    [self presentViewController:_editViewController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
