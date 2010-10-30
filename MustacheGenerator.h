//
//  MustacheGenerator.h
//  ObjectiveMustache
//
//  Created by Wesley Moore on 30/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MustacheGenerator : NSObject {

}

- (NSString *)renderTokens:(CFArrayRef)tokens inContext:(id)context;

@end
