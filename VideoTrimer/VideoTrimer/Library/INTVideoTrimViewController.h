/*
 
The MIT License (MIT)

Copyright (c) 2018 INTUZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#import <UIKit/UIKit.h>

#import "ICGVideoTrimmerView.h"
#import "INTVideoPlayerView.h"

typedef void(^CompleteVideoEditing)(BOOL success, NSURL *trimedFilePath);

@interface INTVideoTrimViewController : UIViewController <INTVideoPlayerDelegate, ICGVideoTrimmerDelegate>
{
    IBOutlet INTVideoPlayerView *viewVideo;
    IBOutlet ICGVideoTrimmerView *videoTrimmer;
    
    IBOutlet UIView *viewVideoOptions;
    IBOutlet UISlider *sliderTime;
    IBOutlet UIButton *btnPlayPause;
    
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblTrimmedTime;
    
    CGFloat videoPlaybackTime;
    CGFloat videoDuration;
    
    BOOL isScrubbing;
    
    CGFloat videoTrimStartTime;
    CGFloat videoTrimEndTime;
}

@property (copy, nonatomic) CompleteVideoEditing completionBlock;

// To Present Video Trimer View Controller
+ (void) presentVideoTrimController:(UIViewController *)controller mediaURL:(NSURL *)mediaURL completion:(CompleteVideoEditing)complete;

// To Push Video Trimer View Controller
+ (void) pushVideoTrimController:(UIViewController *)controller mediaURL:(NSURL *)mediaURL completion:(CompleteVideoEditing)complete;

@end
