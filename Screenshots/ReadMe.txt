Video Editor

Video Trimmer is a simple component, which lets you trim your videos files on the fly. You can see preview video before trimming your selected video. 

Feature: 
• You can select a range of video to be trimmed. • Ability to pick/capture a video and trim it. • Ability to play selected range of video before trimming. 

Pro’s 
• Easy & Fast to make video modification. • Video quality remain as it have in original files. • You can play video range before actually trimming the video. • Fully customised design layout. 

Con’s 
• Currently we don’t have any. 

Required Framework
	#import <AVFoundation/AVFoundation.h>
	#import <CoreMedia/CoreMedia.h>
	#import <MobileCoreServices/MobileCoreServices.h>

How to use:
To use this component in your project you need to perform below steps:

1) Import “VideoEditorViewController.h" file where you want to implement this feature.

2) Add below code where you want to implement this component:
• To Present Video Editor View:

	[VideoEditorViewController presentVideoEditorController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
        	        // Do your stuff here..
        	        NSLog(@"%@", trimedFilePath);
        	    }];


• To Push Video Editor View:

	[VideoEditorViewController pushVideoEditorController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
        	        // Do your stuff here..
        	        NSLog(@"%@", trimedFilePath);
        	    }];


Note: Make sure you add below key in info.plist and provide there valid description.
	- NSCameraUsageDescription
	- NSPhotoLibraryUsageDescription



We used below library to complete this feature

- ICGVideoTrimmer: https://github.com/itsmeichigo/ICGVideoTrimmer
- VIMVideoPlayer: https://github.com/vimeo/VIMVideoPlayer