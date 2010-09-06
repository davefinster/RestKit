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

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

#import "RKRequestBody.h"


@implementation RKRequestBody

-(id) init{
	self = [super init];
	_dictionary = [[NSMutableDictionary alloc] init];
	return self;
}

-(void)addField:(NSString *)fieldName text:(NSString *)text{
	[_dictionary setValue:text forKey:fieldName];
}

-(void)addField:(NSString *)fieldName textToBeConvertedToBase64:(NSString *)text{
	NSData *stringData = [text dataUsingEncoding:NSUTF8StringEncoding];
	[self addField:fieldName stringDataToBeConvertedToBase64:stringData];
}

-(void)addField:(NSString *)fieldName stringDataToBeConvertedToBase64:(NSData *)data{
	[_dictionary setValue:[RKRequestBody base64StringFromData:data length:[data length]] forKey:fieldName];
}

-(void)addField:(NSString *)fieldName boolean:(BOOL)boolean{
	if (boolean) {
		[_dictionary setValue:@"1" forKey:fieldName];
	}else {
		[_dictionary setValue:@"0" forKey:fieldName];
	}
}

-(NSData *) bodyData{
	return [self.bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *) bodyString{
	NSMutableString *mutable = [[NSMutableString alloc] init];
	NSArray *fieldNames = [_dictionary allKeys];
	for (int i = 0; i < [fieldNames count]; i++) {
		if (i != 0) {
			[mutable appendFormat:@"&"];
		}
		[mutable appendFormat:@"%@=%@", [fieldNames objectAtIndex:i], [_dictionary valueForKey:[fieldNames objectAtIndex:i]]];
	}
	return [mutable autorelease];
}

-(void) dealloc{
	[_dictionary release];
	_dictionary = nil;
	[super dealloc];
}

+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
	int lentext = [data length]; 
	if (lentext < 1) return @"";
	
	char *outbuf = malloc(lentext*4/3+4); // add 4 to be sure
	
	if ( !outbuf ) return nil;
	
	const unsigned char *raw = [data bytes];
	
	int inp = 0;
	int outp = 0;
	int do_now = lentext - (lentext%3);
	
	for ( outp = 0, inp = 0; inp < do_now; inp += 3 )
	{
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		outbuf[outp++] = base64EncodingTable[raw[inp+2] & 0x3F];
	}
	
	if ( do_now < lentext )
	{
		char tmpbuf[2] = {0,0};
		int left = lentext%3;
		for ( int i=0; i < left; i++ )
		{
			tmpbuf[i] = raw[do_now+i];
		}
		raw = tmpbuf;
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		if ( left == 2 ) outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
	}
	
	NSString *ret = [[[NSString alloc] initWithBytes:outbuf length:outp encoding:NSASCIIStringEncoding] autorelease];
	free(outbuf);
	
	return ret;
}

@end
