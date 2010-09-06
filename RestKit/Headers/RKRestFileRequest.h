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
#import "RKRestRequest.h"

/**
 * A specialized RKRestRequest which automatically configures the underlying
 * RKRequest object to automatically download the resulting data/file directly
 * to the file system, bypassing memory.
 */
@interface RKRestFileRequest : RKRestRequest {
	NSString *_filePath;
}

@property (nonatomic, readonly) NSString *filePath;

/**
 * Initializes the request with to a given URL and pre-configured (and 
 * finalized if required) request body. As data is downloaded, data will be 
 * saved directly to the file system, bypassing RAM
 */
-(id) initWithURL:(NSURL *)url requestBody:(RKRequestBody *)request filePath:(NSString *)filePath;

@end
