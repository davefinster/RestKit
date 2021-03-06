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

#import "RKRemoteImageView.h"

@implementation RKRemoteImageView

@synthesize indicatorStyle = _indicatorStyle;
@synthesize imageURL = _imageURL;
@synthesize bypassCache = _bypassCache;

-(id)initWithFrame:(CGRect)frame contentsOfURL:(NSURL *)url{
	self = [super initWithFrame:frame];
	_indicatorStyle = UIActivityIndicatorViewStyleGray;
	if(url != nil){
		_imageURL = [url retain];
		[RKImageLoader loadImageFromUrl:url delegate:self];
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame contentsOfURL:(NSURL *)url bypassCache:(BOOL)bypassCache{
	self = [self initWithFrame:frame contentsOfURL:url];
	self.bypassCache = bypassCache;
	return self;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	if (_activity == nil) {
		_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:_indicatorStyle];
		_activity.center = self.center;
		_activity.hidesWhenStopped = YES;
		[self addSubview:_activity];
	}
	if ((self.image == nil) && (self._imageURL != nil)){
		[_activity startAnimating];
	}
}

-(void)imageDownloaded:(RKImageLoaderResponse *)response{
	[_activity stopAnimating];
	self.image = response.image;
}

-(void)setImageURL:(NSURL *)url{
	[_imageURL release];
	_imageURL = [url retain];
	[RKImageLoader loadImageFromUrl:_imageURL delegate:self];
	[_activity startAnimating];
}

-(void)dealloc{
	[_imageURL release];
	_imageURL = nil;
	[_activity release];
	_activity = nil;
	[super dealloc];
}

@end
