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

#import "RKRequest.h"
#import "RKRequestBody.h"
#import "RKRequestMultipartBody.h"
#import "RKRestFileRequest.h"
#import "RKRestRequest.h"
#import "RKRequestManager.h"
#import "RKImageLoader.h"
#import "RKImageLoaderRequest.h"
#import "RKImageLoaderResponse.h"

#define RKBaseURL @"http://www.example.com/api/"