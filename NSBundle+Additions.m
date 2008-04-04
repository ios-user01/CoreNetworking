//
//  NSBundle+Additions.m
//  dawn
//
//  Created by Keith Duncan on 16/10/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSBundle+Additions.h"

#import <objc/runtime.h>

@implementation NSBundle (Additions)

NSImage *KDCacheImageFromBundle(NSBundle *bundle, NSString *name) {
	NSImage *bundleImage = nil;
	NSString *imageName = [bundle objectForInfoDictionaryKey:name];
	
	bundleImage = [NSImage imageNamed:imageName];
	if (bundleImage != nil) return bundleImage;
	
	bundleImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:imageName]];
	[bundleImage setName:imageName];
	
	return bundleImage;
}

- (NSImage *)alertImage {
	return KDCacheImageFromBundle(self, AFAlertImageNameKey);
}

- (NSImage *)bundleImage {
	return KDCacheImageFromBundle(self, @"CFBundleIconFile");
}

- (NSString *)version {
	return [self objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)displayVersion {
	return [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)name {
	return [self objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)displayName {
	return [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSString *)companyName {
	return [self objectForInfoDictionaryKey:AFCompanyNameKey];
}

- (NSString *)companySite {
	return [self objectForInfoDictionaryKey:AFCompanySiteKey];
}

@end

@implementation NSBundle (PathAdditions)

- (NSString *)applicationSupportPath:(NSUInteger)domain {
	return [KDSafeObjectAtIndex(NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, domain, YES), 0) stringByAppendingPathComponent:[self name]];
}

@end

NSString *const AFAlertImageNameKey = @"AFAlertImageName";
NSString *const AFCompanyNameKey = @"AFCompanyName";
NSString *const AFCompanySiteKey = @"AFCompanySite";
