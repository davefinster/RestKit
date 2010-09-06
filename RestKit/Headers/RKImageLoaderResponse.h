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


@interface RKImageLoaderResponse : NSObject {
	NSString *_filePath;
	NSURL *_url;
	NSString *_error;
}

@property (readonly) UIImage *image;
@property (readonly) NSString *filePath;
@property (readonly) NSString *urlString;
@property (readonly) NSURL *url;
@property (readonly) BOOL hasError;
@property (readonly) NSString *error;

-(id)initWithImage:(NSString *)imageString source:(NSURL *)source;
-(id)initWithError:(NSString *)errorString source:(NSURL *)source;

@end
