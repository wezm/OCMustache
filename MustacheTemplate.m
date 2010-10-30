//
//  MustacheParser.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MustacheTemplate.h"

static mustache_token_t *token_create (CFAllocatorRef allocator) {
	int hint = 0;
	mustache_token_t *token = CFAllocatorAllocate(allocator, sizeof(mustache_token_t), hint);
	token->ref_count = 1;

	return token;
}

static const void *token_retain(CFAllocatorRef allocator, const void *value) {
	mustache_token_t *token = (mustache_token_t *)value;
	token->ref_count++;
	return token;
}

static void token_release(CFAllocatorRef allocator, const void *value) {
	mustache_token_t *token = (mustache_token_t *)value;
	token->ref_count--;
	if(token->ref_count == 0) {
		CFAllocatorDeallocate(allocator, token);
	}
}

@interface MustacheTemplate (Private)

- (mustache_token_t *)tokenOfType:(enum mustache_token_type)type withText:(const char *)text ofLength:(size_t)length;

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

		CFArrayCallBacks callbacks = {
			.version = 0,
			.retain = token_retain,
			.release = token_release,
			.equal = NULL, // Will compare pointers
			.copyDescription = NULL
		};

		tokens = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
	}

	return self;
}

- (mustache_token_t *)tokenOfType:(enum mustache_token_type)type withText:(const char *)text ofLength:(size_t)length {
	mustache_token_t *token = token_create(kCFAllocatorDefault);
	mustache_string_t string = {
		.text = text,
		.length = length
	};

	// Initialise the token
	token->type = type;
	token->content = string;
	token->depth = depth;

	return token;
}

#pragma mark Parser delegate methods

- (void)addStaticText:(const char *)text ofLength:(size_t)length
{
	NSLog(@"Add static text");
	mustache_token_t *token = [self tokenOfType:mustache_token_type_static withText:text ofLength:length];

	// Add it to the array
	CFArrayAppendValue(tokens, token);
	token_release(kCFAllocatorDefault, token);
}

- (void)addTag:(const char *)tag ofLength:(size_t)length withSigil:(char)sigil {
	NSLog(@"Add tag");
	mustache_token_t *token = NULL;

	// Initialise the token
	switch (sigil) {
		case '#':
			token = [self tokenOfType:mustache_token_type_section withText:tag ofLength:length];
			depth++;
			break;
		case '^':
			token = [self tokenOfType:mustache_token_type_inverted withText:tag ofLength:length];
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
			token = [self tokenOfType:mustache_token_type_utag withText:tag ofLength:length];
			break;
		default:
			token = [self tokenOfType:mustache_token_type_etag withText:tag ofLength:length];
			break;
	}

	if(token != NULL) {
		// Add it to the array
		CFArrayAppendValue(tokens, token);
		token_release(kCFAllocatorDefault, token);
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
	CFRelease(tokens);
	if(buffer != NULL) free(buffer);
	[super dealloc];
}

@end
