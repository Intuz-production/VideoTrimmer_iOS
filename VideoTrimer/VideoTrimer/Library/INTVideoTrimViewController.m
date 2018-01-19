/*
 
 The MIT License (MIT)
 
 Copyright (c) 2018 INTUZ
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "INTVideoTrimViewController.h"

@interface INTVideoTrimViewController ()

@property (strong, nonatomic) NSURL *trimmedVideoUrl;
@property (strong, nonatomic) NSURL *mediaURL;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVAsset *assetTrimmed;
@property (strong, nonatomic) AVAssetExportSession *exportSession;

@property (assign, nonatomic) BOOL isPushVideoTrim;

@end

@implementation INTVideoTrimViewController

@synthesize trimmedVideoUrl;

// To Present Video Trimer View Controller
+ (void) presentVideoTrimController:(UIViewController *)controller mediaURL:(NSURL *)mediaURL completion:(CompleteVideoEditing)complete {
    INTVideoTrimViewController *videoTrimController = [[INTVideoTrimViewController alloc] initWithNibName:@"INTVideoTrimViewController" bundle:nil];
    videoTrimController.mediaURL=mediaURL;
    videoTrimController.completionBlock=complete;
    videoTrimController.isPushVideoTrim = false;
    videoTrimController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    [controller presentViewController:videoTrimController animated:true completion:nil];
}

// To Push Video Trimer View Controller
+ (void) pushVideoTrimController:(UIViewController *)controller mediaURL:(NSURL *)mediaURL completion:(CompleteVideoEditing)complete {
    INTVideoTrimViewController *videoTrimController = [[INTVideoTrimViewController alloc] initWithNibName:@"INTVideoTrimViewController" bundle:nil];
    videoTrimController.mediaURL=mediaURL;
    videoTrimController.completionBlock=complete;
    videoTrimController.isPushVideoTrim = true;
    videoTrimController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    [controller.navigationController pushViewController:videoTrimController animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSlider];
    
    // Set Video Fill Mode & Configurations.
    [viewVideo setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
    [viewVideo setDelegate:self];
    [viewVideo setIsLooping:FALSE];
    [viewVideo enableTimeUpdates];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"selectedVideo.mp4"];
    if(_mediaURL)
    {
        [self convertVideoToMP4:_mediaURL withFilePath:filePath completion:^(BOOL success) {
            
            // Configure Video Trimer Object.
            self.asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
            NSLog(@"duration %f", CMTimeGetSeconds(self.asset.duration));
            
            CGFloat assetDuration = CMTimeGetSeconds(self.asset.duration);
            [videoTrimmer setAsset:self.asset];
            [videoTrimmer setThemeColor:[UIColor clearColor]];
            [videoTrimmer setMinLength:3];
            CGFloat maxVideoLength = 60;
            [videoTrimmer setMaxLength:assetDuration < maxVideoLength ? assetDuration : maxVideoLength];
            [videoTrimmer setBorderWidth:5];
            [videoTrimmer setThemeColor:[UIColor clearColor]];
            [videoTrimmer hideTracker:TRUE];
            [videoTrimmer setDelegate:self];
            [videoTrimmer setLeftThumbImage:[UIImage imageNamed:@"video_slider_image"]];
            [videoTrimmer setRightThumbImage:[UIImage imageNamed:@"video_slider_image"]];
            // important: reset subviews
            [videoTrimmer resetSubviews];
            
            [self setupVideoWithAsset:self.asset];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Methods

// Perform cancel action to remove Video Trimer View.
- (IBAction)btnCancelTapped:(id)sender {
    if (self.completionBlock) {
        self.completionBlock(false, nil);
    }
    
    [self dismissVideoTrim];
}

// Perform upload action to trim the Video and provide file path.
- (IBAction)btnUploadTapped:(id)sender {
    // Trim Video for Selected Range.
    [self trimVideoWithCompletion:^{
        
        // Call Completion Block.
        if (self.completionBlock) {
            if(self.trimmedVideoUrl) {
                self.completionBlock(true, self.trimmedVideoUrl);
            }
            else {
                self.completionBlock(false, nil);
            }
        }
        
        [self dismissVideoTrim];
    }];
}

// Perform play/pause action for video.
- (IBAction)btnPlayPauseTapped:(id)sender {
    
    if (viewVideo.isPlaying) {
        [self pauseVideo];
    }
    else {
        [self playVideo];
    }
}

#pragma mark - SetUp Slider

// Setip slider Video.
- (void)setUpSlider {
    
    [sliderTime addTarget:self action:@selector(scrubbingDidStart) forControlEvents:UIControlEventTouchDown];
    [sliderTime addTarget:self action:@selector(scrubbingDidChange) forControlEvents:UIControlEventValueChanged];
    [sliderTime addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:UIControlEventTouchUpInside];
    [sliderTime addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:UIControlEventTouchUpOutside];
    
}

// Video player slider did start dragging.
- (void)scrubbingDidStart {
    [viewVideo startScrubbing];
    [sliderTime setThumbImage:[UIImage imageNamed:@"play_seek_icon"] forState:UIControlStateNormal];
}

// Video player slider did change value by dragging.
- (void)scrubbingDidChange {
    
    videoPlaybackTime = sliderTime.value;
    [viewVideo scrub:[self getCurrentPlaybackTime]];
    isScrubbing = TRUE;
    [self updateTimeLabel];
}


// Video player slider did end draging.
- (void)scrubbingDidEnd {
    [sliderTime setThumbImage:[UIImage imageNamed:@"play_seek_active_icon"] forState:UIControlStateNormal];
    [viewVideo stopScrubbing];
    isScrubbing = FALSE;
    [self updateTimeLabel];
}

#pragma mark - Other Methods

// Perform close video trimer view action.
- (void) dismissVideoTrim {
    if (self.isPushVideoTrim == true) {
        [self.navigationController popViewControllerAnimated:true];
    }
    else {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

// Setup video with AVAsset object.
- (void)setupVideoWithAsset:(AVAsset *)asset {
    
    videoDuration = roundf(CMTimeGetSeconds(asset.duration));
    [viewVideo reset];
    
    NSInteger seconds = (NSInteger)videoDuration % 60;
    NSInteger minutes = ((NSInteger)videoDuration / 60) % 60;
    
    [lblTime setText:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
    
    [viewVideo disableAirplay];
    [viewVideo setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
    [viewVideo setDelegate:self];
    
    [viewVideo setAsset:asset];
}

// Perform Play Video.
- (void)playVideo {
    
    [viewVideo play];
    [btnPlayPause setSelected:TRUE];
}

// Perform pause Video.
- (void)pauseVideo {
    
    [viewVideo pause];
    [btnPlayPause setSelected:FALSE];
}

// Update video time label.
- (void)updateTimeLabel {
    NSString *strCurrentTime = [self timeFormatted:[self getCurrentPlaybackTime]];
    [lblTime setText:strCurrentTime];
    
}

// Update video time label.
- (CGFloat)getCurrentPlaybackTime {
    
    return videoPlaybackTime - videoTrimStartTime;
}

// Get Trimed video duration.
- (CGFloat)getVideoDuration {
    
    return videoTrimEndTime - videoTrimStartTime;
}

// Get Formatted time to display.
- (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes, (long)seconds];
}

// Perform Triming on Selected Range.
- (void)trimVideoWithCompletion:(void(^)(void))completion {
    
    if(!trimmedVideoUrl) {
        trimmedVideoUrl = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"video.mp4"]];
    }
    
    NSLog(@"%@",trimmedVideoUrl);
    if([[NSFileManager defaultManager] fileExistsAtPath:trimmedVideoUrl.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:trimmedVideoUrl error:nil];
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        self.exportSession.outputURL = trimmedVideoUrl;
        self.exportSession.outputFileType = AVFileTypeMPEG4;
        
        CMTime start = CMTimeMakeWithSeconds(videoTrimStartTime, self.asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds([self getVideoDuration], self.asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export cancelled");
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(completion) {
                            completion();
                        }
                    });
                    break;
                }
                default:
                    NSLog(@"NONE");
                    break;
            }
        }];
        
    }
}


// Convert Trimed Video on MP4 formate.
- (void)convertVideoToMP4:(NSURL *)selectedVideoUrl withFilePath:(NSString *)filePath completion:(void(^)(BOOL success))completion {
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSURL *videoFullUrl = [NSURL fileURLWithPath:filePath];
    
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:selectedVideoUrl options:nil];
    if([[selectedVideoUrl.lastPathComponent lowercaseString] containsString:[@".mp4" lowercaseString]]) {
        NSData *videoData = [NSData dataWithContentsOfURL:selectedVideoUrl];
        [videoData writeToFile:videoFullUrl.absoluteString atomically:NO];
        if (completion) {
            completion(TRUE);
        }
    }

    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"bgTask" expirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        _exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        
        _exportSession.shouldOptimizeForNetworkUse = YES;
        _exportSession.outputURL = videoFullUrl;
        _exportSession.outputFileType = AVFileTypeMPEG4;
        
        [_exportSession exportAsynchronouslyWithCompletionHandler:^{
            /*
             AVAssetExportSessionStatusUnknown,
             AVAssetExportSessionStatusWaiting,
             AVAssetExportSessionStatusExporting,
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                switch ([_exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                    case AVAssetExportSessionStatusCancelled: {
                        if (completion) {
                            completion(FALSE);
                        }
                        _exportSession = nil;
                    }
                        break;
                    case AVAssetExportSessionStatusCompleted:{
                        if (completion) {
                            completion(TRUE);
                        }
                        _exportSession = nil;
                        break;
                    }
                    default:
                        break;
                }
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            });
        }];
    }
}

#pragma mark - ICGVideoTrimmerDelegate

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime {

    if(startTime >= 0) {
        videoTrimStartTime = startTime;
        videoTrimEndTime = endTime;
        [sliderTime setMinimumValue:videoTrimStartTime];
        [sliderTime setMaximumValue:videoTrimEndTime];
        [sliderTime setValue:videoTrimStartTime];
        videoPlaybackTime = videoTrimStartTime;
        [lblTrimmedTime setText:[NSString stringWithFormat:@"%.2f - %.2f",videoTrimStartTime,videoTrimEndTime]];
        
        [viewVideo seekToTime:videoTrimStartTime completion:^{
            [self pauseVideo];
        }];
    }
}

#pragma mark - INTVideoPlayer Delegate

// Video Player delegate and called when video is ready to play.
- (void)videoPlayerIsReadyToPlayVideo:(INTVideoPlayerView *)videoPlayer {
    
    videoDuration = CMTimeGetSeconds(videoPlayer.player.currentItem.duration);
    [sliderTime setValue:videoTrimStartTime animated:TRUE];
    [self updateTimeLabel];
    [viewVideo seekToTime:videoTrimStartTime completion:^{
        [self pauseVideo];
    }];
}

// Video Player delegate and called when video is reached to end of file.
- (void)videoPlayerDidReachEnd:(INTVideoPlayerView *)videoPlayer {
}

// Video Player delegate and called when playback time is changed.
- (void)videoPlayer:(INTVideoPlayerView *)videoPlayer timeDidChange:(CMTime)cmTime {
    if(isScrubbing) {
        return;
    }
    videoDuration = CMTimeGetSeconds(videoPlayer.player.currentItem.duration);
    CGFloat time = CMTimeGetSeconds(cmTime);
    if(floorf(time) >= videoTrimEndTime && viewVideo.isPlaying) {
        videoPlaybackTime = videoTrimStartTime;
        [sliderTime setValue:videoPlaybackTime animated:TRUE];
        [self pauseVideo];
        [viewVideo seekToTime:videoTrimStartTime completion:^{
        }];
    }
    else {
        videoPlaybackTime = ceilf(time);
    }

    [sliderTime setValue:videoPlaybackTime animated:TRUE];
    [self updateTimeLabel];

}

// Video Player delegate and called when getting error while playing video.
- (void)videoPlayer:(INTVideoPlayerView *)videoPlayer didFailWithError:(NSError *)error {
    NSLog(@"Error : %@", [error localizedDescription]);
}


@end
