//
//  AFNetworkServicePublisher.h
//  CoreNetworking
//
//  Created by Keith Duncan on 12/10/2011.
//  Copyright (c) 2011 Keith Duncan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreNetworking/AFNetworkService-Constants.h"

#import "CoreNetworking/AFNetwork-Macros.h"

@class AFNetworkServiceScope;
@class AFNetworkServicePublisher;
@class AFNetworkServiceSource;
@class AFNetworkSchedule;

@protocol AFNetworkServicePublisherDelegate <NSObject>

 @required

- (void)networkServicePublisher:(AFNetworkServicePublisher *)networkServicePublisher didReceiveError:(NSError *)error;

 @optional

- (void)networkServicePublisher:(AFNetworkServicePublisher *)networkServicePublisher didPublishScope:(AFNetworkServiceScope *)scope;

- (void)networkServicePublisher:(AFNetworkServicePublisher *)networkServicePublisher didRemoveScope:(AFNetworkServiceScope *)scope;

@end

/*!
	\brief
	Publishes (DNS Update) an SRV record for a service and maintains the ephemeral records such as PTR, also allowing for additional records to be associated with the service name such as TXT and NULL records.
 */
@interface AFNetworkServicePublisher : NSObject {
 @private
	AFNetworkServiceScope *_serviceScope;
	uint32_t _port;
	NSMapTable *_recordToDataMap;
	
	id <AFNetworkServicePublisherDelegate> _delegate;
	
	AFNetworkSchedule *_schedule;
	
	void *_service;
	AFNetworkServiceSource *_serviceSource;
	NSMapTable *_recordToHandleMap;
	
	NSMutableSet *_scopes;
}

/*!
	\brief
	Designated initialiser.
	
	\param port
	Port number in host byte order.
 */
- (id)initWithServiceScope:(AFNetworkServiceScope *)serviceScope port:(uint32_t)port;

/*
	Scheduling
 */

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

- (void)scheduleInQueue:(dispatch_queue_t)queue;

/*
 
 */

/*!
	\brief
	Updates are delivered in the scheduled environment.
 */
@property (assign, nonatomic) id <AFNetworkServicePublisherDelegate> delegate;

/*!
	\brief
	Record data is accumulated until the receiver is published.
 */
- (void)publishData:(NSData *)data forRecord:(AFNetworkDomainRecordType)record;

/*!
	\brief
	Stop publishing data for a specific record.
 */
- (void)removeDataForRecord:(AFNetworkDomainRecordType)record;

/*!
	\brief
	Receiver must be scheduled before receiving this message.
 */
- (void)publish;

/*!
	\brief
	Remove all published records.
 */
- (void)invalidate;

@end
