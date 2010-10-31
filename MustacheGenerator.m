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
				// TODO: DRY this up
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
					}
					else if(0) { // a block/lambda
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

						for(id obj in value) {
							NSLog(@"Render %@", obj);
						}
					}
				}
				break;
			default:
				break;
		}

		[pool drain];
	}

	return [result autorelease];
}

@end