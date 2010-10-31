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
}

- (NSString *)renderFragment:(MustacheFragment *)fragment inContext:(id)context;

@end
