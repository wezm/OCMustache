//
//  MustacheParserSpec.m
//  OCMustache
//
//  Created by Wesley Moore on 29/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Cedar/SpecHelper.h>
#import "MustacheTemplate.h"

@interface DictionaryPartialLoader : NSObject <MustachePartialLoader> {
}

+ (DictionaryPartialLoader *)loader;

@end

@implementation DictionaryPartialLoader

+ (DictionaryPartialLoader *)loader
{
	return [[[DictionaryPartialLoader alloc] init] autorelease];
}

- (NSString *)partialWithName:(NSString *)name error:(NSError **)error
{
	return @"partial";
}

@end


SPEC_BEGIN(MustacheTemplateSpec)
describe(@"MustacheTemplate rendering", ^{
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
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

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
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"renders inverted sections when there are no item in a list", ^{
		NSString *templateText = @"List:\n"
		@"{{#list}}\n"
		@"* {{item}}\n"
		@"{{/list}}"
		@"{{^list}}\n"
		@"No items\n"
		@"{{/list}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSArray *list = [NSArray array];
		NSDictionary *context = [NSDictionary dictionaryWithObject:list forKey:@"list"];
		NSString *expected = @"List:\n"
		@"No items\n";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"renders inverted sections when the key is nil", ^{
		NSString *templateText = \
		@"{{#list}}\n"
		@"* {{item}}\n"
		@"{{/list}}"
		@"{{^list}}\n"
		@"No items\n"
		@"{{/list}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionary];
		NSString *expected = @"No items\n";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"renders inverted sections when the key is NSNull", ^{
		NSString *templateText = \
		@"{{#list}}\n"
		@"* {{item}}\n"
		@"{{/list}}"
		@"{{^list}}\n"
		@"No items\n"
		@"{{/list}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"list"];
		NSString *expected = @"No items\n";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"renders inverted sections when the key is false", ^{
		NSString *templateText = \
		@"{{#list}}\n"
		@"* {{item}}\n"
		@"{{/list}}"
		@"{{^list}}\n"
		@"No items\n"
		@"{{/list}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"list"];
		NSString *expected = @"No items\n";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"does not render comments", ^{
		NSString *templateText = @"Before {{! Comment }}after";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionary];
		NSString *expected = @"Before after";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

    it(@"allows multi-line comments", ^{
		NSString *templateText = @"Before {{! Comment\nthat spans several\nlines }}\nafter";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionary];
		NSString *expected = @"Before after";

		NSString *result = [template renderInContext:context];
		NSAssert([expected compare:result] == NSOrderedSame, @"result matches expected");

		[template release];
    });

	it(@"renders partials when specified with >", ^{
		NSString *templateText = @"|{{> gtpartial}}|";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		template.partialLoader = [DictionaryPartialLoader loader];
		[template parseReturningError:nil];

		NSDictionary *context = [NSDictionary dictionary];
		NSString *expected = @"|partial|";

		NSString *result = [template renderInContext:context];
		NSAssert2([expected compare:result] == NSOrderedSame, @"expected '%@' got '%@'", expected, result);

		[template release];
	});
});

describe(@"MustacheTemplate error handling", ^{
	__block MustacheTemplate *template;

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

	it(@"reports an error when a section is closed at the top level", ^{
		NSError *error = nil;
		NSString *templateText = @"Invalid: {{/invalid}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		BOOL result = [template parseReturningError:&error];

		NSAssert(result == NO, @"indicates parsing failed");
		NSAssert(error != nil, @"sets the error variable");
		NSAssert([[error localizedDescription] hasPrefix:@"closing unopened section"], @"provides a description of the error");

		[template release];
	});

	it(@"reports an error when a section is closed out of order", ^{
		NSError *error = nil;
		NSString *templateText = @"{{#section}}{{/invalid}}";
		template = [[MustacheTemplate alloc] initWithString:templateText];
		BOOL result = [template parseReturningError:&error];

		NSAssert(result == NO, @"indicates parsing failed");
		NSAssert(error != nil, @"sets the error variable");
		NSAssert([[error localizedDescription] compare:@"closing tag 'invalid' does not match opening tag 'section'"] == NSOrderedSame, @"provides a description of the error");

		[template release];
	});
});
SPEC_END
