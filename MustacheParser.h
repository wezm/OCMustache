//
//  MustacheParser.h
//  ObjectiveMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MustacheParserMachine.h"

@interface MustacheParser : NSObject {
	MustacheParserMachine *machine;
	NSError *error;
//	NSMutableDictionary *http_params;
//	NSMutableData *http_body;
}

//void HttpParser_free(void *data) {
//	TRACE();
//	
//	if(data) {
//		free(data);
//	}
//}


//VALUE HttpParser_alloc(VALUE klass)
//{
//	VALUE obj;
//	http_parser *hp = ALLOC_N(http_parser, 1);
//	TRACE();
//	hp->http_field = http_field;
//	hp->request_method = request_method;
//	hp->request_uri = request_uri;
//	hp->fragment = fragment;
//	hp->request_path = request_path;
//	hp->query_string = query_string;
//	hp->http_version = http_version;
//	hp->header_done = header_done;
//	http_parser_init(hp);
//	
//	obj = Data_Wrap_Struct(klass, NULL, HttpParser_free, hp);
//	
//	return obj;
//}


/**
 * call-seq:
 *    parser.new -> parser
 *
 * Creates a new parser.
 VALUE HttpParser_init(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 http_parser_init(http);
 
 return self;
 }
 */


/**
 * call-seq:
 *    parser.reset -> nil
 *
 * Resets the parser to it's initial state so that you can reuse it
 * rather than making new ones.
 VALUE HttpParser_reset(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 http_parser_init(http);
 
 return Qnil;
 }
 */
- (void)reset;

/**
 * call-seq:
 *    parser.finish -> true/false
 *
 * Finishes a parser early which could put in a "good" or bad state.
 * You should call reset after finish it or bad things will happen.
 VALUE HttpParser_finish(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 http_parser_finish(http);
 
 return http_parser_is_finished(http) ? Qtrue : Qfalse;
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
 VALUE HttpParser_execute(VALUE self, VALUE req_hash, VALUE data, VALUE start)
 {
 http_parser *http = NULL;
 int from = 0;
 char *dptr = NULL;
 long dlen = 0;
 
 DATA_GET(self, http_parser, http);
 
 from = FIX2INT(start);
 dptr = RSTRING(data)->ptr;
 dlen = RSTRING(data)->len;
 
 if(from >= dlen) {
 rb_raise(eHttpParserError, "Requested start is after data buffer end.");
 } else {
 http->data = (void *)req_hash;
 http_parser_execute(http, dptr, dlen, from);
 
 VALIDATE_MAX_LENGTH(http_parser_nread(http), HEADER);
 
 if(http_parser_has_error(http)) {
 rb_raise(eHttpParserError, "Invalid HTTP format, parsing fails.");
 } else {
 return INT2FIX(http_parser_nread(http));
 }
 }
 }
 */
- (size_t)executeOnData:(NSData *)data startingAt:(NSUInteger)start;

- (void)setError:(NSError *)new_error;

/**
 * call-seq:
 *    parser.error? -> true/false
 *
 * Tells you whether the parser is in an error state.
 VALUE HttpParser_has_error(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 
 return http_parser_has_error(http) ? Qtrue : Qfalse;
 }
 */
- (BOOL)hasError;
- (NSError *)parserError;


/**
 * call-seq:
 *    parser.finished? -> true/false
 *
 * Tells you whether the parser is finished or not and in a good state.
 VALUE HttpParser_is_finished(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 
 return http_parser_is_finished(http) ? Qtrue : Qfalse;
 }
 */
- (BOOL)isFinished;

/**
 * call-seq:
 *    parser.nread -> Integer
 *
 * Returns the amount of data processed so far during this processing cycle.  It is
 * set to 0 on initialize or reset calls and is incremented each time execute is called.
 VALUE HttpParser_nread(VALUE self)
 {
 http_parser *http = NULL;
 DATA_GET(self, http_parser, http);
 
 return INT2FIX(http->nread);
 }
 */
- (size_t)bytesRead;
//- (NSDictionary *)requestParams;
//- (NSData *)requestBody;

@end
