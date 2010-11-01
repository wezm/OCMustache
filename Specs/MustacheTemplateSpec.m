//
//  MustacheParserSpec.m
//  OCMustache
//
//  Created by Wesley Moore on 29/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Cedar/SpecHelper.h>
#import "MustacheTemplate.h"

SPEC_BEGIN(MustacheTemplateSpec)
describe(@"MustacheTemplate", ^{
	__block MustacheTemplate *template;

    it(@"renders the template", ^{
		NSString *templateText = @"Hello {{name}}\n"
		@"You have just won ${{value}}!\n"
		@"{{#in_ca}}\n"
		@"Well, ${{taxed_value}}, {{& after}} taxes.\n"
		@"{{/in_ca}}\n"
		@"{{{small}}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];

		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:@"Name < Test", @"name",
								 [NSNumber numberWithInt:3000], @"value",
								 [NSNumber numberWithBool:YES], @"in_ca",
								 [NSNumber numberWithInt:2400], @"taxed_value",
								 @"<em>after</em>", @"after",
								 @"<small>Fine print</small>", @"small", nil];
		NSString *expected = @"Hello Name &lt; Test\n"
		@"You have just won $3000!\n"
		@"Well, $2400, <em>after</em> taxes.\n"
		@"<small>Fine print</small>";

		NSString *result = [template renderInContext:context];
		NSLog(@"%@", result);

		assert([expected compare:result] == NSOrderedSame && "result matches expected");

		[template release];
    });

    it(@"renders templates with list values", ^{
		NSString *templateText = @"List:\n"
		@"{{#list}}\n"
		@"* {{item}}\n"
		@"{{/list}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSArray *items = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
		NSMutableArray *list = [NSMutableArray arrayWithCapacity:[items count]];
		for(id item in items) {
			[list addObject:[NSDictionary dictionaryWithObject:item forKey:@"item"]];
		}
		NSDictionary *context = [NSDictionary dictionaryWithObject:list forKey:@"list"];
		NSString *expected = @"List:\n"
		@"* one\n"
		@"* two\n"
		@"* three\n";

		NSString *result = [template renderInContext:context];
		NSLog(@"%@", result);

		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

	it(@"reports errors", ^{
		NSError *error = nil;
		NSString *templateText = @"Invalid: {{*invalid}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		BOOL result = [template parseReturningError:&error];

		NSAssert(result == NO, @"indicates parsing failed");
		NSAssert(error != nil, @"sets the error variable");
		NSAssert([[error localizedDescription] hasPrefix:@"Error at character"], @"provides a description of the error");

		[template release];
	});
});
SPEC_END
