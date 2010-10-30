//
//  MustacheParserSpec.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 29/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cedar/SpecHelper.h>
#import "MustacheParser.h"

SPEC_BEGIN(MustacheParserSpec)
describe(@"MustacheParser", ^{
	__block MustacheParser *parser;
	
    beforeEach(^{
		parser = [[MustacheParser alloc] init];
    });
	
	afterEach(^{
		[parser release];
	});
	
    it(@"should read all input", ^{
		NSString *template = @"Hello {{name}}\n"
		@"You have just won ${{value}}!\n"
		@"{{#in_ca}}\n"
		@"Well, ${{taxed_value}}, after taxes.\n"
		@"{{/in_ca}}";

		NSData *data = [template dataUsingEncoding:NSUTF8StringEncoding];
		size_t bytes_read = [parser executeOnData:data startingAt:0];
		assert(bytes_read == [data length] && "didn't read all bytes");
    });
});
SPEC_END
