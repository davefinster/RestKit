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
#import "RKRequest.h"
#import "RKRequestBody.h"

@protocol RKRestRequestDelegate;

typedef enum {
    RKRestRequestGet,
    RKRestRequestPost,
    RKRestRequestPut,
	RKRestRequestDelete
} RKRestRequestMethod;

extern NSString * const RKRestRequestUploadProgressUpdateNotification;
extern NSString * const RKRestRequestDownloadProgressUpdateNotification;
extern NSString * const RKRestRequestDidCompleteNotification;
extern NSString * const RKRestRequestBackgroundTimeoutError;

/**
 * A RKRestRequest provides enhanced functionality above the RKRequest 
 * class allowing the creation and configuration of the request. This 
 * class also manages how the parameters are added to the request according 
 * to the method (GET, POST, PUT, DELETE). RKRestRequest also provides 
 * a facility to generate notifications as to the progress of the upload and download 
 * phases.
 */
@interface RKRestRequest : NSObject<RKRequestDelegate>{
	id<RKRestRequestDelegate> _delegate;
	RKRequest *_request;
	RKRequestBody *_body;
	NSMutableURLRequest *_urlRequest;
	NSURL *_url;
	RKRestRequestMethod _requestMethod;
	double _uploadProgress;
	double _downloadProgress;
	BOOL _generateNotifications;
	BOOL _attemptBackgroundOperation;
	NSUInteger _backgroundTaskIdentifier;
}

/**
 * A delegate which implements RKRestRequestDelegate. This delegate receives 
 * notifications when data is available for use once the request completes 
 * and if a file is being downloaded, receives progress updates 
 */
@property(assign) id<RKRestRequestDelegate> delegate;

/**
 * Specifies the REST operation (GET, POST, DELETE, PUT) that the request 
 * is to perform. 
 * Valid values are RKRestRequestGet, RKRestRequestPost, RKRestRequestDelete, 
 * RKRestRequestPut
 * Default method is RKRestRequestGet
 */
@property(nonatomic) RKRestRequestMethod requestMethod;

/**
 * Specifies whether this request should generate NSNotification objects 
 * during its network activity to indicate changes in progress
 */
@property BOOL generateNotifications;

/**
 * Specifies the progress of the upload phase of the request
 */
@property double uploadProgress;

/**
 * Specifies the progress of the download phase of the request
 */
@property double downloadProgress;

/**
 * Provides access to the data downloaded by the request. Only available 
 * when a file is not being downloaded directly to the file system
 */
@property (nonatomic, readonly) NSData *receivedData;

/**
 * By default set to NO - When set to YES, the REST request will attempt 
 * to register itself as a background task before executing. This allows 
 * the user to leave the app while the request is still running. If the 
 * request runs out of time before being terminated by the OS, a final 
 * requestDidFail message will be sent to the delegate. If you are running 
 * background operations, ensure that this method is very lightweight, 
 * otherwise there is the risk of the app being terminated. A timeout 
 * error is indicated by the passing of RKRestRequestBackgroundTimeoutError 
 * as the error argument to requestDidFail.
 */
@property BOOL attemptBackgroundOperation;

/**
 * Initializes the request with to a given URL and pre-configured (and 
 * finalized if required) request body.
 */
-(id) initWithURL:(NSURL *)url requestBody:(RKRequestBody *)request;

/**
 * Instructs the request to initiate network operations
 */
-(void) go;

@end

@protocol RKRestRequestDelegate <NSObject>

@optional

/**
 * Called when the object has completed its network activity. Depending on 
 * the destination of the data, all received data will either be available 
 * from the received property or on the file system
 */
-(void)requestDidComplete:(RKRestRequest *)request;

/**
 * Called during upload when more data has been sent, thus updating 
 * the progress.
 */
-(void)uploadProgressDidUpdate:(RKRestRequest *)request progress:(double)progress;

/**
 * Called during download when more data has been received, thus updating 
 * the progress.
 */
-(void)downloadProgressDidUpdate:(RKRestRequest *)request progress:(double)progress;

/**
 * Called if there is a failure during network activity
 */
-(void)requestDidFail:(RKRestRequest *)request error:(NSString *)error;

@end
