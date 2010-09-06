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

#import "RKRestRequest.h"
#import "RKRequestMultipartBody.h"

NSString * const RKRestRequestGet = @"GET";
NSString * const RKRestRequestPost = @"POST";
NSString * const RKRestRequestPut = @"PUT";
NSString * const RKRestRequestDelete = @"DELETE";
NSString * const RKRestRequestUploadProgressUpdateNotification = @"RKRestRequestUploadProgressUpdateNotification";
NSString * const RKRestRequestDownloadProgressUpdateNotification = @"RKRestRequestDownloadProgressUpdateNotification";
NSString * const RKRestRequestDidCompleteNotification = @"RKRestRequestDidCompleteNotification";

@implementation RKRestRequest

@synthesize requestMethod=_requestMethod, delegate=_delegate, generateNotifications=_generateNotifications, uploadProgress = _uploadProgress, downloadProgress = _downloadProgress;

-(id) initWithURL:(NSURL *)url requestBody:(RKRequestBody *)body{
	[self init];
	_url = [url retain];
	_body = [body retain];
	_requestMethod = RKRestRequestGet;
	return self;
}

-(void) prepareUrlForRequestMethod{
	if (_body != nil) {
		if (([_requestMethod isEqualToString:RKRestRequestGet]) || ([_requestMethod isEqualToString:RKRestRequestDelete])) {
			NSURL *modifiedUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?%@", [_url absoluteURL], _body.bodyString]];
			[_url release];
			_url = modifiedUrl;
		}
	}
}

-(void) go{
	if (_requestMethod == nil) {
		[NSException raise:@"InvalidArgumentException" format:@"Request method can not be nil"];
	}else {
		[self performSelector:@selector(prepareUrlForRequestMethod)];
		_urlRequest = [[NSMutableURLRequest alloc] initWithURL:_url];
		[_urlRequest setHTTPMethod:_requestMethod];
		[_urlRequest setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
		if ([_body isMemberOfClass:[RKRequestMultipartBody class]]) {
			[_urlRequest addValue:[(RKRequestMultipartBody *)_body boundary] forHTTPHeaderField:@"Content-Type"];
		}
		if (_body != nil) {
			if (([_requestMethod isEqualToString:RKRestRequestPost]) || ([_requestMethod isEqualToString:RKRestRequestPut])) {
				[_urlRequest setHTTPBody:_body.bodyData];
			}
		}
		_request = [[RKRequest alloc] initWithRequest:_urlRequest];
		_request.delegate = self;
		[_request go];
	}
}

-(NSData *)receivedData{
	return _request.receivedData;
}

-(void)dealloc{
	[_urlRequest release];
	_urlRequest = nil;
	[_url release];
	_url = nil;
	[_request release];
	_request = nil;
	[_body release];
	_body = nil;
	[super dealloc];
}

#pragma mark RKRequest Delegate
-(void)requestDidComplete:(RKRequest *)request{
	if ([_delegate respondsToSelector:@selector(requestDidComplete:)]) {
		[_delegate requestDidComplete:self];
	}
}

-(void)uploadProgressDidUpdate:(RKRequest *)request progress:(double)progress{
	_uploadProgress = progress;
	if (_generateNotifications) {
		[[NSNotificationCenter defaultCenter] postNotificationName:RKRestRequestUploadProgressUpdateNotification object:self];
	}
	if ([_delegate respondsToSelector:@selector(uploadProgressDidUpdate:progress:)]) {
		[_delegate uploadProgressDidUpdate:self progress:_uploadProgress];
	}
}

-(void)downloadProgressDidUpdate:(RKRequest *)request progress:(double)progress{
	_downloadProgress = progress;
	if (_generateNotifications) {
		[[NSNotificationCenter defaultCenter] postNotificationName:RKRestRequestDownloadProgressUpdateNotification object:self];
	}
	if ([_delegate respondsToSelector:@selector(downloadProgressDidUpdate:progress:)]) {
		[_delegate downloadProgressDidUpdate:self progress:_downloadProgress];
	}
}

-(void)requestDidFail:(RKRequest *)request error:(NSString *)error{
	if ([_delegate respondsToSelector:@selector(requestDidFail:error:)]) {
		[_delegate requestDidFail:self error:error];
	}
}

@end
