**<h1>Introduction</h1>**
INTUZ is presenting an interesting Video Triming Control to integrate inside your iOS based application. 
Please follow the below steps to integrate this control in your next project.

<br/><br/>
**<h1>Features</h1>**
* Easy & fast video trimming & modifications process.
* You can select a range of videos to be trimmed.
* Ability to pick/capture a starting and ending point of video for trimming process.
* Ability to play selected range of video before trimming.
* Video quality remain as it have in original files.
* You can play video range before actually trimming the video.
* Fully customizable layout.

<br/><br/>

![Alt text](Screenshots/VideoTrimer.gif?raw=true "Title")


<br/><br/>
**<h1>Getting Started</h1>**

> Required Frameworks

```
    #import <AVFoundation/AVFoundation.h>
	#import <CoreMedia/CoreMedia.h>
	#import <MobileCoreServices/MobileCoreServices.h>
```

> Steps to Integrate


1) Add `#import "INTVideoTrimViewController.h"` at the required place on your code.

2) Add below code where you want to open video trimming controller:

* To Present Video Trim View:
```
	[INTVideoTrimViewController presentVideoTrimController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
        	        // Do your stuff here..
        	        NSLog(@"%@", trimedFilePath);
        	    }];
```

* To Push Video Trim View:
```
	[INTVideoTrimViewController pushVideoTrimController:self mediaURL:mediaURL completion:^(BOOL success, NSURL *trimedFilePath) {
        	        // Do your stuff here..
        	        NSLog(@"%@", trimedFilePath);
        	    }];
```

**Note:** Make sure you add below key in info.plist and provide there valid description.
	
	- NSCameraUsageDescription
	- NSPhotoLibraryUsageDescription


<br/><br/>
**<h1>Bugs and Feedback</h1>**
For bugs, questions and discussions please use the Github Issues.

<br/><br/>
**<h1>Acknowledgments</h1>**

<br/>
* <a href="https://github.com/itsmeichigo/ICGVideoTrimmer" target="_blank">ICGVideoTrimmer</a>

<br/><br/>
**<h1>License</h1>**
The MIT License (MIT)
<br/><br/>
Copyright (c) 2018 INTUZ
<br/><br/>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
<br/><br/>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<br/>
<h1></h1>
<a href="https://www.intuz.com/" target="_blank"><img src="Screenshots/logo.jpg"></a>
