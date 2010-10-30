//
//  NSString+HTML.m
//  ObjectiveMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+HTML.h"
#import <libxml/entities.h>

@implementation NSString (MustacheHTMLAdditions)

// Kind of abusing libxml a bit here since we don't pass a doc and don't call
// the library initialisation function. I checked the code (2.7.7) though and
// it seems ok to use it this way.
- (NSString *)stringByEncodingEntities {
	xmlDocPtr doc = NULL;
	xmlChar *encoded = xmlEncodeSpecialChars(doc, (xmlChar *)[self UTF8String]);
	NSString *result = [NSString stringWithCString:encoded encoding:NSUTF8StringEncoding];
	xmlFree(encoded);
	
	return [result autorelease];
}


@end
