//
//  MustacheSpecPartialLoader.h
//  OCMustache
//
//  Created by Wesley Moore on 8/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MustachePartialLoader.h"

@interface MustacheSpecPartialLoader : NSObject <MustachePartialLoader, NSObject> {
	NSDictionary *partials;
}

@property(nonatomic, retain) NSDictionary *partials;

@end
