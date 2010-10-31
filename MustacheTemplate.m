//
//  MustacheParser.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 parser. All rights reserved.
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

#pragma mark Parser related stuff

- (void)reset
{
}


- (BOOL)finish
{
	[parser finish];
	return [parser isFinished];
}


- (BOOL)parse
{
	[parser execute:buffer length:strlen(buffer) offset:0];

	// TODO: This will raise an exception if the test fails, should be NSError
	if([parser hasError])
	{
		// TODO: Set error as below
		//[self setError:[NSError errorWithDomain:WebErrorDomain code:HttpParserInvalidRequest userInfo:nil]];
		NSLog(@"parser hasError");
		return NO;
	}

	return YES;
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

- (void)setError:(NSError *)new_error
{
	if(error != nil) [error release];
	error = [new_error retain];
}

- (NSError *)parserError
{
	return error != nil ? [error retain] : nil;
}


- (BOOL)isFinished
{
	return [parser isFinished];
}

- (BOOL)hasError
{
	return [parser hasError];
}

- (size_t)bytesRead
{
	return [parser bytesRead];
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
