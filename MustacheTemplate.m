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

- (id)init
{
	if((self = [super init]) != nil)
	{
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

//- (void)setRequestMethod:(const char *)at ofLength:(size_t)length
//{
//	// no max length validation on this one as the state machine will only read up to 20 chars
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_request_method];
//	[val release];
//}
//
//- (void)setRequestUri:(const char *)at ofLength:(size_t)length
//{
//	validateMaxLength(length, MAX_REQUEST_URI_LENGTH, MAX_REQUEST_URI_LENGTH_ERR);
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_request_uri];
//	[val release];
//}
//
//- (void)setFragment:(const char *)at ofLength:(size_t)length
//{
//	validateMaxLength(length, MAX_FRAGMENT_LENGTH, MAX_FRAGMENT_LENGTH_ERR);
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_fragment];
//	[val release];
//}
//
//- (void)setRequestPath:(const char *)at ofLength:(size_t)length
//{
//	validateMaxLength(length, MAX_REQUEST_PATH_LENGTH, MAX_REQUEST_PATH_LENGTH_ERR);
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_request_path];
//	[val release];
//}
//
//- (void)setQueryString:(const char *)at ofLength:(size_t)length
//{
//	validateMaxLength(length, MAX_QUERY_STRING_LENGTH, MAX_QUERY_STRING_LENGTH_ERR);
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_query_string];
//	[val release];
//}
//
//- (void)setHttpVersion:(const char *)at ofLength:(size_t)length
//{
//	NSString *val = [[NSString alloc] initWithBytes:at length:length encoding:NSASCIIStringEncoding];
//	[http_params setObject:val forKey:global_http_version];
//	[val release];
//}
//
//- (void)finaliseHeadersAt:(const char *)at ofLength:(size_t)length
//{
//	NSString *content_length = [http_params objectForKey:global_http_content_length];
//	if(content_length != nil)
//	{
//		[http_params setObject:content_length forKey:global_content_length];
//	}
//
//	NSString *content_type = [http_params objectForKey:global_http_content_type];
//	if(content_type != nil)
//	{
//		[http_params setObject:content_type forKey:global_content_type];
//	}
//
//	[http_params setObject:[NSString stringWithString:global_gateway_interface_value] forKey:global_gateway_interface];
//
//	// Set host
//	NSString *http_host = [http_params objectForKey:global_http_host];
//	if(http_host != nil)
//	{
//		// See if a port is already present
//		NSRange r = [http_host rangeOfString:@":" options:NSLiteralSearch | NSBackwardsSearch];
//		if(r.location != NSNotFound)
//		{
//			// set server name to text upto location
//			[http_params setObject:[http_host substringToIndex:r.location] forKey:global_server_name];
//			// TODO: Need to handle the possibility that the colon has nothing after it
//			[http_params setObject:[http_host substringFromIndex:r.location+1] forKey:global_server_port];
//
//		}
//		else
//		{
//			[http_params setObject:http_host forKey:global_server_name];
//			[http_params setObject:[NSString stringWithString:global_port_80] forKey:global_server_port];
//		}
//	}
//
//	http_body = [NSMutableData dataWithBytes:at length:length];
//	[http_params setObject:[NSString stringWithString:global_server_protocol_value] forKey:global_server_protocol];
//	[http_params setObject:[NSString stringWithString:global_mongrel_version] forKey:global_server_software];
//}

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


- (size_t)executeOnData:(NSData *)data startingAt:(NSUInteger)start
{
	if(start < [data length])
	{
		[parser execute:[data bytes] length:[data length] offset:start];

		// TODO: This will raise an exception if the test fails, should be NSError
		//validateMaxLength([parser bytesRead], MAX_HEADER_LENGTH, MAX_HEADER_LENGTH_ERR);
		if([parser hasError])
		{
			//[self setError:[NSError errorWithDomain:WebErrorDomain code:HttpParserInvalidRequest userInfo:nil]];
			NSLog(@"parser hasError");
			return -1;
		}
	}
	else
	{
		//[self setError:[NSError errorWithDomain:WebErrorDomain code:HttpParserOutOfBoundsError userInfo:nil]];
		NSLog(@"parser out of bounds");
		return -1;
	}

	return [parser bytesRead];
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

//- (NSDictionary *)requestParams
//{
//	[http_params retain];
//	return [http_params autorelease];
//}
//
//- (NSData *)requestBody
//{
//	[http_body retain];
//	return [http_body autorelease];
//}

- (void)dealloc
{
	[parser release];
	CFRelease(tokens);
	[super dealloc];
}

@end
