//
//  MustacheParser.m
//  OCMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheTemplate.h"
#import "MustacheToken.h"
#import "MustacheFilePartialLoader.h"

@interface MustacheTemplate (Private)

- (MustacheGenerator *)generator;

@end

@implementation MustacheTemplate

@synthesize rootFragment, partialLoader;

- (id)initWithString:(NSString *)templateString
{
	if((self = [super init]) != nil)
	{
		buffer = [[templateString dataUsingEncoding:NSUTF8StringEncoding] retain];
		rootFragment = [[MustacheFragment alloc] initWithRootToken:nil];
		rootFragment.template = self;
		parser = [[MustacheParser alloc] initWithDelegate:rootFragment];
		partials = [[NSMutableDictionary alloc] init];
		partialData = [[NSMutableArray alloc] init];
	}

	return self;
}

- (BOOL)parseReturningError:(NSError **)error
{
	[parser parseBytes:[buffer bytes] length:[buffer length]];

	if([parser isInErrorState] && error != nil) {
		*error = parser.error;
		return NO;
	}

	return ![parser isInErrorState];
}

- (NSString *)renderInContext:(id)context {
	return [[self generator] renderInContext:context];
}

- (MustacheGenerator *)generator {
	if(generator == nil) {
		generator = [[MustacheGenerator alloc] initWithTemplate:self];
	}

	return generator;
}

// Use a default partialLoader if one hasn't been set
- (id <MustachePartialLoader>)partialLoader
{
	if(partialLoader == nil) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		partialLoader = [[MustacheFilePartialLoader alloc] initWithBaseURL:[NSURL fileURLWithPath:[fileManager currentDirectoryPath]]];
	}

	return partialLoader;
}

#pragma mark Partials

// TODO: Make more efficient
- (void)addPartial:(MustacheToken *)token
{
	NSAssert(token.type == mustache_token_type_partial, @"addPartial: token is not a partial");

	NSError *error = nil;
	NSString *partialName = [token contentString];
	NSString *partialString = [self.partialLoader partialWithName:partialName error:&error];
	if(partialString == nil) {
		// TODO: Report the actual error properly
		NSLog(@"Unable to load partial with name '%@'", partialName);
		return;
	}

	// Check if this partial has been already been loaded
	if([partials objectForKey:partialName] == nil) {
		// Parse the partial
		MustacheFragment *partialFragment = [[MustacheFragment alloc] initWithRootToken:nil];
		partialFragment.template = self;

		//	[parser reset];
		MustacheParser *partialParser = [[MustacheParser alloc] initWithDelegate:partialFragment];
		//	parser.delegate = partialFragment;

		// TODO: This whole store the data and fragment bit feels wrong and messy
		// The fragment is added to the list prior to parsing so that if the
		// partial is recursive the guard on the above if statement actually
		// prevents an infinite loop.
		NSData *data = [partialString dataUsingEncoding:NSUTF8StringEncoding];
		[partialData addObject:data];
		[partials setObject:partialFragment forKey:partialName];
		[partialParser parseBytes:[data bytes] length:[data length]];

		if([partialParser isInErrorState]) {
			// TODO: Create a new error that wraps the partial parser one.
			[parser abortWithError:partialParser.error];
			return;
		}

		[partialParser release];
	}
}

- (MustacheFragment *)partialWithName:(NSString *)name
{
	return [partials objectForKey:name];
}

- (void)dealloc
{
	[parser release];
	[rootFragment release];
	[buffer release];
	[generator release];
	[partialLoader release];
	[partials release];
	[partialData release];
	[super dealloc];
}

@end
