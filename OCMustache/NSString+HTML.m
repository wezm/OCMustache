//
//  NSString+HTML.m
//  OCMustache
//
//  Created by Wesley Moore on 30/10/10.
//

// Derived from entities.c in libxml

/*
 * entities.c : implementation for the XML entities handling
 *
 * Except where otherwise noted in the source code (e.g. the files hash.c,
 * list.c and the trio files, which are covered by a similar licence but
 * with different Copyright notices) all the files are:
 *
 * Copyright (C) 1998-2003 Daniel Veillard.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is fur-
 * nished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
 * NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * DANIEL VEILLARD BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CON-
 * NECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of Daniel Veillard shall not
 * be used in advertising or otherwise to promote the sale, use or other deal-
 * ings in this Software without prior written authorization from him.
 *
 *
 *
 * daniel@veillard.com
 */

#import "NSString+HTML.h"

/*
 * Macro used to grow the current buffer.
 */
#define growBufferReentrant() {								\
    buffer_size *= 2;										\
    buffer = (char *)										\
    		realloc(buffer, buffer_size * sizeof(char));	\
    if (buffer == NULL) {									\
        NSLog(@"stringByEncodingEntities: realloc failed");	\
		return(nil);										\
    }														\
}

@implementation NSString (MustacheHTMLAdditions)

/* Lots of code but it was already written and runs about 4 times faster
   than calling stringByReplacingOccurrencesOfString repeatedly. Also
   probably more memory efficient. */
- (NSString *)stringByEncodingEntities {
	if([self length] == 0) return self;

	const char *input = [self UTF8String];

	/**
	 * xmlEncodeSpecialChars:
	 * @doc:  the document containing the string
	 * @input:  A string to convert to XML.
	 *
	 * Do a global encoding of a string, replacing the predefined entities
	 * this routine is reentrant, and result must be deallocated.
	 *
	 * Returns A newly allocated string with the substitution done.
	 */
	const char *cur = input;
	char *buffer = NULL;
	char *out = NULL;
	int buffer_size = 0;
	if (input == NULL) return(NULL);

	/*
	 * allocate an translation buffer.
	 */
	buffer_size = 2 * [self maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSAssert(buffer_size > 0, @"stringByEncodingEntities: Unable to get maximumLengthOfBytes in UTF-8");
	buffer = (char *) malloc(buffer_size * sizeof(char));
	if (buffer == NULL) {
		NSLog(@"stringByEncodingEntities: malloc failed");
		return(nil);
	}
	out = buffer;

	while (*cur != '\0') {
		if (out - buffer > buffer_size - 10) {
			int indx = out - buffer;

			growBufferReentrant();
			out = &buffer[indx];
		}

		/*
		 * By default one have to encode at least '<', '>', '"' and '&' !
		 */
		switch (*cur) {
			case '<':
				*out++ = '&';
				*out++ = 'l';
				*out++ = 't';
				*out++ = ';';
				break;
			case '>':
				*out++ = '&';
				*out++ = 'g';
				*out++ = 't';
				*out++ = ';';
				break;
			case '&':
				*out++ = '&';
				*out++ = 'a';
				*out++ = 'm';
				*out++ = 'p';
				*out++ = ';';
				break;
			case '"':
				*out++ = '&';
				*out++ = 'q';
				*out++ = 'u';
				*out++ = 'o';
				*out++ = 't';
				*out++ = ';';
				break;
			case '\r':
				*out++ = '&';
				*out++ = '#';
				*out++ = '1';
				*out++ = '3';
				*out++ = ';';
				break;
			default:
				/*
				 * Works because on UTF-8, all extended sequences cannot
				 * result in bytes in the ASCII range.
				 */
				*out++ = *cur;
				break;
		}
		cur++;
	}
	*out = 0;

	return [[NSString alloc] initWithBytesNoCopy:buffer length:out - buffer encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

@end
