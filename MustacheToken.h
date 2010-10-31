//
//  MustacheToken.h
//  OCMustache
//
//  Created by Wesley Moore on 31/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

enum mustache_token_type {
	mustache_token_type_etag = 1, // Escaped tag
	mustache_token_type_utag, // Unescaped tag
	mustache_token_type_section,
	mustache_token_type_inverted,
	mustache_token_type_static, // Static text
	mustache_token_type_partial
};

@interface MustacheToken : NSObject {
	enum mustache_token_type type;
	const char *content;
	NSUInteger content_length;
}

@property(nonatomic, assign) enum mustache_token_type type;
@property(nonatomic, assign) const char *content;
@property(nonatomic, assign) size_t contentLength;

- (id)initWithType:(enum mustache_token_type)token_type content:(const char *)content contentLength:(NSUInteger)length;

@end
