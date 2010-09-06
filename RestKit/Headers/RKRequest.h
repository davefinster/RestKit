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

@protocol RKRequestDelegate;

extern NSString * const RKRequestNetworkError;
extern NSString * const RKRequestFileError;

/**
 * A RKRequest serves as a management object for the NSURLConnection class 
 * collecting any data that is returned or streaming the received data 
 * directly to the file system.
 */
@interface RKRequest : NSObject {
	id<RKRequestDelegate> _delegate;
	NSURLConnection *_connection;
	NSURLRequest *_request;
	NSMutableData *_data;
	NSString *_filePath;
	NSString *_tempFilePath;
	NSString *_tempFileName;
	NSFileHandle *_fileHandle;
	double _expectedContentLength;
	double _downloadedContentLength;
	double _progress;
}

/**
 * A delegate which implements RKRequestDelegate. This delegate receives 
 * notifications when data is available for use once the request completes 
 * and if a file is being downloaded, receives progress updates
 */
@property (assign) id<RKRequestDelegate> delegate;

/**
 * Provides access to the data downloaded by the request. Only available 
 * when a file is not being downloaded directly to the file system
 */
@property(nonatomic, readonly) NSData *receivedData;

/**
 * The specified file path of the downloaded file - if any
 */
@property(nonatomic, readonly) NSString *filePath;

/**
 * The underlying NSURLRequest
 */
@property(nonatomic, readonly) NSURLRequest *urlRequest;

/**
 * Initiates a request with received data being retained in memory
 */
-(id) initWithRequest:(NSURLRequest *)request;

/**
 * Initiates a request with received data being delivered directly to 
 * the file system. The filePath argument accepts either a fully qualified
 * file path, to which the resulting file will be downloaded regardless of 
 * original file name, or nil, which will force the request to determine 
 * an appropiate file name. The resulting file name is available in the 
 * filePath property of this request after the transfer is complete.
 */
-(id) initWithRequest:(NSURLRequest *)request filePath:(NSString *)filePath;

/**
 * Starts the request process
 */
-(void) go;

/**
 * Cancels the receiver's network activity
 */
-(void) cancel;

@end

@protocol RKRequestDelegate <NSObject>

@optional

/**
 * Called when the object has completed its network activity. Depending on 
 * the destination of the data, all received data will either be available 
 * from the received property or on the file system
 */
-(void)requestDidComplete:(RKRequest *)request;

/**
 * Called during upload when more data has been sent, thus updating 
 * the progress.
 */
-(void)uploadProgressDidUpdate:(RKRequest *)request progress:(double)progress;

/**
 * Called during download when more data has been received, thus updating 
 * the progress.
 */
-(void)downloadProgressDidUpdate:(RKRequest *)request progress:(double)progress;

/**
 * Called if there is a failure during network activity
 */
-(void)requestDidFail:(RKRequest *)request error:(NSString *)error;

@end
