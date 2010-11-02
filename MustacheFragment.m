//
//  MustacheFragment.m
//  OCMustache
//
//  Created by Wesley Moore on 31/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
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
	if([parser isInErrorState]) {
		NSLog(@"Ignoring foundText in error state");
		return;
	}

	MustacheToken *token = [[MustacheToken alloc] initWithType:mustache_token_type_static content:text contentLength:length];

	// Add it to the array
	[tokens addObject:token];
	[token release];
}

- (void)parser:(MustacheParser *)parser foundTag:(const char *)tag ofLength:(size_t)length withSigil:(char)sigil {
	MustacheToken *token = nil;
	MustacheFragment *fragment  = nil;

	// Initialise the token
	switch (sigil) {
		case '^':
		case '#':
			token = [[MustacheToken alloc] initWithType:(sigil == '#' ? mustache_token_type_section : mustache_token_type_inverted) content:tag contentLength:length];
			fragment = [[MustacheFragment alloc] initWithRootToken:token];
			[token release];
			token = nil; // for code at end of switch

			fragment.parent = self;
			parser.delegate = fragment;
			[tokens addObject:fragment];
			[fragment release];
			break;
		case '/':
			// End section
			if(self.rootToken != nil) {
				// Compare the tag name
				if((self.rootToken.contentLength != length) || (memcmp(self.rootToken.content, tag, length) != 0)) {
					// End tag does not match open tag
					NSString *closingTag = [[NSString alloc] initWithBytesNoCopy:tag length:length encoding:NSUTF8StringEncoding freeWhenDone:NO];
					NSString *localizedDescription = [NSString stringWithFormat:@"closing tag '%@' does not match opening tag '%@'", closingTag, [self.rootToken contentString]];
					[closingTag release];
					NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
					[parser abortWithError:[NSError errorWithDomain:@"OCMustacheErrorDomain" code:2 userInfo:userInfo]];
				} else {
					[self.parent parsingWithParser:parser didEndFragment:self];
				}
			}
			else {
				// Ending a section that isn't open
				NSString *localizedDescription = [NSString stringWithFormat:@"closing unopened section '%@'", [token contentString]];
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
				[parser abortWithError:[NSError errorWithDomain:@"OCMustacheErrorDomain" code:2 userInfo:userInfo]];
			}
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
