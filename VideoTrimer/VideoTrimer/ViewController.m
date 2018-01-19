/*
 
 The MIT License (MIT)
 
 Copyright (c) 2018 INTUZ
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import "ViewController.h"

#import "INTVideoTrimViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL isPresentVideoEditor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Video Editor";
}

// Called when received memory warnings.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Open Trim View Controller by using Presenting ViewController.
- (IBAction)btnPresentVideoEditor:(id)sender {
    self.isPresentVideoEditor = true;
    [self openGalleryViewForVideo];
}

// Open Trim View Controller by Pushing in NavigationController.
- (IBAction)btnPushVideoEditor:(id)sender {
    self.isPresentVideoEditor = false;
    [self showCameraForVideo];
}

// Open Camera Control to capture a video.
- (void) showCameraForVideo {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc]init];
    [videoPicker setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [videoPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [videoPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [videoPicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [self presentViewController:videoPicker animated:TRUE completion:nil];
}

// Open Video Picker Controller.
- (void) openGalleryViewForVideo {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc]init];
    [videoPicker setDelegate:self];
    [videoPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [videoPicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [self presentViewController:videoPicker animated:TRUE completion:nil];
}

#pragma mark - UIImagePicker Delegate.

// Image Picker delegate for Pick a Video Files.
-  (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:TRUE completion:^{
        if([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
            NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL] ? : [info objectForKey:UIImagePickerControllerReferenceURL];
            if (self.isPresentVideoEditor) {
                [INTVideoTrimViewController presentVideoTrimController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
                    // Do your stuff here..
                    NSLog(@"%@", trimedFilePath);
                }];
            }
            else {
                [INTVideoTrimViewController pushVideoTrimController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
                    // Do your stuff here..
                    NSLog(@"%@", trimedFilePath);
                }];
            }
        }
    }];
}

@end
