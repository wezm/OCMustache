//
//  MustacheParser.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MustacheParser.h"

@implementation MustacheParser

- (id)init
{
	if((self = [super init]) != nil)
	{
		machine = [[MustacheParserMachine alloc] initWithDelegate:self];
		//http_params = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


//- (void)addHttpField:(const char *)field ofLength:(size_t)flen withValue:(const char *)value ofLength:(size_t)vlen
//{
//	NSString *v = nil;
//	NSMutableString *f = nil;
//	
//	validateMaxLength(flen, MAX_FIELD_NAME_LENGTH, MAX_FIELD_NAME_LENGTH_ERR);
//	validateMaxLength(vlen, MAX_FIELD_VALUE_LENGTH, MAX_FIELD_VALUE_LENGTH_ERR);
//	
//	v = [[NSString alloc] initWithBytes:value length:vlen encoding:NSASCIIStringEncoding];
//	
//	NSString *fname = [[NSString alloc] initWithBytes:field length:flen encoding:NSASCIIStringEncoding];
//	f = [NSMutableString stringWithFormat:@"%s%@", global_http_prefix, fname];
//	[fname release];
//	
//	// Replace dashes with underscore and ensure uppercase
//	[f replaceOccurrencesOfString:@"-" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [f length])];
//	
//	[http_params setObject:v forKey:[f uppercaseString]];
//	
//	// TODO: release all the intermediate bits here
//}
//
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
	[machine finish];
	return [machine isFinished];
}


- (size_t)executeOnData:(NSData *)data startingAt:(NSUInteger)start
{
	if(start < [data length])
	{
		[machine execute:[data bytes] length:[data length] offset:start];
		
		// TODO: This will raise an exception if the test fails, should be NSError
		//validateMaxLength([machine bytesRead], MAX_HEADER_LENGTH, MAX_HEADER_LENGTH_ERR);
		if([machine hasError])
		{
			//[self setError:[NSError errorWithDomain:WebErrorDomain code:HttpParserInvalidRequest userInfo:nil]];
			NSLog(@"machine hasError");
			return -1;
		}
	}
	else
	{
		//[self setError:[NSError errorWithDomain:WebErrorDomain code:HttpParserOutOfBoundsError userInfo:nil]];
		NSLog(@"parser out of bounds");
		return -1;
	}
	
	return [machine bytesRead];
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
	return [machine isFinished];
}

- (BOOL)hasError
{
	return [machine hasError];
}

- (size_t)bytesRead
{
	return [machine bytesRead];
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
	[machine release];
//	[http_params release];
//	if(http_body != nil) [http_body release];
	[super dealloc];
}

@end
