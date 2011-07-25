/*
 *  MustacheParserMachine.h
 *  OCMustache
 *
 *  Created by Wesley Moore on 20/08/10.
 *  Copyright 2010 Wesley Moore. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol MustacheParserDelegate;

@interface MustacheParser : NSObject {
	int cs; // Ragel, current state

	BOOL abort;
	NSError *error;
	NSUInteger nread;
	const char * mark;
	const char *identifier_start;
	id <MustacheParserDelegate>__unsafe_unretained delegate;
}

@property(readonly) NSError *error;
@property(nonatomic, assign) id <MustacheParserDelegate> delegate;

- (id)initWithDelegate:(id <MustacheParserDelegate>)parserDelegate;
- (NSUInteger)parseBytes:(const char *)buffer length:(size_t)length;
- (void)abort;
- (void)reset;
- (void)abortWithError:(NSError *)error;
- (BOOL)isInErrorState;
- (BOOL)isFinished;
- (NSUInteger)bytesRead;

@end

@protocol MustacheParserDelegate

- (void)parser:(MustacheParser *)parser foundText:(const char *)text ofLength:(NSUInteger)length;
- (void)parser:(MustacheParser *)parser foundTag:(const char *)tag ofLength:(NSUInteger)length withSigil:(char)sigil;

@end
