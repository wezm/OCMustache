//
//  MustacheGenerator.m
//  OCMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheGenerator.h"
#import "MustacheTemplate.h"
#import "MustacheToken.h"

@interface MustacheGenerator (Private)

- (NSString *)renderToken:(MustacheToken *)token inContext:(id)context;
- (NSString *)renderPartialToken:(MustacheToken *)token inContext:(id)context;
- (NSString *)renderChildFragment:(MustacheFragment *)fragment inContext:(id)context;
- (NSString *)renderFragment:(MustacheFragment *)fragment inContext:(id)context;

@end

@implementation MustacheGenerator

- (id)initWithTemplate:(MustacheTemplate *)aTemplate
{
	if((self = [super init]) != nil) {
		template = aTemplate;
	}

	return self;
}

- (NSString *)stringWithContentsOfToken:(MustacheToken *)token {
	return [[[NSString alloc] initWithBytesNoCopy:token.content
										   length:token.contentLength
										 encoding:NSUTF8StringEncoding
									 freeWhenDone:NO] autorelease];
}

- (NSString *)renderInContext:(id)context
{
	return [self renderFragment:template.rootFragment inContext:context];
}

- (NSString *)renderFragment:(MustacheFragment *)fragment inContext:(id)context {
	NSMutableString *result = [[NSMutableString alloc] init];

	for(id node in fragment.tokens) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *value = nil;
		if([node isKindOfClass:[MustacheFragment class]]) {
			value = [self renderChildFragment:node inContext:context];
		}
		else {
			value = [self renderToken:node inContext:context];
		}

		if(value != nil) {
			[result appendString:value];
		}

		[pool drain];
	}

	return [result autorelease];
}

- (NSString *)renderToken:(MustacheToken *)token inContext:(id)context {
	id value;
	NSString *stringValue;

	switch (token.type) {
		case mustache_token_type_static:
			return [self stringWithContentsOfToken:token];
			break;
		case mustache_token_type_etag:
			// TODO: DRY this up
			value = [context valueForKey:[self stringWithContentsOfToken:token]];
			if([value respondsToSelector:@selector(stringValue)]) {
				stringValue = [value stringValue];
			}
			else {
				stringValue = [value description];
			}

			return [stringValue stringByEncodingEntities];
			break;
		case mustache_token_type_utag:
			value = [context valueForKey:[self stringWithContentsOfToken:token]];
			if([value respondsToSelector:@selector(stringValue)]) {
				stringValue = [value stringValue];
			}
			else {
				stringValue = [value description];
			}

			return stringValue;
			break;
		case mustache_token_type_partial:
			return [self renderPartialToken:token inContext:context];
			break;
		default:
			NSLog(@"%@: Unknown token type '%c'", NSStringFromSelector(_cmd), token.type);
			break;
	}

	return nil;
}

- (NSString *)renderChildFragment:(MustacheFragment *)fragment inContext:(id)context {
	id value;
	MustacheToken *token = [fragment rootToken];

	switch (token.type) {
		case mustache_token_type_section:
			/* Ok this one requires some magic...
			 if the value for the key is
			 - boolean then just show the section, same context
			 - an object then use it as the context
			 - a list then iterate over each item as the context
			 - a function/callable/block then call it with the section
			 */
			// Time for some duck typing...
			value = [context valueForKey:[self stringWithContentsOfToken:token]];

			// First up skip if this thing is nil or false
			if(value == nil || ([value respondsToSelector:@selector(boolValue)] && ([value boolValue] == NO))) {
				// Do nothing
			}
			else {
				if([value respondsToSelector:@selector(boolValue)] && ([value boolValue] == YES)) {
					// A true value, render the section in this context
					return [self renderFragment:fragment inContext:context];
				}
				else if(0) { // a block/lambda TODO: Decide how to test for this
					// TODO: Call the block with the section text
				}
				else {
					if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
						// The value is list like however dictionaries also
						// conform to this protocol and they should behave like an object
						if([value respondsToSelector:@selector(objectForKey:)]) {
							value = [NSArray arrayWithObject:value];
						}
					}
					else {
						// Some random object
						value = [NSArray arrayWithObject:value];
					}

					NSMutableString *result = [NSMutableString string];
					for(id obj in value) {
						context = obj;
						NSString *fragmentResult = [self renderFragment:fragment inContext:obj];
						if(fragmentResult != nil) {
							[result appendString:fragmentResult];
						}
					}
					return result;
				}
			}
			break;
		case mustache_token_type_inverted:
			value = [context valueForKey:[self stringWithContentsOfToken:token]];

			// TODO: // Extract the first test so it can be shared with above
			if(value == nil || ([value respondsToSelector:@selector(boolValue)] && ([value boolValue] == NO)) || ([value respondsToSelector:@selector(count)] && ([value count] == 0))) {
				// A false value, render the section in this context
				return [self renderFragment:fragment inContext:context];
			}

			break;
		default:
			NSLog(@"%@ Unknown token type '%c'", NSStringFromSelector(_cmd), token.type);
			break;
	}

	return nil;
}

- (NSString *)renderPartialToken:(MustacheToken *)token inContext:(id)context
{
	MustacheFragment *partial = [template partialWithName:[token contentString]];
	NSAssert1(partial != nil, @"Partial with name %@ was nil", [token contentString]);

	return [self renderFragment:partial inContext:context];
}

@end
