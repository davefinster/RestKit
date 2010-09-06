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

#import "RKImageLoader.h"
#import "RKImageLoaderRequest.h"
#import "RKImageLoaderResponse.h"

@implementation RKImageLoader

+(RKImageLoader *) defaultLoader{
	static RKImageLoader *loader;
	@synchronized(self){
		if (loader == nil) {
			loader = [[RKImageLoader alloc] init];
		}
	}
	return loader;
}

+(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrlString:url delegate:delegate];
}

+(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrl:url delegate:delegate];
}

-(id)init{
	self = [super init];
	_queue = [[NSMutableArray alloc] init];
	return self;
}

-(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	RKImageLoaderRequest *request = nil;
	for (int i = 0; i < [_queue count]; i++) {
		if ([[(RKImageLoaderRequest *)[_queue objectAtIndex:i] url] isEqualToString:url]) {
			request = [_queue objectAtIndex:i];
		}
	}
	if (request == nil) {
		request = [[RKImageLoaderRequest alloc] init];
		request.url = url;
		[_queue addObject:request];
	}
	[request addDelegate:delegate];
	[self performSelector:@selector(initiateNextRequest)];
}

-(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[self loadImageFromUrlString:[url absoluteString] delegate:delegate];
}

-(void)initiateNextRequest{	
	if (([_queue count] > 0) && (_currentRequest == nil)) {
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[(RKImageLoaderRequest *)[_queue objectAtIndex:0] url]]];
		_currentRequest = [[RKRequest alloc] initWithRequest:request filePath:nil];
		_currentRequest.delegate = self;
		[request release];
		[_currentRequest go];
	}
}

-(void)requestDidComplete:(RKRequest *)request{
	RKImageLoaderResponse *response = [[RKImageLoaderResponse alloc] initWithImage:request.filePath source:[request.urlRequest URL]];
	[request autorelease];
	_currentRequest = nil;
	[self performSelector:@selector(performResponse:) withObject:response];
	[response release];
}

-(void)requestDidFail:(RKRequest *)request error:(NSString *)error{
	RKImageLoaderResponse *response = [[RKImageLoaderResponse alloc] initWithError:error source:[request.urlRequest URL]];
	[request autorelease];
	_currentRequest = nil;
	[self performSelector:@selector(performResponse:) withObject:response];
	[response release];
}

-(void)performResponse:(RKImageLoaderResponse *)response{
	[(RKImageLoaderRequest *)[_queue objectAtIndex:0] performResponse:response];
	[_queue removeObjectAtIndex:0];
	if ([_queue count] > 0) {
		[self performSelector:@selector(initiateNextRequest)];
	}
}

-(void)dealloc{
	[_currentRequest release];
	_currentRequest = nil;
	[_queue release];
	_queue = nil;
	[super dealloc];
}

@end
