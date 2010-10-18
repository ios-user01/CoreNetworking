//
//  AFHTTPConnection.m
//  CoreNetworking
//
//  Created by Keith Duncan on 29/04/2009.
//  Copyright 2009. All rights reserved.
//

#import "AFHTTPConnection.h"

#import "AFNetworkTransport.h"
#import "AFHTTPMessage.h"
#import "AFHTTPMessagePacket.h"
#import "AFNetworkPacketWrite.h"
#import "AFNetworkPacketWriteFromReadStream.h"

#import "AFNetworkMacros.h"

AFNETWORK_NSSTRING_CONTEXT(_AFHTTPConnectionWriteRequestContext);
AFNETWORK_NSSTRING_CONTEXT(_AFHTTPConnectionWriteResponseContext);

AFNETWORK_NSSTRING_CONTEXT(_AFHTTPConnectionReadRequestContext);
AFNETWORK_NSSTRING_CONTEXT(_AFHTTPConnectionReadResponseContext);

@interface AFHTTPConnection ()
@property (readwrite, retain) NSMutableDictionary *messageHeaders;
@end

#pragma mark -

@implementation AFHTTPConnection

@dynamic delegate;

@synthesize messageHeaders=_messageHeaders;

+ (Class)lowerLayer {
	return [AFNetworkTransport class];
}

+ (AFNetworkInternetTransportSignature)transportSignatureForScheme:(NSString *)scheme {
	if ([scheme compare:AFNetworkSchemeHTTP options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		AFNetworkInternetTransportSignature AFNetworkInternetTransportSignatureHTTP = {
			.type = AFNetworkSocketSignatureInternetTCP,
			.port = 80,
		};
		
		return AFNetworkInternetTransportSignatureHTTP;
	}
	if ([scheme compare:AFNetworkSchemeHTTPS options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		AFNetworkInternetTransportSignature AFNetworkInternetTransportSignatureHTTPS = {
			.type = AFNetworkSocketSignatureInternetTCP,
			.port = 443,
		};
		
		return AFNetworkInternetTransportSignatureHTTPS;
	}
	return [super transportSignatureForScheme:scheme];
}

+ (NSString *)serviceDiscoveryType {
	return @"_http";
}

- (id)init {
	self = [super init];
	if (self == nil) return nil;
	
	_messageHeaders = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dealloc {
	[_messageHeaders release];
	
	[super dealloc];
}

- (void)preprocessRequest:(CFHTTPMessageRef)request {
	if ([NSMakeCollectable(CFHTTPMessageCopyHeaderFieldValue(request, (CFStringRef)AFHTTPMessageContentLengthHeader)) autorelease] == nil) {
		CFHTTPMessageSetHeaderFieldValue(request, (CFStringRef)AFHTTPMessageContentLengthHeader, (CFStringRef)[[NSNumber numberWithUnsignedInteger:[[NSMakeCollectable(CFHTTPMessageCopyBody(request)) autorelease] length]] stringValue]);
	}
	
	for (NSString *currentConnectionHeader in [self.messageHeaders allKeys]) {
		CFHTTPMessageSetHeaderFieldValue(request, (CFStringRef)currentConnectionHeader, (CFStringRef)[self.messageHeaders objectForKey:currentConnectionHeader]);
	}
	
	NSURL *endpoint = [self peer];
	if ([endpoint isKindOfClass:[NSURL class]]) {
		CFHTTPMessageSetHeaderFieldValue(request, (CFStringRef)AFHTTPMessageHostHeader, (CFStringRef)[endpoint absoluteString]);
	}
}

#pragma mark -

- (void)performRequestMessage:(CFHTTPMessageRef)message {
	[self preprocessRequest:message];
	[self performWrite:AFHTTPConnectionPacketForMessage(message) withTimeout:-1 context:&_AFHTTPConnectionWriteRequestContext];
}

- (void)readRequest {
	[self performRead:[[[AFHTTPMessagePacket alloc] initForRequest:YES] autorelease] withTimeout:-1 context:&_AFHTTPConnectionReadRequestContext];
}

- (void)downloadRequest:(NSURL *)location {
	NSParameterAssert([location isFileURL]);
	
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark -

- (void)performResponseMessage:(CFHTTPMessageRef)message {
	[self performWrite:AFHTTPConnectionPacketForMessage(message) withTimeout:-1 context:&_AFHTTPConnectionWriteResponseContext];
}

- (void)readResponse {
	[self performRead:[[[AFHTTPMessagePacket alloc] initForRequest:NO] autorelease] withTimeout:-1 context:&_AFHTTPConnectionReadResponseContext];
}

- (void)downloadResponse:(NSURL *)location {
	NSParameterAssert([location isFileURL]);
	
	AFHTTPMessagePacket *messagePacket = [[[AFHTTPMessagePacket alloc] initForRequest:NO] autorelease];
	[messagePacket setBodyStorage:location];
	[self performRead:messagePacket withTimeout:-1 context:&_AFHTTPConnectionReadResponseContext];
}

#pragma mark -

- (void)networkLayer:(id <AFNetworkTransportLayer>)layer didWrite:(id)data context:(void *)context {
	if (context == &_AFHTTPConnectionWriteRequestContext) {
		// nop
	} else if (context == &_AFHTTPConnectionWriteResponseContext) {
		// nop
	} else if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate networkLayer:self didWrite:data context:context];
	}
}

- (void)networkLayer:(id <AFNetworkTransportLayer>)layer didRead:(id)data context:(void *)context {
	if (context == &_AFHTTPConnectionReadRequestContext) {
		if ([self.delegate respondsToSelector:@selector(connection:didReceiveRequest:)])
			[self.delegate connection:self didReceiveRequest:(CFHTTPMessageRef)data];
	} else if (context == &_AFHTTPConnectionReadResponseContext) {
		if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
			[self.delegate connection:self didReceiveResponse:(CFHTTPMessageRef)data];
	} else if ([self.delegate respondsToSelector:_cmd]) {
		[self.delegate networkLayer:self didRead:data context:context];
	}
}

@end
