//
//  MustacheFragment.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MustacheFragment.h"
#import "MustacheToken.h"

@implementation MustacheFragment

@synthesize parent, rootToken, tokens;

- (id)initWithRootToken:(MustacheToken *)token {
	if((self = [super init]) != nil) {
		rootToken = [token retain];
		tokens = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	[rootToken release];
	[tokens release];
	[super dealloc];
}

#pragma mark Parser delegate methods

- (void)parser:(MustacheParser *)parser foundText:(const char *)text ofLength:(size_t)length {
	NSLog(@"Add static text");
	MustacheToken *token = [[MustacheToken alloc] initWithType:mustache_token_type_static content:text contentLength:length];
	
	// Add it to the array
	[tokens addObject:token];
	[token release];
}

- (void)parser:(MustacheParser *)parser foundTag:(const char *)tag ofLength:(size_t)length withSigil:(char)sigil {
	NSLog(@"Add tag");
	MustacheToken *token = nil;
	MustacheFragment *fragment  = nil;
	
	// Initialise the token
	switch (sigil) {
		case '#':
			token = [[MustacheToken alloc] initWithType:mustache_token_type_section content:tag contentLength:length];
			fragment = [[MustacheFragment alloc] initWithRootToken:token];
			[token release];
			token = nil; // for code at end of switch

			fragment.parent = self;
			parser.delegate = fragment;
			[tokens addObject:fragment];
			[fragment release];

			// TODO: Tidy this up
			break;
		case '^':
			token = [[MustacheToken alloc] initWithType:mustache_token_type_inverted content:tag contentLength:length];
			break;
		case '/':
			// End section
			// TODO: check that it matches the last start section
			[self.parent parsingWithParser:parser didEndFragment:self];
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

- (void)parsingWithParser:(MustacheParser *)parser didEndFragment:(MustacheFragment *)fragment {
	parser.delegate = self;
}

@end
