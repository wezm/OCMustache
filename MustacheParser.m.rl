#import "MustacheParser.h"
#import <stdio.h>
#import <assert.h>
#import <stdlib.h>
#import <ctype.h>
#import <string.h>

#define LEN(AT, FPC) (FPC - AT)

/** Machine **/
%%{

	machine mustache_parser;

	# Character classes
	open  = '{' :> '{';
	close = '}' :> '}';
	identifier = ( alnum | [?!_] | '-')+; # Identifier needs '/' for partials
	simple_type = [=<>&];
	section_type = [#^/];

	action mark { mark = fpc; }

	action start_identifier {
		identifier_start = fpc;
		printf("Start of %c tag\n", tag_type);
	}

	action got_identifier {
		printf("Tag: ");
		fwrite(identifier_start, sizeof(char), LEN(identifier_start, fpc), stdout);
		printf("\n");
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, fpc) withSigil:tag_type];
		if(abort) { fhold; fgoto *mustache_parser_error; }
	}

	action write_static {
		// Write out all the static text up to this tag
		printf("Static text of Length %ld: ", LEN(mark, fpc));
		fwrite(mark, sizeof(char), LEN(mark, fpc), stdout);
		printf("\n");
		[self.delegate parser:self foundText:mark ofLength:LEN(mark, fpc)];
	}

	action init_type {
		tag_type = ' ';
	}

	action set_type {
		tag_type = fc;
	}

	action set_error {
		NSLog(@"Error at character %ld", LEN(buffer, fpc));
		[self setErrorAtIndex:LEN(buffer, fpc)];
	}

	var = (
		open
		simple_type? >init_type $set_type <: # Need to add error for unknown type
		space*
		identifier >start_identifier %got_identifier
		space*
		close %mark
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

	comment = (
		open
		'!' $set_type <:
		(any* -- close) >start_identifier %got_identifier :>
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
		| comment
		| text
	);

	main := body* %eof(write_static) $err(set_error);

}%%

/** Data **/
%% write data;

@interface MustacheParser (Internal)

- (void)setErrorAtIndex:(NSUInteger)index;
- (void)setError:(NSError *)parseError;

@end

@implementation MustacheParser

@synthesize error, delegate;

- (id)initWithDelegate:(id <MustacheParserDelegate>)parserDelegate
{
	if((self = [super init]) != nil)
	{
		%% write init;
		delegate = parserDelegate;
	}

	return self;
}


- (NSUInteger)parseBytes:(const char *)buffer length:(size_t)length
{
	const char *p, *pe, *eof; // Ragel pointers
	char tag_type = ' ';

	p = buffer;
	mark = p;
	pe = buffer + length;
	eof = pe;

	%% write exec;

	nread += p - buffer;
	return nread;
}

- (void)abort
{
	abort = YES;
}

- (void)abortWithError:(NSError *)parseError
{
	[self abort];
	[self setError:parseError];
}

- (BOOL)isInErrorState
{
	return cs == %%{ write error; }%% ? YES : NO;
}

- (NSError *)error
{
	return error;
}

- (void)setError:(NSError *)parseError
{
	if(parseError == error) return;
	[error release];
	error = [parseError retain];
}

- (BOOL)isFinished
{
	return cs == %%{ write first_final; }%% ? YES : NO;
}

- (NSUInteger)bytesRead
{
	return nread;
}

- (void)setErrorAtIndex:(NSUInteger)index
{
	NSString *localizedDescription = [NSString stringWithFormat:@"Error at character %ld", index];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
	[self setError:[NSError errorWithDomain:@"MustacheParserErrorDomain" code:1 userInfo:userInfo]];
}

@end
