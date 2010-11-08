
#line 1 "../MustacheParser.m.rl"
#import "MustacheParser.h"
#import <stdio.h>
#import <assert.h>
#import <stdlib.h>
#import <ctype.h>
#import <string.h>

#define LEN(AT, FPC) (FPC - AT)

/** Machine **/

#line 103 "../MustacheParser.m.rl"


/** Data **/

#line 20 "MustacheParser.m"
static const int mustache_parser_start = 17;
static const int mustache_parser_first_final = 17;
static const int mustache_parser_error = 0;

static const int mustache_parser_en_main = 17;


#line 107 "../MustacheParser.m.rl"

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
		[self reset];
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

	
#line 64 "MustacheParser.m"
	{
	if ( p == pe )
		goto _test_eof;
	goto _resume;

_again:
	switch ( cs ) {
		case 17: goto st17;
		case 18: goto st18;
		case 1: goto st1;
		case 0: goto st0;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 19: goto st19;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 20: goto st20;
		case 9: goto st9;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
	default: break;
	}

	if ( ++p == pe )
		goto _test_eof;
_resume:
	switch ( cs )
	{
tr40:
#line 22 "../MustacheParser.m.rl"
	{ mark = p; }
	goto st17;
st17:
	if ( ++p == pe )
		goto _test_eof17;
case 17:
#line 109 "MustacheParser.m"
	if ( (*p) == 123 )
		goto tr38;
	goto st17;
tr38:
#line 33 "../MustacheParser.m.rl"
	{
		// Write out all the static text up to this tag
		[self.delegate parser:self foundText:mark ofLength:LEN(mark, p)];

		// Move the mark up to this point
		mark =  p;
	}
	goto st18;
tr41:
#line 22 "../MustacheParser.m.rl"
	{ mark = p; }
#line 33 "../MustacheParser.m.rl"
	{
		// Write out all the static text up to this tag
		[self.delegate parser:self foundText:mark ofLength:LEN(mark, p)];

		// Move the mark up to this point
		mark =  p;
	}
	goto st18;
st18:
	if ( ++p == pe )
		goto _test_eof18;
case 18:
#line 139 "MustacheParser.m"
	if ( (*p) == 123 )
		goto st1;
	goto st17;
st1:
	if ( ++p == pe )
		goto _test_eof1;
case 1:
	switch( (*p) ) {
		case 32: goto tr1;
		case 33: goto tr2;
		case 35: goto tr3;
		case 38: goto tr4;
		case 45: goto tr5;
		case 47: goto tr3;
		case 63: goto tr5;
		case 94: goto tr3;
		case 95: goto tr5;
		case 123: goto tr6;
	}
	if ( (*p) < 60 ) {
		if ( (*p) > 13 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr5;
		} else if ( (*p) >= 9 )
			goto tr1;
	} else if ( (*p) > 62 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr5;
		} else if ( (*p) >= 65 )
			goto tr5;
	} else
		goto tr4;
	goto tr0;
tr0:
#line 49 "../MustacheParser.m.rl"
	{
		[self setErrorAtIndex:LEN(buffer, p)];
	}
	goto st0;
#line 180 "MustacheParser.m"
st0:
cs = 0;
	goto _out;
tr1:
#line 41 "../MustacheParser.m.rl"
	{
		tag_type = ' ';
	}
	goto st2;
tr4:
#line 41 "../MustacheParser.m.rl"
	{
		tag_type = ' ';
	}
#line 45 "../MustacheParser.m.rl"
	{
		tag_type = (*p);
	}
	goto st2;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
#line 204 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st2;
		case 33: goto tr8;
		case 45: goto tr8;
		case 63: goto tr8;
		case 95: goto tr8;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto st2;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr8;
		} else if ( (*p) >= 65 )
			goto tr8;
	} else
		goto tr8;
	goto tr0;
tr5:
#line 41 "../MustacheParser.m.rl"
	{
		tag_type = ' ';
	}
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st3;
tr8:
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st3;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
#line 244 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr9;
		case 33: goto st3;
		case 45: goto st3;
		case 63: goto st3;
		case 95: goto st3;
		case 125: goto tr11;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr9;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st3;
		} else if ( (*p) >= 65 )
			goto st3;
	} else
		goto st3;
	goto tr0;
tr9:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st4;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
#line 276 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st4;
		case 125: goto st5;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto st4;
	goto tr0;
tr11:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st5;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
#line 295 "MustacheParser.m"
	if ( (*p) == 125 )
		goto st19;
	goto tr0;
st19:
	if ( ++p == pe )
		goto _test_eof19;
case 19:
	if ( (*p) == 123 )
		goto tr41;
	goto tr40;
tr2:
#line 41 "../MustacheParser.m.rl"
	{
		tag_type = ' ';
	}
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
#line 45 "../MustacheParser.m.rl"
	{
		tag_type = (*p);
	}
	goto st6;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
#line 324 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr16;
		case 33: goto tr17;
		case 45: goto tr17;
		case 63: goto tr17;
		case 95: goto tr17;
		case 125: goto tr18;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr16;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr17;
		} else if ( (*p) >= 65 )
			goto tr17;
	} else
		goto tr17;
	goto tr15;
tr15:
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st7;
tr22:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st7;
tr16:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st7;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
#line 373 "MustacheParser.m"
	if ( (*p) == 125 )
		goto tr20;
	goto st7;
tr20:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st8;
tr18:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st8;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
#line 399 "MustacheParser.m"
	if ( (*p) == 125 )
		goto st20;
	goto tr0;
tr42:
#line 22 "../MustacheParser.m.rl"
	{ mark = p; }
	goto st20;
st20:
	if ( ++p == pe )
		goto _test_eof20;
case 20:
#line 411 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr42;
		case 123: goto tr41;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr42;
	goto tr40;
tr17:
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st9;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
#line 429 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr22;
		case 33: goto st9;
		case 45: goto st9;
		case 63: goto st9;
		case 95: goto st9;
		case 125: goto tr20;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr22;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st9;
		} else if ( (*p) >= 65 )
			goto st9;
	} else
		goto st9;
	goto st7;
tr3:
#line 45 "../MustacheParser.m.rl"
	{
		tag_type = (*p);
	}
	goto st10;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
#line 460 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st10;
		case 33: goto tr25;
		case 45: goto tr25;
		case 63: goto tr25;
		case 95: goto tr25;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto st10;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr25;
		} else if ( (*p) >= 65 )
			goto tr25;
	} else
		goto tr25;
	goto tr0;
tr25:
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st11;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
#line 490 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr26;
		case 33: goto st11;
		case 45: goto st11;
		case 63: goto st11;
		case 95: goto st11;
		case 125: goto tr20;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr26;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st11;
		} else if ( (*p) >= 65 )
			goto st11;
	} else
		goto st11;
	goto tr0;
tr26:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st12;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
#line 522 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st12;
		case 125: goto st8;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto st12;
	goto tr0;
tr6:
#line 45 "../MustacheParser.m.rl"
	{
		tag_type = (*p);
	}
	goto st13;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
#line 540 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st13;
		case 33: goto tr31;
		case 45: goto tr31;
		case 63: goto tr31;
		case 95: goto tr31;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto st13;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr31;
		} else if ( (*p) >= 65 )
			goto tr31;
	} else
		goto tr31;
	goto tr0;
tr31:
#line 24 "../MustacheParser.m.rl"
	{
		identifier_start = p;
	}
	goto st14;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
#line 570 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto tr32;
		case 33: goto st14;
		case 45: goto st14;
		case 63: goto st14;
		case 95: goto st14;
		case 125: goto tr34;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr32;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st14;
		} else if ( (*p) >= 65 )
			goto st14;
	} else
		goto st14;
	goto tr0;
tr32:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st15;
st15:
	if ( ++p == pe )
		goto _test_eof15;
case 15:
#line 602 "MustacheParser.m"
	switch( (*p) ) {
		case 32: goto st15;
		case 125: goto st16;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto st15;
	goto tr0;
tr34:
#line 28 "../MustacheParser.m.rl"
	{
		[self.delegate parser:self foundTag:identifier_start ofLength:LEN(identifier_start, p) withSigil:tag_type];
		if(abort) { p--; {cs = (mustache_parser_error); goto _again;} }
	}
	goto st16;
st16:
	if ( ++p == pe )
		goto _test_eof16;
case 16:
#line 621 "MustacheParser.m"
	if ( (*p) == 125 )
		goto st5;
	goto tr0;
	}
	_test_eof17: cs = 17; goto _test_eof; 
	_test_eof18: cs = 18; goto _test_eof; 
	_test_eof1: cs = 1; goto _test_eof; 
	_test_eof2: cs = 2; goto _test_eof; 
	_test_eof3: cs = 3; goto _test_eof; 
	_test_eof4: cs = 4; goto _test_eof; 
	_test_eof5: cs = 5; goto _test_eof; 
	_test_eof19: cs = 19; goto _test_eof; 
	_test_eof6: cs = 6; goto _test_eof; 
	_test_eof7: cs = 7; goto _test_eof; 
	_test_eof8: cs = 8; goto _test_eof; 
	_test_eof20: cs = 20; goto _test_eof; 
	_test_eof9: cs = 9; goto _test_eof; 
	_test_eof10: cs = 10; goto _test_eof; 
	_test_eof11: cs = 11; goto _test_eof; 
	_test_eof12: cs = 12; goto _test_eof; 
	_test_eof13: cs = 13; goto _test_eof; 
	_test_eof14: cs = 14; goto _test_eof; 
	_test_eof15: cs = 15; goto _test_eof; 
	_test_eof16: cs = 16; goto _test_eof; 

	_test_eof: {}
	if ( p == eof )
	{
	switch ( cs ) {
	case 17: 
	case 18: 
#line 33 "../MustacheParser.m.rl"
	{
		// Write out all the static text up to this tag
		[self.delegate parser:self foundText:mark ofLength:LEN(mark, p)];

		// Move the mark up to this point
		mark =  p;
	}
	break;
	case 1: 
	case 2: 
	case 3: 
	case 4: 
	case 5: 
	case 6: 
	case 7: 
	case 8: 
	case 9: 
	case 10: 
	case 11: 
	case 12: 
	case 13: 
	case 14: 
	case 15: 
	case 16: 
#line 49 "../MustacheParser.m.rl"
	{
		[self setErrorAtIndex:LEN(buffer, p)];
	}
	break;
	case 19: 
	case 20: 
#line 22 "../MustacheParser.m.rl"
	{ mark = p; }
#line 33 "../MustacheParser.m.rl"
	{
		// Write out all the static text up to this tag
		[self.delegate parser:self foundText:mark ofLength:LEN(mark, p)];

		// Move the mark up to this point
		mark =  p;
	}
	break;
#line 696 "MustacheParser.m"
	}
	}

	_out: {}
	}

#line 142 "../MustacheParser.m.rl"

	nread += p - buffer;
	return nread;
}

- (void)abort
{
	abort = YES;
}

- (void)reset
{
	
#line 717 "MustacheParser.m"
	{
	cs = mustache_parser_start;
	}

#line 155 "../MustacheParser.m.rl"
}

- (void)abortWithError:(NSError *)parseError
{
	[self abort];
	[self setError:parseError];
}

- (BOOL)isInErrorState
{
	return cs == 
#line 734 "MustacheParser.m"
0
#line 165 "../MustacheParser.m.rl"
 ? YES : NO;
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
	return cs == 
#line 755 "MustacheParser.m"
17
#line 182 "../MustacheParser.m.rl"
 ? YES : NO;
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
