//
//  MustacheParserSpec.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 29/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cedar/SpecHelper.h>
#import "MustacheTemplate.h"

SPEC_BEGIN(MustacheTemplateSpec)
describe(@"MustacheTemplate", ^{
	__block MustacheTemplate *template;

//    beforeEach(^{
//    });
//
//	afterEach(^{
//	});

    it(@"should read all input", ^{
		NSString *templateText = @"Hello {{name}}\n"
		@"You have just won ${{value}}!\n"
		@"{{#in_ca}}\n"
		@"Well, ${{taxed_value}}, after taxes.\n"
		@"{{/in_ca}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];

		[template parse];
		assert([template bytesRead] == [templateText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] && "didn't read all bytes");

		[template release];
    });
});
SPEC_END
