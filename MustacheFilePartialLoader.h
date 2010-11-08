//
//  MustacheFilePartialLoader.h
//  OCMustache
//
//  Created by Wesley Moore on 4/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MustachePartialLoader.h"

@interface MustacheFilePartialLoader : NSObject <MustachePartialLoader> {
	NSURL *baseUrl;
	NSMutableDictionary *partials;
}

- (id)initWithBaseURL:(NSURL *)url;

@end
