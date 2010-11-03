//
//  MustacheSpec.m
//  OCMustache
//
//  Created by Wesley Moore on 3/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Cedar/SpecHelper.h>
#import <YAML/YAMLSerialization.h>

@interface MustacheSpec : CDRSpec
{
	NSMutableArray *jsonTests;
}

@end

@implementation MustacheSpec

- (id)init {
	if((self = [super init]) != nil) {
		// Find the specs
		NSFileManager *fileManager = [NSFileManager defaultManager];
		// Assumes pwd is the project root, which has been set on the executable
		NSURL *specsDir = [NSURL fileURLWithPath:@"Mustache-Spec/specs" isDirectory:YES];
		NSArray *properties = [NSArray arrayWithObject:NSURLNameKey];
		NSUInteger options =    NSDirectoryEnumerationSkipsSubdirectoryDescendants |
			NSDirectoryEnumerationSkipsPackageDescendants |
			NSDirectoryEnumerationSkipsHiddenFiles;
		NSDirectoryEnumerator *dir = [fileManager enumeratorAtURL:specsDir includingPropertiesForKeys:properties options:options errorHandler:nil];

		NSLog(@"Looking for specs in %@", specsDir);
		jsonTests = [[NSMutableArray alloc] init];
		for (NSURL *url in dir) {
			NSLog(@"%@", url);
			if([[url pathExtension] compare:@"yml"] == NSOrderedSame) {
				[jsonTests addObject:url];
			}
		}
		
//		NSData *JSONData = [NSData dataWithContentsOfFile:@"example.json"];
//		jsonTests = [JSONData yajl_JSON];
	}
		 
	return self;
}

- (void)dealloc {
	[jsonTests release];
	[super dealloc];
}

- (void)declareBehaviors {
	
	// Loop over the jsonTests and build the test suite.
	// A describe call for each test whose name is built from the filename and the JSON
	for(NSURL *suiteUrl in jsonTests) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSInputStream *stream = [[[NSInputStream alloc] initWithURL:suiteUrl] autorelease];
		NSError *error = nil;
		NSArray *yamlDocs = [YAMLSerialization YAMLWithStream:stream
													  options:kYAMLReadOptionStringScalars
														error:&error];
		NSLog(@"%@", yamlDocs);
		
		[pool drain];
	}
	
}

@end
//
//SPEC_BEGIN(MustacheSpec)
//describe(@"MustacheSpec", ^{
//	
//	beforeEach(<#CDRSpecBlock block#>);
//	
//	afterEach(<#CDRSpecBlock block#>);
//	
//});
//SPEC_END