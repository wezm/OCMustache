//
//  MustacheGenerator.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MustacheGenerator.h"
#import "MustacheTemplate.h"
#import "MustacheToken.h"

@interface MustacheGenerator (Private)

- (NSString *)handleToken:(MustacheToken *)token inContext:(id)context;
- (NSString *)handleFragment:(MustacheFragment *)fragment inContext:(id)context;

@end

@implementation MustacheGenerator

- (NSString *)stringWithContentsOfToken:(MustacheToken *)token {
	return [[[NSString alloc] initWithBytesNoCopy:token.content
										   length:token.contentLength
										 encoding:NSUTF8StringEncoding
									 freeWhenDone:NO] autorelease];
}

- (NSString *)renderFragment:(MustacheFragment *)fragment inContext:(id)context {
	NSMutableString *result = [[NSMutableString alloc] init];

	for(id node in fragment.tokens) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *value = nil;
		if([node isKindOfClass:[MustacheFragment class]]) {
			value = [self handleFragment:node inContext:context];
		}
		else {
			value = [self handleToken:node inContext:context];
		}

		if(value != nil) {
			[result appendString:value];
		}

		[pool drain];
	}

	return [result autorelease];
}

- (NSString *)handleToken:(MustacheToken *)token inContext:(id)context {
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
		default:
			NSLog(@"Unknown token type");
			break;
	}

	return nil;
}

- (NSString *)handleFragment:(MustacheFragment *)fragment inContext:(id)context {
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
				// So here is where we skip all the tokens at the depth > depth
				NSLog(@"nil or false, skip section");
			}
			else {
				if([value respondsToSelector:@selector(boolValue)] && ([value boolValue] == YES)) {
					// A true value, render the section in this context
					NSLog(@"Render section (true)");
					return [self renderFragment:fragment inContext:context];
				}
				else if(0) { // a block/lambda TODO: Decide how to test for this
					// Call the block with the section text
					NSLog(@"Call block");
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
						NSLog(@"Render %@", obj);
						// call render tokens again, limiting to a certain depth
						NSString *fragmentResult = [self renderFragment:fragment inContext:obj];
						if(fragmentResult != nil) {
							[result appendString:fragmentResult];
						}
					}
					return result;
				}
			}
			break;
		default:
			NSLog(@"Unknown token type");
			break;
	}

	return nil;
}

@end
