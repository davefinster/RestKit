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

#import "RKRestFileRequest.h"

@implementation RKRestFileRequest

@synthesize filePath = _filePath;

-(id) initWithURL:(NSURL *)url requestBody:(RKRequestBody *)request filePath:(NSString *)filePath{
	[self initWithURL:url requestBody:request];
	_filePath = [filePath retain];
	return self;
}

-(void) go{
	[self performSelector:@selector(configureBackgroundTask)];
	[self performSelector:@selector(prepareUrlForRequestMethod)];
	_urlRequest = [[NSMutableURLRequest alloc] initWithURL:_url];
	[self performSelector:@selector(setURLRequestMethod:) withObject:_urlRequest];
	if ((_requestMethod == RKRestRequestPost) || (_requestMethod == RKRestRequestPut)) {
		[_urlRequest setHTTPBody:_body.bodyData];
	}
	_request = [[RKRequest alloc] initWithRequest:_urlRequest filePath:_filePath];
	_request.delegate = self;
	[_request go];
}

-(NSString *)filePath{
	return _request.filePath;
}

-(void)dealloc{
	[_filePath release];
	_filePath = nil;
	[super dealloc];
}

@end
