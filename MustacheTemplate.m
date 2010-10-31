//
//  MustacheParser.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

		parser = [[MustacheParser alloc] initWithDelegate:self];
		tokens = [[NSMutableArray alloc] init];
	}

	return self;
}

#pragma mark Parser delegate methods

- (void)addStaticText:(const char *)text ofLength:(size_t)length
{
	NSLog(@"Add static text");
	MustacheToken *token = [[MustacheToken alloc] initWithType:mustache_token_type_static content:text contentLength:length];

	// Add it to the array
	[tokens addObject:token];
	[token release];
}

- (void)addTag:(const char *)tag ofLength:(size_t)length withSigil:(char)sigil {
	NSLog(@"Add tag");
	MustacheToken *token = nil;

	// Initialise the token
	switch (sigil) {
		case '#':
			token = [[MustacheToken alloc] initWithType:mustache_token_type_section content:tag contentLength:length];
			depth++;
			break;
		case '^':
			token = [[MustacheToken alloc] initWithType:mustache_token_type_inverted content:tag contentLength:length];
			depth++;
			break;
		case '/':
			// End section
			// TODO: check that it matches the last start section
			depth--;
			break;
		case '!':
			// Ignore comments
			break;
		case '{':
		case '&':
			token = [[MustacheToken alloc] initWithType:mustache_token_type_utag content:tag contentLength:length];
			break;
		default:
			token = [[MustacheToken alloc] initWithType:mustache_token_type_etag content:tag contentLength:length];
			break;
	}

	if(token != nil) {
		// Add it to the array
		[tokens addObject:token];
		[token release];
	}
}

- (void)reset
{
	//	http_parser *http = NULL;
	//	DATA_GET(self, http_parser, http);
	//	http_parser_init(http);
	//
	//	return Qnil;
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
	//validateMaxLength([parser bytesRead], MAX_HEADER_LENGTH, MAX_HEADER_LENGTH_ERR);
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
	return [[self generator] renderTokens:tokens inContext:context];
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
	[tokens release];
	if(buffer != NULL) free(buffer);
	[generator release];
	[super dealloc];
}

@end
