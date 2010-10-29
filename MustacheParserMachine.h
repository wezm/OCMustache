/*
 *  MustacheParserMachine.h
 *  ObjectiveMustache
 *
 *  Created by Wesley Moore on 20/08/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol MustacheParserDelegate

- (void)addHttpField:(const char *)field ofLength:(size_t)flen withValue:(const char *)value ofLength:(size_t)vlen;
- (void)setRequestMethod:(const char *)at ofLength:(size_t)length;
- (void)setRequestUri:(const char *)at ofLength:(size_t)length;
- (void)setFragment:(const char *)at ofLength:(size_t)length;
- (void)setQueryString:(const char *)at ofLength:(size_t)length;
- (void)setHttpVersion:(const char *)at ofLength:(size_t)length;
- (void)setRequestPath:(const char *)at ofLength:(size_t)length;
- (void)finaliseHeadersAt:(const char *)at ofLength:(size_t)length;

@end


@interface MustacheParserMachine : NSObject {
	int cs; // Ragel, current state
//	size_t body_start;
//	int content_len;
	size_t nread;
	size_t mark;
//	size_t field_start;
//	size_t field_len;
//	size_t query_start;
//	
//	void *data;
//	
//	//	field_cb http_field;
//	//	element_cb request_method;
//	//	element_cb request_uri;
//	//	element_cb fragment;
//	//	element_cb request_path;
//	//	element_cb query_string;
//	//	element_cb http_version;
//	//	element_cb header_done;
//	
//	id <MustacheParserDelegate> delegate;
}

- (id)initWithDelegate:(id)parser_delegate;
- (size_t)execute:(const char *)buffer length:(size_t)len offset:(size_t)off;
- (int)finish;
- (BOOL)hasError;
- (BOOL)isFinished;
- (size_t)bytesRead;

@end
