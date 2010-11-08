//
//  MustacheGenerator.h
//  OCMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MustacheFragment.h"

@interface MustacheGenerator : NSObject {
	MustacheTemplate *template;
}

- (id)initWithTemplate:(MustacheTemplate *)aTemplate;

// Renders the assigned template in the given context
- (NSString *)renderInContext:(id)context;

@end
