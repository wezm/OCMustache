//
//  MustacheParser.m
//  OCMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheTemplate.h"
#import "MustacheToken.h"

@interface MustacheTemplate (Private)

- (MustacheGenerator *)generator;

@end

@implementation MustacheTemplate

- (id)initWithString:(NSString *)templateString
{
	if((self = [super init]) != nil)
	{
		NSUInteger length = [templateString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		NSAssert(length > 0, @"template is empty");
		length++; // +1 for NUL character

		buffer = malloc(sizeof(char) * length);
		NSAssert(buffer != NULL, @"Unable to allocate buffer for tempalate");

		if(![templateString getCString:buffer maxLength:length  encoding:NSUTF8StringEncoding]) {
			NSLog(@"Unable to get UTF-8 version of template string");
			[self release];
			return nil;
		}

		rootFragment = [[MustacheFragment alloc] initWithRootToken:nil];
		parser = [[MustacheParser alloc] initWithDelegate:rootFragment];
	}

	return self;
}

- (BOOL)parseReturningError:(NSError **)error
{
	[parser parseBytes:buffer length:strlen(buffer) error:error];

	return ![parser hasError];
}

- (NSString *)renderInContext:(id)context {
	return [[self generator] renderFragment:rootFragment inContext:context];
}

- (MustacheGenerator *)generator {
	if(generator == nil) {
		generator = [[MustacheGenerator alloc] init	];
	}

	return generator;
}

- (void)dealloc
{
	[parser release];
	[rootFragment release];
	if(buffer != NULL) free(buffer);
	[generator release];
	[super dealloc];
}

@end
