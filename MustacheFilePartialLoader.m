//
//  MustacheFilePartialLoader.m
//  OCMustache
//
//  Created by Wesley Moore on 4/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheFilePartialLoader.h"

@interface MustacheFilePartialLoader (Private)

- (NSURL *)partialURLWithName:(NSString *)name;

@end


@implementation MustacheFilePartialLoader

- (id)initWithBaseURL:(NSURL *)url
{
	if((self = [super init]) != nil) {
		baseUrl = [url retain];
		partials = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (void)dealloc
{
	[baseUrl release];
	[partials release];
	[super dealloc];
}

// TODO: Make this handle pre-loading the partials, returning an error at that time.

- (NSURL *)partialURLWithName:(NSString *)name
{
	return [[baseUrl URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"mustache"];
}

// Loads the named partial if it hasn't already been loaded
- (NSString *)partialWithName:(NSString *)name error:(NSError **)error
{
	NSString *partial;

	if((partial = [partials objectForKey:name]) == nil) {
		NSStringEncoding encoding = 0;
		NSString *partial = [NSString stringWithContentsOfURL:[self partialURLWithName:name] usedEncoding:&encoding error:error];
		if(partial == nil) return nil;
		[partials setObject:partial forKey:name];
	}

	return partial;
}

@end
