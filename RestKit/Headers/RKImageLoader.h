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
#import "RKImageLoaderResponse.h"
#import "RKRequest.h"

@protocol RKImageLoaderDelegate;

extern NSString * const RKImageLoaderDownloadCompleteNotification;

/**
 * The RKImageLoader provides a queueable method of downloading 
 * images asynchronously from the internet. 
 *
 * Cache:
 * RKImageLoader manages an image cache within the documents 
 * directory of the application. The cache folder is called 
 * RestKitImageCache, but can be altered by changing the return 
 * value of cacheDirectory. Inside this directory, a plist
 * containing a serialized NSMutableDictionary exists which 
 * provides mappings between previously accessed URL's and 
 * the resulting file paths. The caching strategy is to 
 * simply save all downloaded images and assumes that if the 
 * same URL is requested, the same image should be returned (ie 
 * it makes the assumption that the image at a given URL does not change).
 * The cache can be manually cleared by calling the clearCache 
 * method.
 */
@interface RKImageLoader : NSObject<RKRequestDelegate>{
	NSMutableArray *_queue;
	RKRequest *_currentRequest;
	NSMutableDictionary *_cacheDatabase;
}

/**
 * Access the default singleton loader object
 */
+(RKImageLoader *)defaultLoader;

+(NSString *)cacheDirectory;
+(NSString *)cacheDatabasePath;

/**
 * Queues the specified url string for download. The delegate object will 
 * be notified once the download has been attempted.
 */
+(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate;
+(void)loadImageFromUrlString:(NSString *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url for download. The delegate object will 
 * be notified once the download has been attempted.
 */
+(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate;
+(void)loadImageFromUrl:(NSURL *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url string for download. The delegate object will 
 * be notified once the download has been attempted.
 */
-(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate;
-(void)loadImageFromUrlString:(NSString *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url for download. The delegate object will 
 * be notified once the download has been attempted.
 */
-(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate;
-(void)loadImageFromUrl:(NSURL *)url bypassCache:(BOOL)bypassCache delegate:(id<RKImageLoaderDelegate>)delegate;
@end

@protocol RKImageLoaderDelegate <NSObject>

@optional

/**
 * Called when the image download attempt has been completed. The 
 * response object will either contain the resulting image's file 
 * path or an error string
 */
-(void)imageDownloaded:(RKImageLoaderResponse *)response;

@end