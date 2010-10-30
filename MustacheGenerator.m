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

- (NSString *)renderTokens:(CFArrayRef)tokens inContext:(id)context {
	NSMutableString *result = [[NSMutableString alloc] init];
	CFIndex count = CFArrayGetCount(tokens);
	NSString *str;
	
	for(CFIndex i = 0; i < count; i++) {
		const mustache_token_t *token = CFArrayGetValueAtIndex(tokens, i);
		
		switch (token->type) {
			case mustache_token_type_static:
				str = [[NSString alloc] initWithBytesNoCopy:token->content.text length:token->content.length encoding:NSUTF8StringEncoding freeWhenDone:NO];
				[result appendString:str];
				[str release];
				break;
			default:
				break;
		}
	}
	
	return [result autorelease];
}

@end
