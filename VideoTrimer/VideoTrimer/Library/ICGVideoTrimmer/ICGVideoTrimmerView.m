//
//  ICGVideoTrimmerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGVideoTrimmerView.h"
#import "ICGThumbView.h"

#define kSpacing 0

@interface ICGVideoTrimmerView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *frameView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (strong, nonatomic) UIView *leftOverlayView;
@property (strong, nonatomic) UIView *rightOverlayView;
@property (strong, nonatomic) ICGThumbView *leftThumbView;
@property (strong, nonatomic) ICGThumbView *rightThumbView;

@property (strong, nonatomic) UIView *trackerView;
@property (strong, nonatomic) UIView *topBorder;
@property (strong, nonatomic) UIView *bottomBorder;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat endTime;

@property (nonatomic) CGFloat widthPerSecond;

@property (nonatomic) CGPoint leftStartPoint;
@property (nonatomic) CGPoint rightStartPoint;
@property (nonatomic) CGFloat overlayWidth;

@end

@implementation ICGVideoTrimmerView

#pragma mark - Initiation

- (instancetype)initWithAsset:(AVAsset *)asset
{
    return [self initWithFrame:CGRectZero asset:asset];
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    self = [super initWithFrame:frame];
    if (self) {
        _asset = asset;
        [self resetSubviews];
    }
    return self;
}


#pragma mark - Private methods

- (CGFloat)thumbWidth
{
    return _thumbWidth ?: 20;
}

- (CGFloat)maxLength
{
    return _maxLength ?: 15;
}

- (CGFloat)minLength
{
    return _minLength ?: 3;
}

- (CGFloat)borderWidth
{
    return _borderWidth ?: 4;
}

// Reset subviews Frames according to View
- (void)resetSubviews
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kSpacing, 0, CGRectGetWidth(self.frame) - kSpacing*2, CGRectGetHeight(self.frame))];
    [self addSubview:self.scrollView];
    [self.scrollView setDelegate:self];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    
    self.contentView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView setContentSize:self.contentView.frame.size];
    [self.scrollView addSubview:self.contentView];
    
    self.frameView = [[UIView alloc] initWithFrame:CGRectMake(self.thumbWidth, self.borderWidth, CGRectGetWidth(self.contentView.frame)-2*self.thumbWidth, CGRectGetHeight(self.contentView.frame) - (self.borderWidth * 2))];
    [self.frameView.layer setMasksToBounds:YES];
    [self.contentView addSubview:self.frameView];
    
    [self addFrames];
    
    // add borders
    self.topBorder = [[UIView alloc] init];
    [self.topBorder setBackgroundColor:self.themeColor];
    [self addSubview:self.topBorder];
    
    self.bottomBorder = [[UIView alloc] init];
    [self.bottomBorder setBackgroundColor:self.themeColor];
    [self addSubview:self.bottomBorder];
    
    // width for left and right overlay views
    self.overlayWidth =  CGRectGetWidth(self.frame) - (self.minLength * self.widthPerSecond);

    // add left overlay view
    self.leftOverlayView = [[UIView alloc] initWithFrame:CGRectMake(kSpacing + self.thumbWidth + (self.thumbWidth/2) - self.overlayWidth, 0 /*-7*/, self.overlayWidth, CGRectGetHeight(self.contentView.frame))];
    CGRect leftThumbFrame = CGRectMake(self.overlayWidth-self.thumbWidth, 0, self.thumbWidth, CGRectGetHeight(self.leftOverlayView.frame));
    if (self.leftThumbImage) {
        self.leftThumbView = [[ICGThumbView alloc] initWithFrame:leftThumbFrame thumbImage:self.leftThumbImage];
    } else {
        self.leftThumbView = [[ICGThumbView alloc] initWithFrame:leftThumbFrame color:self.themeColor right:NO];
    }
    [self.leftThumbView setBackgroundColor:[UIColor clearColor]];
    
    UIView *viewLeftOverlayBG = [[UIView alloc] initWithFrame:CGRectMake(-self.thumbWidth/2, 0 /*7*/, CGRectGetWidth(self.leftOverlayView.frame)  , CGRectGetHeight(self.leftOverlayView.frame) /*-7*/)];
    [viewLeftOverlayBG setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [viewLeftOverlayBG setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.leftOverlayView addSubview:viewLeftOverlayBG];

    [self.leftOverlayView addSubview:self.leftThumbView];
    [self.leftOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *leftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftOverlayView:)];
    [self.leftOverlayView addGestureRecognizer:leftPanGestureRecognizer];
    [self.leftOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    [self addSubview:self.leftOverlayView];

    // add right overlay view
    CGFloat rightViewFrameX = CGRectGetWidth(self.contentView.frame) < CGRectGetWidth(self.frame) ? CGRectGetMaxX(self.contentView.frame) : CGRectGetWidth(self.frame) - self.thumbWidth;
    self.rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(rightViewFrameX - kSpacing - (self.thumbWidth/2), 0, self.overlayWidth, CGRectGetHeight(self.contentView.frame) /*7*/)];
    CGRect rightThumbFrame = CGRectMake(0, 0, self.thumbWidth, CGRectGetHeight(self.rightOverlayView.frame));

    if (self.rightThumbImage) {
        self.rightThumbView = [[ICGThumbView alloc] initWithFrame:rightThumbFrame thumbImage:self.rightThumbImage];
    } else {
        self.rightThumbView = [[ICGThumbView alloc] initWithFrame:rightThumbFrame color:self.themeColor right:YES];
    }
    [self.rightThumbView setBackgroundColor:[UIColor clearColor]];

    
    UIView *viewRightOverlayBG = [[UIView alloc] initWithFrame:CGRectMake(self.thumbWidth/2, 0, CGRectGetWidth(self.rightOverlayView.frame)  , CGRectGetHeight(self.rightOverlayView.frame) /*-7*/)];
    [viewRightOverlayBG setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [viewRightOverlayBG setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.rightOverlayView addSubview:viewRightOverlayBG];
    
    [self.rightOverlayView addSubview:self.rightThumbView];
    [self.rightOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *rightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRightOverlayView:)];
    [self.rightOverlayView addGestureRecognizer:rightPanGestureRecognizer];
    [self.rightOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    [self addSubview:self.rightOverlayView];
    
    [self updateBorderFrames];
    [self notifyDelegate];
}

// Update Border Frames
- (void)updateBorderFrames
{
    [self.topBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), 0, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), self.borderWidth)];
    [self.bottomBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), CGRectGetHeight(self.contentView.frame)-self.borderWidth, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), self.borderWidth)];
}

- (void)moveLeftOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.leftStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.leftStartPoint.x;
            
            
            CGPoint center = self.leftOverlayView.center;
            
            CGFloat newLeftViewMidX = center.x += deltaX;
    
            CGFloat maxWidth = CGRectGetMinX(self.rightOverlayView.frame) - (self.minLength * self.widthPerSecond);
            CGFloat newLeftViewMinX = newLeftViewMidX - self.overlayWidth/2;
            
            // Get Pan Gesture Direction.
            CGPoint velocity = [gesture velocityInView:self.rightOverlayView];
            BOOL isPanToRight = (velocity.x > 0);
            
            if (newLeftViewMinX < kSpacing + self.thumbWidth + (self.thumbWidth/2) - self.overlayWidth && !isPanToRight) {
                newLeftViewMidX = kSpacing + self.thumbWidth + (self.thumbWidth/2) - self.overlayWidth + self.overlayWidth/2;
            }
            else if (newLeftViewMinX + self.overlayWidth > maxWidth && isPanToRight) {
                newLeftViewMidX = maxWidth - self.overlayWidth/2 + self.thumbWidth;
            }

            // Stop Drag After Left Most Point
            NSInteger leftPoint = (newLeftViewMidX + (self.leftOverlayView.frame.size.width / 2));
            if (leftPoint < 18) {
                return;
            }
            
            self.leftOverlayView.center = CGPointMake(newLeftViewMidX, self.leftOverlayView.center.y);
            
            self.leftStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegate];
            
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)moveRightOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.rightStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.rightStartPoint.x;
            
            CGPoint center = self.rightOverlayView.center;
        
            CGFloat newRightViewMidX = center.x += deltaX;
            CGFloat minX = CGRectGetMaxX(self.leftOverlayView.frame) + self.minLength * self.widthPerSecond;
            CGFloat maxX = floorf(CMTimeGetSeconds([self.asset duration])) <= self.maxLength + 0.5 ? CGRectGetMaxX(self.frameView.frame) + (self.thumbWidth*2) + kSpacing : CGRectGetWidth(self.frame) - self.thumbWidth;
            
            // Get Pan Gesture Direction.
            CGPoint velocity = [gesture velocityInView:self.rightOverlayView];
            BOOL isPanToRight = (velocity.x > 0);
            
            if (newRightViewMidX - self.overlayWidth/2 < minX && !isPanToRight) {
                newRightViewMidX = minX + self.overlayWidth/2 - self.thumbWidth;
            }
            else if (newRightViewMidX - self.overlayWidth/2 > maxX - (self.thumbWidth/2)  && isPanToRight) {
                newRightViewMidX = maxX + self.overlayWidth/2 - (self.thumbWidth/2);
            }
            
            // Stop Drag After Right Most Point
            NSInteger rightPoint = (self.frame.size.width - (newRightViewMidX - (self.rightOverlayView.frame.size.width / 2)));
            if (rightPoint < 18) {
                return;
            }
            
            self.rightOverlayView.center = CGPointMake(newRightViewMidX, self.rightOverlayView.center.y);
            self.rightStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegate];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)seekToTime:(CGFloat) time
{    
    CGFloat posToMove = time * self.widthPerSecond + self.thumbWidth - self.scrollView.contentOffset.x;
    
    CGRect trackerFrame = self.trackerView.frame;
    trackerFrame.origin.x = posToMove;
    self.trackerView.frame = trackerFrame;
    
}

- (void)hideTracker:(BOOL)flag
{
    self.trackerView.hidden = flag;
}

- (void)notifyDelegate {
    
    CGFloat start = (CGRectGetMaxX(self.leftOverlayView.frame) - kSpacing - (self.thumbWidth/2)) / self.widthPerSecond + (self.scrollView.contentOffset.x - self.thumbWidth) / self.widthPerSecond;
    if (!self.trackerView.hidden && start != self.startTime) {
        [self seekToTime:start];
    }

    self.startTime = roundf(start);
    CGFloat end = (CGRectGetMinX(self.rightOverlayView.frame) - kSpacing + (self.thumbWidth/2))/ self.widthPerSecond + (self.scrollView.contentOffset.x - self.thumbWidth) / self.widthPerSecond;
    self.endTime = roundf(end);

    [self.delegate trimmerView:self didChangeLeftPosition:self.startTime rightPosition:self.endTime];
}

- (void)addFrames
{
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.frameView.frame)*2, CGRectGetHeight(self.frameView.frame)*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.frameView.frame), CGRectGetHeight(self.frameView.frame));
    }
    
    CGFloat picWidth = 0;
    
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *videoScreen;
    if ([self isRetina]){
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
    } else {
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
    }
    if (halfWayImage != NULL) {
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = tmp.frame;
        rect.size.width = videoScreen.size.width;
        tmp.frame = rect;
        [self.frameView addSubview:tmp];
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    Float64 duration = ceilf(CMTimeGetSeconds([self.asset duration]));
    CGFloat screenWidth = CGRectGetWidth(self.scrollView.frame) - 2*self.thumbWidth; // quick fix to make up for the width of thumb views
    
    NSInteger actualFramesNeeded;
    
    CGFloat frameViewFrameWidth = ((duration / self.maxLength) * screenWidth);
    [self.frameView setFrame:CGRectMake(self.thumbWidth, self.borderWidth, frameViewFrameWidth, CGRectGetHeight(self.frameView.frame))];
    CGFloat contentViewFrameWidth = duration <= self.maxLength + 0.5 ? screenWidth + 30 : frameViewFrameWidth;
    contentViewFrameWidth += (self.thumbWidth*2);
    [self.contentView setFrame:CGRectMake(0, 0, contentViewFrameWidth, CGRectGetHeight(self.contentView.frame))];
    [self.scrollView setContentSize:self.contentView.frame.size];
    NSInteger minFramesNeeded = screenWidth / picWidth + 1;
    actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded + 1;
    
    Float64 durationPerFrame = duration / (actualFramesNeeded*1.0);
    self.widthPerSecond = frameViewFrameWidth / duration;
    
    int preferredWidth = 0;
    NSMutableArray *times = [[NSMutableArray alloc] init];
    for (int i=1; i<actualFramesNeeded; i++){
        
        CMTime time = CMTimeMakeWithSeconds(i*durationPerFrame, 600);
        [times addObject:[NSValue valueWithCMTime:time]];
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        tmp.tag = i;
        
        CGRect currentFrame = tmp.frame;
        currentFrame.origin.x = i*picWidth;
        
        currentFrame.size.width = picWidth;
        preferredWidth += currentFrame.size.width;
        
        if( i == actualFramesNeeded-1){
            currentFrame.size.width-=6;
        }
        tmp.frame = currentFrame;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.frameView addSubview:tmp];
        });
        
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=1; i<=[times count]; i++) {
            CMTime time = [((NSValue *)[times objectAtIndex:i-1]) CMTimeValue];
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            
            UIImage *videoScreen;
            if ([self isRetina]){
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
            CGImageRelease(halfWayImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView *)[self.frameView viewWithTag:i];
                [imageView setImage:videoScreen];
                
            });
        }
    });
}


- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale > 1.0));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (floorf(CMTimeGetSeconds([self.asset duration])) <= self.maxLength + 0.5) {
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentOffset:CGPointZero];
        }];
    }
    [self notifyDelegate];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return TRUE;
}


@end
