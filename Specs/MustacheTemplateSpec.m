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


    it(@"should read render the template", ^{
		NSString *templateText = @"Hello {{name}}\n"
		@"You have just won ${{value}}!\n"
		@"{{#in_ca}}\n"
		@"Well, ${{taxed_value}}, {{& after}} taxes.\n"
		@"{{/in_ca}}\n"
		@"{{{small}}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];

		[template parse];

		NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:@"Name < Test", @"name",
								 [NSNumber numberWithInt:3000], @"value",
								 [NSNumber numberWithBool:YES], @"in_ca",
								 [NSNumber numberWithInt:2400], @"taxed_value",
								 @"<em>after</em>", @"after",
								 @"<small>Fine print</small>", @"small", nil];
		NSString *expected = @"Hello Name &lt; Test\n"
		@"You have just won $3000!\n"
		@"\n"
		@"Well, $2400, <em>after</em> taxes.\n"
		@"\n"
		@"<small>Fine print</small>";

		NSString *result = [template renderInContext:context];
		NSLog(@"%@", result);

		assert([expected compare:result] == NSOrderedSame && "result matches expected");

		[template release];
    });
});
SPEC_END
