/*
 *  MustacheParserMachine.h
 *  ObjectiveMustache
 *
 *  Created by Wesley Moore on 20/08/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol MustacheParserDelegate;

@interface MustacheParser : NSObject {
	int cs; // Ragel, current state

	size_t nread;
	size_t mark;
	size_t identifier_start;
	id <MustacheParserDelegate>delegate;
}

@property(nonatomic, assign) id <MustacheParserDelegate> delegate;

- (id)initWithDelegate:(id <MustacheParserDelegate>)parserDelegate;
- (size_t)execute:(const char *)buffer length:(size_t)len offset:(size_t)off;
- (int)finish;
- (BOOL)hasError;
- (BOOL)isFinished;
- (size_t)bytesRead;

@end

@protocol MustacheParserDelegate

- (void)parser:(MustacheParser *)parser foundText:(const char *)text ofLength:(size_t)length;
- (void)parser:(MustacheParser *)parser foundTag:(const char *)tag ofLength:(size_t)length withSigil:(char)sigil;

@end
