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

#import "RKRequest.h"
#import "RKRequestManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
NSString * const RKRequestNetworkError = @"RKRequestNetworkError";
NSString * const RKRequestFileError = @"RKRequestFileError";

@implementation RKRequest

@synthesize delegate = _delegate, receivedData = _data, filePath = _filePath, urlRequest = _request;

-(id) initWithRequest:(NSURLRequest *)request{
	if (request == nil) {
		[NSException raise:@"InvalidArgumentException" format:@"The provided request object can not be nil"];
	}else {
		[self init];
		_request = [request retain];
	}
	return self;
}

-(id) initWithRequest:(NSURLRequest *)request filePath:(NSString *)filePath{
	[self initWithRequest:request];
	if (_filePath == nil) {
		_filePath = @"";
	}else{
		_filePath = [filePath retain];
	}
	return self;
}

-(void) go{
	_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
	[RKRequestManager addOperation:self];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	if (totalBytesExpectedToWrite != 0) {
		if ([_delegate respondsToSelector:@selector(uploadProgressDidUpdate:progress:)]) {
			[_delegate uploadProgressDidUpdate:self progress:(totalBytesWritten/totalBytesExpectedToWrite)];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
}

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	if (_filePath == nil) {
		_data = [[NSMutableData alloc] init];
	}else {
		if ([[response suggestedFilename] rangeOfString:@"unknown"].location != NSNotFound) {
			NSString *fileExtension = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (CFStringRef)[response MIMEType], NULL);
			_tempFileName = [NSString stringWithFormat:@"%@%@%@", [[NSDate date] timeIntervalSince1970], arc4random() % 100000, fileExtension];
			[fileExtension release];
		}else {
			_tempFileName = [[response suggestedFilename] retain];
		}
		_tempFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:_tempFileName] retain];
		
		if ([[NSFileManager defaultManager] createFileAtPath:_tempFilePath contents:nil attributes:nil]) {
			_fileHandle = [[NSFileHandle fileHandleForUpdatingAtPath:_tempFilePath] retain];
			if (!_fileHandle) {
				[self performSelector:@selector(didFail:) withObject:RKRequestFileError];
			}
			[_fileHandle seekToEndOfFile];
		}else {
			[self performSelector:@selector(didFail:) withObject:RKRequestFileError];
		}
	}
	_expectedContentLength = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData{
	if (_filePath == nil) {
		[_data appendData:newData];
	}else {
		[_fileHandle seekToEndOfFile];
		[_fileHandle writeData:newData];
	}
	_downloadedContentLength = _downloadedContentLength + [newData length];
	[self performSelector:@selector(updateProgress)];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[self performSelector:@selector(didFail:) withObject:RKRequestNetworkError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if (_filePath != nil) {
		[_fileHandle closeFile];
		if ((_filePath != nil) && ([_filePath length] > 0)) {
			[[NSFileManager defaultManager] moveItemAtPath:_tempFilePath toPath:_filePath error:nil];
		}else {
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			[[NSFileManager defaultManager] moveItemAtPath:_tempFilePath toPath:[documentsDirectory stringByAppendingPathComponent:[_tempFileName lastPathComponent]] error:nil];
		}
	}
	[self performSelector:@selector(didComplete)];
}

-(void) cancel{
	[_connection cancel];
}

-(NSString *) filePath{
	if ((_filePath == nil) || (![_filePath length] > 0)) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		return [documentsDirectory stringByAppendingPathComponent:_tempFileName];
	}else {
		return _filePath;
	}
}

-(void) dealloc{
	[_tempFilePath release];
	_tempFilePath = nil;
	[_tempFileName release];
	_tempFileName = nil;
	[_fileHandle release];
	_fileHandle = nil;
	[_connection release];
	_connection = nil;
	[_data release];
	_data = nil;
	[_request release];
	_request = nil;
	[_filePath release];
	_filePath = nil;
	[super dealloc];
}

#pragma mark Delegate Methods

-(void)didComplete{
	[RKRequestManager removeOperation:self];
	if ([_delegate respondsToSelector:@selector(requestDidComplete:)]) {
		[_delegate requestDidComplete:self];
	}
}

- (void)updateProgress{
	if (_expectedContentLength != 0) {
		if ([_delegate respondsToSelector:@selector(downloadProgressDidUpdate:progress:)]) {
			[_delegate downloadProgressDidUpdate:self progress:(_downloadedContentLength/_expectedContentLength)];
		}
	}
}

-(void)didFail:(NSString *)error{
	[RKRequestManager removeOperation:self];
	if ([_delegate respondsToSelector:@selector(requestDidFail:error:)]) {
		[_delegate requestDidFail:self error:error];
	}
}



@end
