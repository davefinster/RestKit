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

/**
 * A RKRequestBody provides a simple way of attaching parameters and data 
 * to a rest request. This class supports simple text based parameters and 
 * provides a convenience method for booleans.
 */
@interface RKRequestBody : NSObject {
	NSMutableDictionary *_dictionary;
}

/**
 * Provides an NSData version of the parameters specified within the 
 * request body encoded using UTF8 Encoding
 */
@property (readonly) NSData *bodyData;

/**
 * Provides a NSString version of the parameters specified within the 
 * request body
 */
@property (readonly) NSString *bodyString;

/**
 * Adds a field (parameter name) with the specified text value to 
 * the body.
 */
-(void)addField:(NSString *)fieldName text:(NSString *)text;

/**
 * Adds a field (parameter name) with the specified boolean value to 
 * the body. 1 indicates a YES and 0 indicates NO
 */
-(void)addField:(NSString *)fieldName boolean:(BOOL)boolean;

/**
 * Adds a field (parameter name) with the text re-encoded into base 64
 */
-(void)addField:(NSString *)fieldName textToBeConvertedToBase64:(NSString *)text;

/**
 * Adds a field (parameter name) with the data re-encoded into base 64
 */
-(void)addField:(NSString *)fieldName stringDataToBeConvertedToBase64:(NSData *)data;

/**
 * Returns an NSString representation of the provided data re-encoded in Base 64
 */
+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end

