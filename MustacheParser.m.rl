#import "MustacheParser.h"
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

	# Character classes
	open  = '{' :> '{';
	close = '}' :> '}';
	identifier = ( alnum | [?!_] | '-')+;
	simple_type = [=!<>&];
	section_type = [#^/];

	action mark { MARK(mark, fpc); }

	action start_identifier {
		MARK(identifier_start, fpc);
		printf("Start of %c tag\n", tag_type);
	}

	action got_identifier {
		printf("Tag: ");
		fwrite(PTR_TO(identifier_start), sizeof(char), LEN(identifier_start, fpc), stdout);
		printf("\n");
		[self.delegate parser:self foundTag:PTR_TO(identifier_start) ofLength:LEN(identifier_start, fpc) withSigil:tag_type];
	}

	action write_static {
		// Write out all the static text up to this tag
		printf("Static text: ");
		fwrite(PTR_TO(mark), sizeof(char), LEN(mark, fpc), stdout);
		printf("\n");
		[self.delegate parser:self foundText:PTR_TO(mark) ofLength:LEN(mark, fpc)];
	}

	action set_type {
		tag_type = fc;
	}

	action init_type {
		tag_type = ' ';
	}

	var = (
		open
		simple_type? >init_type $set_type <: # Need to add error for unknown type
		space*
		identifier >start_identifier %got_identifier
		space*
		close %mark # Need to skip whitespace for section tags
	) >write_static;

	section = (
		open
		section_type $set_type# Need to add error for unknown type
		space*
		identifier >start_identifier %got_identifier
		space*
		close
		space* %mark # Skip trailing whitespace
	) >write_static;

	# Special case for triple mustache
	unescaped = (
		open
		'{' $set_type
		space*
		identifier >start_identifier %got_identifier
		space*
		'}'
		close %mark
	) >write_static;

	text = (any+ -- open);

	body = (
		var
		| unescaped
		| section
		| text
	);

	main := body* %eof(write_static);

}%%

/** Data **/
%% write data;

@implementation MustacheParser

@synthesize delegate;

//int http_parser_init(http_parser *parser)  {
- (id)initWithDelegate:(id <MustacheParserDelegate>)parserDelegate
{
	if((self = [super init]) != nil)
	{
		mark = 0; // Mark the start of the text
		%% write init;
		delegate = parserDelegate;
	}

	return self;
}


/** exec **/
//size_t http_parser_execute(http_parser *parser, const char *buffer, size_t len, size_t off)  {
- (size_t)execute:(const char *)buffer length:(size_t)len offset:(size_t)off
{
  const char *p, *pe, *eof;
  //int cs = parser->cs;
  char tag_type = ' ';

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
