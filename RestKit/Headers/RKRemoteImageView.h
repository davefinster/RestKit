/*
 * Copyright 2010 Dave Finster
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RKImageLoader.h"

/**
 * A RKRemoteImageView class provides an easy way of embedding 
 * asynchronously loading images in an application. Simply
 * initialize the view with the URL of the image that you want 
 * to display and it will automatically queue it with the 
 * RKImageLoader manager. While waiting for the download, 
 * an activity indicator will be displayed according to the style 
 * provided. When then download is complete, the view will be 
 * notified and will automatically display the resulting image.
 */

@interface RKRemoteImageView : UIImageView<RKImageLoaderDelegate>{
	UIActivityIndicatorView *_activity;
	UIActivityIndicatorViewStyle _indicatorStyle;
}

@property (nonatomic) UIActivityIndicatorViewStyle indicatorStyle;

-(id)initWithFrame:(CGRect)frame contentsOfURL:(NSURL *)url;

@end
