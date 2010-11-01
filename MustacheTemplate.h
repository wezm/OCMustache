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

@interface MustacheTemplate : NSObject {
	char *buffer;
	MustacheParser *parser;
	MustacheFragment *rootFragment;
	MustacheGenerator *generator;
}

- (BOOL)parseReturningError:(NSError **)error;
- (NSString *)renderInContext:(id)context;

@end
