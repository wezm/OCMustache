//
//  MustacheSpec.m
//  OCMustache
//
//  Created by Wesley Moore on 3/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <YAML/YAMLSerialization.h>

#import "MustacheSpec.h"
#import "MustacheTemplate.h"
#import "MustacheSpecPartialLoader.h"

@implementation MustacheSpec

- (id)init {
	if((self = [super init]) != nil) {
		// Find the specs
		NSFileManager *fileManager = [NSFileManager defaultManager];
		// Assumes pwd is the project root, which has been set on the "Mustache-Spec" executable
		NSURL *specsDir = [NSURL fileURLWithPath:@"Mustache-Spec/specs" isDirectory:YES];
		NSUInteger options =    NSDirectoryEnumerationSkipsSubdirectoryDescendants |
			NSDirectoryEnumerationSkipsPackageDescendants |
			NSDirectoryEnumerationSkipsHiddenFiles;
		NSDirectoryEnumerator *dir = [fileManager enumeratorAtURL:specsDir includingPropertiesForKeys:nil options:options errorHandler:nil];

		NSLog(@"Looking for specs in %@", specsDir);
		testSuiteUrls = [[NSMutableArray alloc] init];
		for (NSURL *url in dir) {
			if([[url pathExtension] compare:@"yml"] == NSOrderedSame) {
				[testSuiteUrls addObject:url];
			}
		}
	}

	return self;
}

- (void)dealloc {
	[testSuiteUrls release];
	[super dealloc];
}

- (void)declareBehaviors {
	// These suites aren't expected to pass
	NSSet *pendingTestSuites = [NSSet setWithObjects:@"delimiters", @"lambdas", nil];

	// Load the tests in each YAML test suite file
	for(NSURL *suiteUrl in testSuiteUrls) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSInputStream *stream = [[NSInputStream alloc] initWithURL:suiteUrl];
		NSError *error = nil;
		id lastDoc = [[YAMLSerialization YAMLWithStream:stream
												options:kYAMLReadOptionStringScalars
												  error:&error] lastObject];
		[stream release];
		NSAssert([lastDoc isKindOfClass:[NSDictionary class]], @"Test suite is not a dictionary");
		NSDictionary *suite = lastDoc;
		NSArray *tests = [suite objectForKey:@"tests"];
		NSString *suiteName = [[suiteUrl lastPathComponent] stringByDeletingPathExtension];

		describe(suiteName, ^{
			for(NSDictionary *test in tests) {
				NSString *testDesc = [NSString stringWithFormat:@"%@ - %@", [test objectForKey:@"desc"], [test objectForKey:@"name"]];
				if([pendingTestSuites containsObject:suiteName]) {
					// Create a pending test
					it(testDesc, PENDING);
				}
				else {
					it(testDesc, ^{
						MustacheSpecPartialLoader *partialLoader = [[MustacheSpecPartialLoader alloc] init];
						partialLoader.partials = [test objectForKey:@"partials"];

						NSError *parseError = nil;
						MustacheTemplate *t = [[MustacheTemplate alloc] initWithString:[test objectForKey:@"template"]];
						t.partialLoader = partialLoader;
						NSAssert([t parseReturningError:&parseError] == YES, @"parses sucessfully");
						[partialLoader release];

						NSString *expected = [test objectForKey:@"expected"];
						NSString *result = [t renderInContext:[test objectForKey:@"data"]];
						NSAssert2([expected compare:result] == NSOrderedSame, @"expected '%@' got '%@'", expected, result);

						[t release];
					});
				}
			}

		});


		[pool drain];
	}

}

@end
