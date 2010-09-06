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
#import <UIKit/UIKit.h>
#import "RKRequestBody.h"

/**
 * A RKRequestMultipartBody is a specialized version of RKRequestBody 
 * providing support for multiple formats of attached data. This class 
 * supports standard text, images, booleans and files. Using this class 
 * for simple text/booleans only is not as efficient as a RKRequestBody
 * due to the boundaries required in multi-part bodies
 */
@interface RKRequestMultipartBody : RKRequestBody {
	NSString *_boundary;
	NSString *_boundaryString;
	NSString *_boundarySeparator;
	NSMutableData *_data;
	BOOL _hasFinalized;
}

/**
 * The string used to separate the data items (fields) from each other
 */
@property (readonly) NSString *boundary;


/**
 * Adds a field (parameter name) with the specified arbitary data
 */
-(void)addField:(NSString *)fieldName data:(NSData *)data;

/**
 * Adds a field (parameter name) with the specified image value to the 
 * body. The image is converted to a PNG representation and added to body. 
 * The specified filename will be the filename seen by the receiving server
 */
-(void)addField:(NSString *)fieldName image:(UIImage *)image fileName:(NSString *)fileName;

/**
 * Adds a field (parameter name) with the specified file to the body. The 
 * specified filename will be the filename seen by the receiving server
 */
-(void)addField:(NSString *)fieldName filePath:(NSString *)filePath  fileName:(NSString *)fileName;

/**
 * This method appends the final string to indicate the end of the body. This 
 * method should be called once the body is complete and before the body is attached 
 * to an RKRestRequest. If this method is not called before the internal data is used, 
 * the body will be automatically finalized (with a warning issued to console) and 
 * further modification will raise an AlreadyFinalizedException.
 */
-(void)finalizeBody;

@end
