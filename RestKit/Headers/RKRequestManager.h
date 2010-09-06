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
#import "RKRequest.h"

extern NSString * const RKRequestManagerOperationAddedNotification;
extern NSString * const RKRequestManagerOperationRemovedNotification;

/**
 * RKRequestManager acts as a central authority on all 
 * active network operations being carried out by RestKit.
 * All RKRequest objects are automatically registered here when 
 * network activity begins and de-registered once they have 
 * completed network operation, but before their delegate 
 * completion methods are called.
 */
@interface RKRequestManager : NSObject {
	NSMutableArray *_operations;
}

/**
 * Retrieve the central manager
 */
+(RKRequestManager *) defaultManager;

/**
 * Retrieve an array of all active RKRequests
 */
+(NSArray *) currentOperations;
-(NSArray *) currentOperations;

/**
 * Add a new RKRequest to the manager for tracking. This 
 * generates a RKRequestManagerOperationAddedNotification which 
 * attaches the operation being added to its object parameter.
 */
+(void) addOperation:(RKRequest *)request;
-(void) addOperation:(RKRequest *)request;

/**
 * Remove a completed RKRequest from the manager. This 
 * generates a RKRequestManagerOperationRemovedNotification which 
 * attaches the operation being removed to its object parameter.
 */
+(void) removeOperation:(RKRequest *)request;
-(void) removeOperation:(RKRequest *)request;
@end
