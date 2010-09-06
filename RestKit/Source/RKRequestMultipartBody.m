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

#import "RKRequestMultipartBody.h"
@implementation RKRequestMultipartBody

@synthesize boundary = _boundaryString;

-(id)init{
	self = [super init];
	_data = [[NSMutableData alloc] init];
	_boundary = [[NSString alloc] initWithString:[[NSProcessInfo processInfo] globallyUniqueString]];
	_boundaryString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", _boundary];
	_boundarySeparator = [[NSString alloc] initWithFormat:@"--%@\r\n", _boundary];
	_hasFinalized = NO;
	return self;
}

-(NSData *) bodyData{
	if (!_hasFinalized) {
		[self finalizeBody];
		NSLog(@"RKRequestMultipartBody used without being finalized. Finalization performed automatically");
	}
	return _data;
}

-(NSString *) bodyString{
	if (!_hasFinalized) {
		[self finalizeBody];
		NSLog(@"RKRequestMultipartBody used without being finalized. Finalization performed automatically");
	}
	return [super bodyString];
}

-(void)addField:(NSString *)fieldName data:(NSData *)data{
	if (!_hasFinalized) {
		NSString *formDataName = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName];
		NSString *formDataValue = [[NSString alloc] initWithFormat:@"\r\n"];
		[_data appendData:[_boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[formDataName dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:data];
		[_data appendData:[formDataValue dataUsingEncoding:NSUTF8StringEncoding]];
		[formDataName release];
		[formDataValue release];
	}else {
		[self performSelector:@selector(finalizeError)];
	}
}

-(void)addField:(NSString *)fieldName textToBeConvertedToBase64:(NSString *)text{
	NSData *stringData = [text dataUsingEncoding:NSUTF8StringEncoding];
	[self addField:fieldName stringDataToBeConvertedToBase64:stringData];
}

-(void)addField:(NSString *)fieldName stringDataToBeConvertedToBase64:(NSData *)data{
	NSString *converted = [RKRequestBody base64StringFromData:data length:[data length]];
	[self addField:fieldName text:converted];
}

-(void)addField:(NSString *)fieldName text:(NSString *)text{
	if (!_hasFinalized) {
		NSString *formDataName = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldName];
		NSString *formDataValue = [[NSString alloc] initWithFormat:@"%@\r\n", text];
		[_data appendData:[_boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[formDataName dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[formDataValue dataUsingEncoding:NSUTF8StringEncoding]];
		[formDataName release];
		[formDataValue release];
	}else {
		[self performSelector:@selector(finalizeError)];
	}
}

-(void)addField:(NSString *)fieldName image:(UIImage *)image fileName:(NSString *)fileName{
	if (!_hasFinalized) {
		[_data appendData:[_boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:UIImagePNGRepresentation(image)];
		[_data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}else {
		[self performSelector:@selector(finalizeError)];
	}
}

-(void)addField:(NSString *)fieldName boolean:(BOOL)boolean{
	if (!_hasFinalized) {
		if (boolean) {
			[self addField:fieldName text:@"1"];
		}else {
			[self addField:fieldName text:@"0"];
		}
	}else {
		[self performSelector:@selector(finalizeError)];
	}
}

-(void)addField:(NSString *)fieldName filePath:(NSString *)filePath  fileName:(NSString *)fileName{
	if (!_hasFinalized) {
		[_data appendData:[_boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filePath, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
		[_data appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
		[_data appendData:fileData];
		[fileData release];
		[_data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	}else {
		[self performSelector:@selector(finalizeError)];
	}
}

-(void)finalizeError{
	[NSException raise:@"AlreadyFinalizedException" format:@"RKRequestMultipartBody can not be modified after finalization"];
}

-(void)finalizeBody{
	_hasFinalized = YES;
	[_data appendData:[[NSString stringWithFormat:@"--%@--\r \n",_boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)dealloc{
	[_boundary release];
	_boundary = nil;
	[_boundaryString release];
	_boundaryString = nil;
	[_boundarySeparator release];
	_boundarySeparator = nil;
	[_data release];
	_data = nil;
	[super dealloc];
}

@end
