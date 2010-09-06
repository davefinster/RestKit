//
//  RKRequestManager.m
//  Receipter
//
//  Created by Dave Finster on 13/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RKRequestManager.h"

NSString * const RKRequestManagerOperationAddedNotification = @"RKRequestManagerOperationAddedNotification";
NSString * const RKRequestManagerOperationRemovedNotification = @"RKRequestManagerOperationRemovedNotification";

@implementation RKRequestManager

+(RKRequestManager *) defaultManager{
	static RKRequestManager *manager;
	@synchronized(self){
		if (manager == nil) {
			manager = [[RKRequestManager alloc] init];
		}
	}
	return manager;
}

-(id)init{
	self = [super init];
	_operations = [[NSMutableArray alloc] init];
	return self;
}

+(NSArray *) currentOperations{
	return [[RKRequestManager defaultManager] currentOperations];
}

-(NSArray *) currentOperations{
	return _operations;
}

+(void) addOperation:(RKRequest *)request{
	[[RKRequestManager defaultManager] addOperation:request];
}

-(void) addOperation:(RKRequest *)request{
	[_operations addObject:request];
	[[NSNotificationCenter defaultCenter] postNotificationName:RKRequestManagerOperationAddedNotification object:request];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+(void) removeOperation:(RKRequest *)request{
	[[RKRequestManager defaultManager] removeOperation:request];
}

-(void) removeOperation:(RKRequest *)request{
	[_operations removeObject:request];
	if ([_operations count] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:RKRequestManagerOperationRemovedNotification object:request];
}

-(void)dealloc{
	[_operations release];
	_operations = nil;
	[super dealloc];
}

@end
