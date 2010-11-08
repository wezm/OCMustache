//
//  NSString+HTML.h
//  OCMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 Wesley Moore. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MustacheHTMLAdditions)

- (NSString *)stringByEncodingEntities;

@end
