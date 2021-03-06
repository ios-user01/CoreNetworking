//
//  AFPacketQueue.m
//  Amber
//
//  Created by Keith Duncan on 02/04/2009.
//  Copyright 2009. All rights reserved.
//

#import "AFNetworkPacketQueue.h"

@interface AFNetworkPacketQueue ()
@property (retain, nonatomic) NSMutableArray *packets;
@property (readwrite, retain, nonatomic) id currentPacket;
@end

@implementation AFNetworkPacketQueue

@synthesize packets=_packets;
@synthesize currentPacket=_currentPacket;

- (id)init {
	self = [super init];
	if (self == nil) return nil;
	
	_packets = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc {
	[_packets release];
	[_currentPacket release];
	
	[super dealloc];
}

- (NSUInteger)count {
	NSUInteger count = [self.packets count];
	if (self.currentPacket != nil) count++;
	return count;
}

- (void)enqueuePacket:(id)packet {
	[self.packets addObject:packet];
}

- (BOOL)tryDequeue {
	if (self.currentPacket != nil) return NO;
	if ([self.packets count] == 0) return NO;
	
	// Note: the order of execution here is crucial, don't change it
	
	NSUInteger newPacketIndex = 0;
	
	id newPacket = [[self.packets objectAtIndex:newPacketIndex] retain];
	
	[self.packets removeObjectAtIndex:newPacketIndex];
	self.currentPacket = newPacket;
	
	[newPacket release];
	
	return YES;
}

- (void)dequeued {
	self.currentPacket = nil;
}

- (void)emptyQueue {
	[self.packets removeAllObjects];
	[self dequeued];
}

@end
