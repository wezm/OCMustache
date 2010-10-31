//
//  MustacheToken.m
//  OCMustache
//
//  Created by Wesley Moore on 31/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheToken.h"

@implementation MustacheToken

@synthesize type, content, contentLength=content_length;

- (id)initWithType:(enum mustache_token_type)token_type content:(const char *)token_content contentLength:(NSUInteger)length {
	if((self = [super init]) != nil) {
		type = token_type;
		content = token_content;
		content_length = length;
	}

	return self;
}

@end
