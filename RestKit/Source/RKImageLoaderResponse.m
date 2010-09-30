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

#import "RKImageLoaderResponse.h"


@implementation RKImageLoaderResponse

@synthesize filePath = _filePath, url = _url, error = _error, fromCache = _fromCache;

-(id)initWithImage:(NSString *)imageString source:(NSURL *)source fromCache:(BOOL)fromCache{
	[self init];
	_filePath = [imageString retain];
	_url = [source retain];
	_fromCache = fromCache;
	return self;
}

-(id)initWithError:(NSString *)errorString source:(NSURL *)source{
	[self init];
	_error = [errorString retain];
	_url = [source retain];
	return self;
}

-(UIImage *) image{
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:_filePath];
	return [image autorelease];
}

-(BOOL) hasError{
	if (_error == nil) {
		return NO;
	}else {
		return YES;
	}
}

-(NSString *) urlString{
	return [_url absoluteString];
}

-(void)dealloc{
	[super dealloc];
}

@end
