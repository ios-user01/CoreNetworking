//
//  AFPacketQueue.h
//  Amber
//
//  Created by Keith Duncan on 02/04/2009.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
	\brief
	The intended usage is that you add packets using `-enqueuePacket:`.
	You observe the `currentWritePacket` property to learn when there's a new packet to process.
	Then call `-dequeuePacket` once you've finished processing the `currentPacket`.
 */
@interface AFNetworkPacketQueue : NSObject {
 @private
	NSMutableArray *_packets;
	id _currentPacket;
}

/*!
	\brief
	Accommodates for the packet shifted into the `currentPacket` position too.
 */
- (NSUInteger)count;

/*!
	\brief
	Appends to the internal ordered collection.
 */
- (void)enqueuePacket:(id)packet;

/*!
	\brief
	This property will change when a packet is dequeued, you can observe it to determine when there is work to be done.
 */
@property (readonly, retain, nonatomic) id currentPacket;

/*!
	\brief
	Call this method to shift a packet out of the queue into the currentPacket position.
	If the queue is empty, or there is already a `currentPacket` this method returns false. 
	
	\return
	(self.currentPacket != nil)
 */
- (BOOL)tryDequeue;

/*!
	\brief
	Should be called once you have processed the `currentPacket` to allow another to be shifted into the `currentPacket` position.
 */
- (void)dequeued;

/*!
	\brief
	First removes all queued packets, then calls `-dequeuePacket`. This ensures that when terminating, you can flush the queue, without starting a new packet.
 */
- (void)emptyQueue;

@end
