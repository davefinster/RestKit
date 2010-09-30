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

#import "RKImageLoaderRequest.h"
#import "RKImageLoader.h"

@implementation RKImageLoaderRequest

@synthesize url = _url, bypassCache = _bypassCache;

-(id)init{
	self = [super init];
	_delegate = [[NSMutableArray alloc] init];
	return self;
}

-(void)addDelegate:(id<RKImageLoaderDelegate>)delegate{
	for (int i = 0; i < [_delegate count]; i++) {
		if ([_delegate objectAtIndex:i] == delegate) {
			return;
		}
	}
	[_delegate addObject:delegate];
}

-(void)performResponse:(RKImageLoaderResponse *)response{
	for (int i = 0; i < [_delegate count]; i++) {
		[[_delegate objectAtIndex:i] imageDownloaded:response];
		[_delegate removeObjectAtIndex:i];
	}
}

-(void)dealloc{
	[_url release];
	_url = nil;
	[_delegate release];
	_delegate = nil;
	[super dealloc];
}

@end
