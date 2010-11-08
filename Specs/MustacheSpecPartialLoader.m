//
//  MustacheSpecPartialLoader.m
//  OCMustache
//
//  Created by Wesley Moore on 8/11/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import "MustacheSpecPartialLoader.h"


@implementation MustacheSpecPartialLoader

@synthesize partials;

- (id)init
{
	if((self = [super init]) != nil) {
		partials = [[NSDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[partials release];
	[super dealloc];
}

- (NSString *)partialWithName:(NSString *)name error:(NSError **)error
{
	return [partials objectForKey:name];
}

@end
