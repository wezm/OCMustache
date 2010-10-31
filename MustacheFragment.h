//
//  MustacheFragment.h
//  ObjectiveMustache
//
//  Created by Wesley Moore on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MustacheParser.h"
#import "MustacheToken.h"

@protocol MustacheFragmentDelegate;

@interface MustacheFragment : NSObject <MustacheParserDelegate> {
	MustacheFragment *parent;
	MustacheToken *rootToken;
	NSMutableArray *tokens;
}

@property(nonatomic, assign) MustacheFragment *parent;
@property(readonly) MustacheToken *rootToken;
@property(readonly) NSArray *tokens;

- (id)initWithRootToken:(MustacheToken *)token;
- (void)parsingWithParser:(MustacheParser *)parser didEndFragment:(MustacheFragment *)fragment;

@end
