#import "MustacheParserMachine.h"
#import <stdio.h>
#import <assert.h>
#import <stdlib.h>
#import <ctype.h>
#import <string.h>

#define LEN(AT, FPC) (FPC - buffer - AT)
#define MARK(M,FPC) (M = (FPC) - buffer)
#define PTR_TO(F) (buffer + F)

/** Machine **/
%%{

	machine mustache_parser;

	# Line endings
	newline = ( "\r" | "\r\n" | "\n" );

	# Character classes
	white = [ \t]*;
	open  = '{' :> '{';
	close = '}' :> '}';

	# Action
    # # After these types of tags, all whitespace will be skipped.
    # SKIP_WHITESPACE = [ '#', '^', '/' ]
    #
    # # The content allowed in a tag name.
    # ALLOWED_CONTENT = /(\w|[?!\/-])*/
    #
    # # These types of tags allow any content,
    # # the rest only allow ALLOWED_CONTENT.
    # ANY_CONTENT = [ '!', '=' ]

	identifier = ( alnum | [?!/] | '-')*;
	# [a-zA-Z_0-9?!/]*;
	# /(\w|[?!\/-])*/;

	# Tags
	#type  = [#^/=<>&{];

	# var     = ( open white identifier white close );
	#
	# enum    = ( open '#' white identifier white close );
	#
	# inverted = ( open '^' white identifier white close );
	#
	# end_enum = ( open '/' white identifier white close );
	#
	# comment = ( open '!' (any* -- close) close );

	#body = ( comment | var | enum | nl );

	action mark { MARK(mark, fpc); }

	action start_identifier {
		MARK(identifier_start, fpc);
	}

	action got_identifier {
		// NSLog(@"mark %d, len: %d\n", mark, LEN(mark, fpc));

		printf("Tag: ");
		fwrite(PTR_TO(identifier_start), sizeof(char), LEN(identifier_start, fpc), stdout);
		printf("\n");
	}

	action write_static {
		// Write out all the static text up to this tag
		printf("Static text: ");
		fwrite(PTR_TO(mark), sizeof(char), LEN(mark, fpc), stdout);
		printf("\n");
	}

	#tag_type = [&/<>{^];

	tag = (
		open
		identifier >start_identifier %got_identifier
		close %mark
	) >write_static;

	text = (any+ -- open) ;

	main := (
		tag |
		text
	)* %eof(write_static);

}%%

/** Data **/
%% write data;

@implementation MustacheParserMachine

//int http_parser_init(http_parser *parser)  {
- (id)initWithDelegate:(id)parser_delegate
{
	if((self = [super init]) != nil)
	{
		mark = 0; // Mark the start of the text
		%% write init;
		//delegate = [parser_delegate retain];
	}

	return self;
}


/** exec **/
//size_t http_parser_execute(http_parser *parser, const char *buffer, size_t len, size_t off)  {
- (size_t)execute:(const char *)buffer length:(size_t)len offset:(size_t)off
{
  const char *p, *pe, *eof;
  //int cs = parser->cs;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;
  eof = pe;

  assert(*pe == '\0' && "pointer does not end on NUL");
  assert(pe - p == len - off && "pointers aren't same distance");


  %% write exec;

  //parser->cs = cs;
  nread += p - (buffer + off);
//
//  assert(p <= pe && "buffer overflow after parsing execute");
  assert(nread <= len && "nread longer than length");
//  assert(body_start <= len && "body starts after buffer end");
//  assert(mark < len && "mark is after buffer end");
//  assert(field_len <= len && "field has length longer than whole buffer");
//  assert(field_start < len && "field starts after buffer end");

//  if(body_start) {
//    /* final \r\n combo encountered so stop right here */
//    //%%write eof;
//    nread++;
//  }

  //return nread;
  return 0;
}

- (int)finish {
 if ([self hasError]) {
   return -1;
 } else if ([self isFinished]) {
   return 1;
 } else {
   return 0;
 }
}

- (BOOL)hasError
{
 return cs == mustache_parser_error ? YES : NO;
}

- (BOOL)isFinished
{
 return cs == mustache_parser_first_final ? YES : NO;
}

- (size_t)bytesRead
{
	return nread;
}

//- (void)dealloc
//{
//	[delegate release];
//	[super dealloc];
//}

@end
