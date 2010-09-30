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

+(NSString *)documentsDirectory{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString *)cacheDirectory{
	BOOL isDir = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:[[RKImageLoader documentsDirectory] stringByAppendingPathComponent:@"RestKitImageCache"] isDirectory:&isDir]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[[RKImageLoader documentsDirectory] stringByAppendingPathComponent:@"RestKitImageCache"] withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return [[RKImageLoader documentsDirectory] stringByAppendingPathComponent:@"RestKitImageCache"];
}

+(NSString *)cacheDatabasePath{
	return [[RKImageLoader cacheDirectory] stringByAppendingPathComponent:@"CacheDatabase.plist"];	
}

-(void)clearCache{
	NSString *cachePath = [RKImageLoader cacheDirectory];
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
	for (int i = 0; i < [items count]; i++) {
		if (![[items objectAtIndex:i] isEqualToString:@"CacheDatabase.plist"]) {
			[[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:[items objectAtIndex:i]] error:nil];
		}
	}
	[_cacheDatabase removeAllObjects];
}

+(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrlString:url delegate:delegate];
}

+(void)loadImageFromUrlString:(NSString *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrlString:url bypassCache:bypassCache delegate:delegate];
}

+(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrl:url delegate:delegate];
}

+(void)loadImageFromUrl:(NSURL *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate{
	[[RKImageLoader defaultLoader] loadImageFromUrl:url bypassCache:bypassCache delegate:delegate];
}

-(id)init{
	self = [super init];
	_queue = [[NSMutableArray alloc] init];
	_cacheDatabase = [[NSMutableDictionary alloc] initWithContentsOfFile:[RKImageLoader cacheDatabasePath]];
	if (_cacheDatabase == nil) {
		_cacheDatabase = [[NSMutableDictionary alloc] init];
	}else {
		NSArray *keys = [_cacheDatabase allKeys];
		for (int i = 0; i < [keys count]; i++) {
			BOOL isDir;
			if (![[NSFileManager defaultManager] fileExistsAtPath:[_cacheDatabase valueForKey:[keys objectAtIndex:i]] isDirectory:&isDir]) {
				[_cacheDatabase removeObjectForKey:[keys objectAtIndex:i]];
			}
		}
	}
	return self;
}

-(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[self loadImageFromUrlString:url bypassCache:NO delegate:delegate];
}

-(void)loadImageFromUrlString:(NSString *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate{
	RKImageLoaderRequest *request = nil;
	for (int i = 0; i < [_queue count]; i++) {
		if ([[(RKImageLoaderRequest *)[_queue objectAtIndex:i] url] isEqualToString:url]) {
			request = [_queue objectAtIndex:i];
		}
	}
	if (request == nil) {
		request = [[RKImageLoaderRequest alloc] init];
		request.url = url;
		request.bypassCache = bypassCache;
		[_queue addObject:request];
	}
	[request addDelegate:delegate];
	[self performSelector:@selector(initiateNextRequest)];
}

-(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate{
	[self loadImageFromUrl:url bypassCache:NO delegate:delegate];
}

-(void)loadImageFromUrl:(NSURL *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate{
	[self loadImageFromUrlString:[url absoluteString] bypassCache:bypassCache delegate:delegate];
}

-(void)initiateNextRequest{	
	if (([_queue count] > 0) && (_currentRequest == nil)) {
		NSString *url = [(RKImageLoaderRequest *)[_queue objectAtIndex:0] url];
		if (([[_cacheDatabase allKeys] containsObject:url]) && (![[_queue objectAtIndex:0] bypassCache])) {
			NSLog(@"Served from cache");
			RKImageLoaderResponse *response = [[RKImageLoaderResponse alloc] initWithImage:[_cacheDatabase valueForKey:url] source:[NSURL URLWithString:url] fromCache:YES];
			[self performSelector:@selector(performResponse:) withObject:response];
			[response release];
		}else {
			NSLog(@"Downloaded file");
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[(RKImageLoaderRequest *)[_queue objectAtIndex:0] url]]];
			_currentRequest = [[RKRequest alloc] initWithRequest:request filePath:nil];
			_currentRequest.delegate = self;
			[request release];
			[_currentRequest go];
		}
	}
}

-(void)requestDidComplete:(RKRequest *)request{
	NSString *destinationPath = [[RKImageLoader cacheDirectory] stringByAppendingPathComponent:[request.filePath lastPathComponent]];
	[[NSFileManager defaultManager] moveItemAtPath:request.filePath toPath:destinationPath error:nil];
	RKImageLoaderResponse *response = [[RKImageLoaderResponse alloc] initWithImage:destinationPath source:[request.urlRequest URL] fromCache:NO];
	[_cacheDatabase setValue:destinationPath forKey:[[request.urlRequest URL] absoluteString]];
	[_cacheDatabase writeToFile:[RKImageLoader cacheDatabasePath] atomically:YES];
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
	[_cacheDatabase release];
	_cacheDatabase = nil;
	[_currentRequest release];
	_currentRequest = nil;
	[_queue release];
	_queue = nil;
	[super dealloc];
}

@end
