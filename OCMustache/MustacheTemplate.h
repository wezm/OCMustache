//
//  MustacheParser.h
//  OCMustache
//
//  Created by Wesley Moore on 20/08/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MustacheParser.h"
#import "MustacheGenerator.h"
#import "MustacheFragment.h"
#import "MustachePartialLoader.h"

@interface MustacheTemplate : NSObject {
	NSData *buffer;
	MustacheParser *parser;
	MustacheFragment *rootFragment;
	MustacheGenerator *generator;
	id <MustachePartialLoader> partialLoader;
	NSMutableDictionary *partials;
	NSMutableArray *partialData;
}

@property(readonly) MustacheFragment *rootFragment;
@property(nonatomic, retain) id <MustachePartialLoader> partialLoader;

- (BOOL)parseReturningError:(NSError **)error;
- (NSString *)renderInContext:(id)context;

- (void)addPartial:(MustacheToken *)token;
- (MustacheFragment *)partialWithName:(NSString *)name;

@end
