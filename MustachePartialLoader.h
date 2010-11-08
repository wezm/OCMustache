//
//  MustachePartialLoader.h
//  OCMustache
//
//  Created by Wesley Moore on 5/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MustachePartialLoader <NSObject>

- (NSString *)partialWithName:(NSString *)name error:(NSError **)error;

@end
