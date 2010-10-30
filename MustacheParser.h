//
//  MustacheParser.h
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MustacheParserMachine.h"

enum mustache_token_type {
	mustache_token_type_etag = 1, // Escaped tag
	mustache_token_type_utag, // Unescaped tag
	mustache_token_type_section,
	mustache_token_type_inverted,
	mustache_token_type_static // Static text
};

typedef struct _mustache_string {
	const char *text;
	unsigned length;
} mustache_string_t;

typedef struct _mustache_token {
	enum mustache_token_type type;
	unsigned depth;
	mustache_string_t content;
	unsigned ref_count;
} mustache_token_t;


@interface MustacheParser : NSObject <MustacheParserDelegate> {
	MustacheParserMachine *machine;
	NSError *error;
	NSUInteger depth;
	CFMutableArrayRef tokens;
}

/**
 * call-seq:
 *    parser.reset -> nil
 *
 * Resets the parser to it's initial state so that you can reuse it
 * rather than making new ones.
 */
- (void)reset;

/**
 * call-seq:
 *    parser.finish -> true/false
 *
 * Finishes a parser early which could put in a "good" or bad state.
 * You should call reset after finish it or bad things will happen.
 }
 */
- (BOOL)finish;

/**
 * call-seq:
 *    parser.execute(req_hash, data, start) -> Integer
 *
 * Takes a Hash and a String of data, parses the String of data filling in the Hash
 * returning an Integer to indicate how much of the data has been read.  No matter
 * what the return value, you should call HttpParser#finished? and HttpParser#error?
 * to figure out if it's done parsing or there was an error.
 * 
 * This function now throws an exception when there is a parsing error.  This makes 
 * the logic for working with the parser much easier.  You can still test for an 
 * error, but now you need to wrap the parser with an exception handling block.
 *
 * The third argument allows for parsing a partial request and then continuing
 * the parsing from that position.  It needs all of the original data as well 
 * so you have to append to the data buffer as you read.
 */
- (size_t)executeOnData:(NSData *)data startingAt:(NSUInteger)start;

- (void)setError:(NSError *)new_error;

/**
 * call-seq:
 *    parser.error? -> true/false
 *
 * Tells you whether the parser is in an error state.
 */
- (BOOL)hasError;
- (NSError *)parserError;


/**
 * call-seq:
 *    parser.finished? -> true/false
 *
 * Tells you whether the parser is finished or not and in a good state.
 */
- (BOOL)isFinished;

/**
 * call-seq:
 *    parser.nread -> Integer
 *
 * Returns the amount of data processed so far during this processing cycle.  It is
 * set to 0 on initialize or reset calls and is incremented each time execute is called.
 */
- (size_t)bytesRead;

@end
