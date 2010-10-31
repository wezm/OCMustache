//
//  NSString+HTML.h
//  ObjectiveMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 parser. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MustacheHTMLAdditions)

- (NSString *)stringByEncodingEntities;

@end
