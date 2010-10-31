//
//  MustacheGenerator.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MustacheGenerator.h"
#import "MustacheTemplate.h"

@implementation MustacheGenerator

- (NSString *)stringWithContentsOfToken:(const mustache_token_t *)token {
	return [[[NSString alloc] initWithBytesNoCopy:token->content.text
										   length:token->content.length
										 encoding:NSUTF8StringEncoding
									 freeWhenDone:NO] autorelease];
}

- (NSString *)renderTokens:(CFArrayRef)tokens inContext:(id)context {
	NSMutableString *result = [[NSMutableString alloc] init];
	CFIndex count = CFArrayGetCount(tokens);

	for(CFIndex i = 0; i < count; i++) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		const mustache_token_t *token = CFArrayGetValueAtIndex(tokens, i);
		id value;
		NSString *stringValue;

		switch (token->type) {
			case mustache_token_type_static:
				[result appendString:[self stringWithContentsOfToken:token]];
				break;
			case mustache_token_type_etag:
				value = [context valueForKey:[self stringWithContentsOfToken:token]];
				if([value respondsToSelector:@selector(stringValue)]) {
					stringValue = [value stringValue];
				}
				else {
					stringValue = [value description];
				}

				[result appendString:[stringValue stringByEncodingEntities]];
				break;
			case mustache_token_type_utag:
				value = [context valueForKey:[self stringWithContentsOfToken:token]];
				if([value respondsToSelector:@selector(stringValue)]) {
					stringValue = [value stringValue];
				}
				else {
					stringValue = [value description];
				}

				[result appendString:stringValue];
				break;
			default:
				break;
		}

		[pool drain];
	}

	return [result autorelease];
}

@end
