/*
 
 The MIT License (MIT)
 
 Copyright (c) 2018 INTUZ
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

@import Foundation;
@import AVFoundation;
@import UIKit;

@class INTVideoPlayerView;

@protocol INTVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayerIsReadyToPlayVideo:(INTVideoPlayerView *)videoPlayer;
- (void)videoPlayerDidReachEnd:(INTVideoPlayerView *)videoPlayer;
- (void)videoPlayer:(INTVideoPlayerView *)videoPlayer timeDidChange:(CMTime)cmTime;
- (void)videoPlayer:(INTVideoPlayerView *)videoPlayer loadedTimeRangeDidChange:(float)duration;
- (void)videoPlayerPlaybackBufferEmpty:(INTVideoPlayerView *)videoPlayer;
- (void)videoPlayerPlaybackLikelyToKeepUp:(INTVideoPlayerView *)videoPlayer;
- (void)videoPlayer:(INTVideoPlayerView *)videoPlayer didFailWithError:(NSError *)error;

@end

@interface INTVideoPlayerView : UIView

@property (nonatomic, weak) id<INTVideoPlayerDelegate> delegate;

@property (nonatomic, strong, readonly) AVPlayer *player;

@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) BOOL isLooping;
@property (nonatomic, assign) BOOL isMuted;

- (void)setURL:(NSURL *)URL;
- (void)setPlayerItem:(AVPlayerItem *)playerItem;
- (void)setAsset:(AVAsset *)asset;

- (void)setVideoFillMode:(NSString *)fillMode;

// Playback

- (void)play;
- (void)pause;
- (void)seekToTime:(float)time completion:(void (^)(void))completionHandler;
- (void)reset;

// AirPlay

- (void)enableAirplay;
- (void)disableAirplay;
- (BOOL)isAirplayEnabled;

// Time Updates

- (void)enableTimeUpdates;
- (void)disableTimeUpdates;

// Scrubbing

- (void)startScrubbing;
- (void)scrub:(float)time;
- (void)stopScrubbing;

// Volume

- (void)setVolume:(float)volume;
- (void)fadeInVolume;
- (void)fadeOutVolume;

@end
