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
 */
@interface RKImageLoader : NSObject<RKRequestDelegate>{
	NSMutableArray *_queue;
	RKRequest *_currentRequest;
}

/**
 * Access the default singleton loader object
 */
+(RKImageLoader *)defaultLoader;

/**
 * Queues the specified url string for download. The delegate object will 
 * be notified once the download has been attempted.
 */
+(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url for download. The delegate object will 
 * be notified once the download has been attempted.
 */
+(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url string for download. The delegate object will 
 * be notified once the download has been attempted.
 */
-(void)loadImageFromUrlString:(NSString *)url delegate:(id<RKImageLoaderDelegate>)delegate;

/**
 * Queues the specified url for download. The delegate object will 
 * be notified once the download has been attempted.
 */
-(void)loadImageFromUrl:(NSURL *)url delegate:(id<RKImageLoaderDelegate>)delegate;

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