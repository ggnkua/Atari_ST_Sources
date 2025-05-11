/* APP.C - pre-processor for as */

/* Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of Gas, the GNU Assembler.

The GNU assembler is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU Assembler General
Public License for full details.

Everyone is granted permission to copy, modify and redistribute
the GNU Assembler, but only under the conditions described in the
GNU Assembler General Public License.  A copy of this license is
supposed to have been given to you along with the GNU Assembler
so you can know your rights and responsibilities.  It should be
in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.  */

/* JF:  Made this a part of gas on RMS's orders.  I thought it was probably
   OK as a separate program.  Ohwell.  */

/*
 *	Assembler PreProcessor.
 *
 * A filter from the string in_string (length in_length) to the created string
 * out_string.  (Total bytes allocted is in out_length, free bytes at end
 * are in out_free.) No switches.
 *
 * Pass input characters to output.
 * BUT	Translate / * comment * / into just 1 space.
 *	Translate \n # (line_comment_chars) comment \n into just \n.
 *	Translate | (comment_chars) comment \n into just \n
 *	Within a / * . . . * / comment, other chars is unnoticed:
 *	they do not begin a comment.
 *	Within a # or | comment a / * is unnoticed: it does not
 *	start any comment.
 *	Generally: comments do not nest.

x x x x / * . . . . * / y y y		=> x x x x space y y y
x x x | . . . \n			=> x x x \n

 * BUT	A # in column 1 translates its line to
 *	a .line ... ; .file ... \n form.

# . . .					=> much hair (!)

 * BUT	Don't emit 2 whitespace characters in a row.
 *		Whitespace characters are '\t' and ' '.
 *	Remove all whitespace preceeding a \n.
 *	Special crock: change any emitted whitespace to a space
 *	unless it is before the 1st symbol. I.E. keep tabs only
 *	to the left of the keyword.

. . . \t space				=> space [could => \t]
. . . \t space \n			=> . . . \n
. . . \t k e y \t w o r d s		=> . . . \t k e y space w o r d s

 * BUT	Don't repress whitespace in a character constant.

' \t \t					=> ' \t \t
" \t \t "				=> " \t \t "

 * BUT	Change any single-quoted constant into a decimal constant.

' \t					=> ( 9 )

 * BUT	Remove any \ seen, with a complaint.

\ h					=> ERROR!

 * BUT	In a character constant, permit certain escape sequences;
 *	warn of and repress all others.
 * BUT	Translate \ \n in a character constant to \ n.

" x \ \n y "				=> " x \ n y "

 * BUT	Always make sure that newlines are merely postponed to
 *	a convenient time, rather than forgotten. This helps relate
 *	error message's line numbers from the output file to
 *	line numbers in the input file, transparently.

" x \ \n y " \n				=> " x \ n y " \n \n

 * BUT	On premature end of input file, warn stderr, and append
 *	a guess at what characters are sufficient to make the
 *	output file contain no unclosed comments or stings.
 *	An empty file is not a premature end-of-file.
 */

#include <stdio.h>
#include "as.h"

/* JF these used to be down at the bottom.  I moved them up here for the
   new comment stuff, which should be fun. */

static char	lex [256];
static char	symbol_chars[] = 
	"$._ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

extern char comment_chars[];
extern char line_comment_chars[];

#define LEX_IS_SYMBOL_COMPONENT		(1)
#define LEX_IS_WHITESPACE		(2)
#define LEX_IS_LINE_SEPERATOR		(4)
#define LEX_IS_COMMENT_START		(8)	/* JF added these two */
#define LEX_IS_LINE_COMMENT_START	(16)
#define IS_SYMBOL_COMPONENT(c)		(lex [c] & LEX_IS_SYMBOL_COMPONENT)
#define IS_WHITESPACE(c)		(lex [c] & LEX_IS_WHITESPACE)
#define IS_LINE_SEPERATOR(c)		(lex [c] & LEX_IS_LINE_SEPERATOR)
#define IS_COMMENT(c)			(lex [c] & LEX_IS_COMMENT_START)
#define IS_LINE_COMMENT(c)		(lex [c] & LEX_IS_LINE_COMMENT_START)

/*
 * Structure is of several internal filters.
 *
 * Input, munge, repress whitespace, synchronise '\n's.
 */


static int		c;		/* Last character input. COMMON COUPLED. */

static char *		context;	/* Error to emit if we see end of file. */
				/* 0 if we have no special context. */
static char *		closing;	/* String to emit if we see End-Of-File. */

static char	*in_string;
static int	in_length;

static char	*out_begin;
static char	*out_string;
static int	out_length;
static int	out_free;

/* When the output buffer fills up, allocate in units of. . . */
#define OUT_INC		100

static input_context_begin (contex, clos) /* CONTEXT DOES NOT NEST. */
     char * contex;
     char * clos;
{
  context = contex;
  closing = clos;
}

static
input_context_end ()
{
  input_context_begin (0, "");
}

/* JF input_to_c now returns zero when we hit EOF.  This is so we can
   STOP without exit()ing */

static int lineno=1;
extern char *file_name;		/* For error msgs */

/* Returns 1 on success, zero on failure */
static
input_to_c ()
{
	char	former_c;
	char	*p;

	former_c = c;
	if(in_length == 0) {
		if (!context) {
			if (former_c != '\n') {
				if(!flagseen['W'])
					fprintf(stderr,"%s:%d:Newline appended to last (partial) line.\n",file_name,lineno);
				repress_whitespace('\n');
			}
		} else if(closing[0]) {
			repress_whitespace_string(closing);
			if(!flagseen['W'])
				fprintf(stderr,"%s:%d:Premature EOF in %s.  Appended \"%s\" to file.",file_name,lineno,context,closing);
		} else if(!flagseen['W'])
			fprintf(stderr,"%s:%d:Premature EOF in %s.\n",file_name,lineno,context);

		c = EOF;
		return 0;
	}
	c = *in_string;
	in_string++;
	--in_length;
	if(c=='\n')		/* JF for error msgs */
		lineno++;
	return 1;
}

static
uninput_to_c ()
{
	if(c=='\n')
		--lineno;
	--in_string;
	*in_string = c;
	++in_length;
}

do_scrub_begin()
{
	repress_whitespace_begin ();
}

/* We store a pointer to the final string in *store_string, and the final
   length in *store_length */
do_scrub(save,save_length,in,size,store_string,store_length)
char *save;
int save_length;
char *in;
int size;
char **store_string;
int *store_length;
{
	int	last_char;		/* Prior value of c. */
	char	work[6];
	static char *old_string;

	in_string = in;
	in_length = size;

	if(old_string) {
		free(old_string);
		old_string = 0;
	}
	out_string=out_begin=xmalloc(save_length+OUT_INC);
	out_length=save_length+OUT_INC;
	if(save_length) {
		bcopy(save,out_string,save_length);
		out_string+=save_length;
	}
	out_free=OUT_INC;

	input_context_end ();		/* No special context yet. */
	c = '\n';			/* If file is empty, input_to_c() */
					/* should not complain. */
	for (last_char = '\n'; ;last_char = c) {
		if(input_to_c () == 0)
			break;
		switch (c) {
		default:
			if(last_char!='\n' || ! IS_LINE_COMMENT(c)) {
				if(! IS_COMMENT(c)) {

					/* Nothing interesting */
					repress_whitespace (c);
					break;
				}

					/* Boring comment */
				input_context_begin ("comment", "\n");
				while (input_to_c () && c != '\n')
					;
				context = 0;
				closing = "";
				repress_whitespace ('\n');
				break;
			}
			/* It is a LINE_COMMENT:  Do hackery */
			while(input_to_c() && IS_WHITESPACE(c))
				;
			if(c<'0' || c>'9') {
				input_context_begin ("line comment", "\n");
				while (input_to_c () && c != '\n')
					;
				context = 0;
				closing = "";
				repress_whitespace ('\n');
				break;
			}

			/* Turn it into .line .file */
			input_context_begin ("#ed .line, .file line", "\n");
			repress_whitespace_string (".line ");
			repress_whitespace(c);

		/* We have to use repress_whitespace, else as' */
		/* expression analyser will be upset because is is */
		/* now "efficient" and doesn't look for whitespaces. */
		/* synch_newlines (c); */
			while (input_to_c () &&  c != '\n' && c != '\"')
				repress_whitespace (c);
			repress_whitespace(';'); /* Ends expression. */
			if (c == '\"') {
				repress_whitespace_string (".file ");
				parse_string ();
			}
			/* Ignore rest of line. */
			while (c != '\n' && input_to_c ())
				;
			repress_whitespace ('\n');
			input_context_end ();
			break;

		case '/':
			if(input_to_c () == 0)
				break;
			if (c != '*') {	/* Not comment beginning after all. */
				repress_whitespace ('/');
				uninput_to_c();
				break;
			}
			input_context_begin ("/* comment */", "*/\n");
			for (;;) {
				if(input_to_c () == 0)
					break;
				if (c == '*') {
					if(input_to_c () == 0)
						break;
					if (c == '/')
						break; /* Comment closed. */
					else
			/* Keep looking for '*', '/'. */
						uninput_to_c();
			/* This could be a '*'. */
				} else if (c == '\n')
					postpone_newline ();
			}
			repress_whitespace (' '); /* A comment parsed. */
			input_context_end ();
			break;

		case '\'':
			input_context_begin ("\'-ed constant", "\\\n");
			if(input_to_c () == 0)
				break;
			input_context_end ();
			/* 'ed chars become decimal constants. */
			sprintf (work, "(%d)", c & 0xFF);
			repress_whitespace_string (work);
			break;

		case '\"':
			parse_string ();
			break;
		}
	}

	*store_string=out_begin;
	*store_length=out_length-out_free;
	old_string=out_begin;
}



static
parse_string ()			/* Just saw opening double-quote. */
{
	repress_whitespace ('\"');
	while ( input_to_c () && c != '\"' ) {
		input_context_begin ("Double-quoted string literal","\"\n");
		if (c == '\n') {
			synch_newlines ('\\');
			synch_newlines ('n');
			postpone_newline ();
			continue;
		}
		if (c != '\\') {
			synch_newlines (c);
			continue;
		}
		input_context_begin ("\\-ed escaped character in string\
 literal","\\\"\n");
		if(input_to_c () == 0)
			return;
		switch (c) {
		default:
			if(!flagseen['W'])
				fprintf(stderr,"%s:%d:dropping unknown escaped character '\\%c'\n",
 file_name,lineno,c);
			break;
		/* YES! This is not a bug. */
		/* BSD 4.2 as actually takes this literally. */
		/* They pass backslash newline in a .asciX string as */
		/* a {.byte 10} and continue the string (!!). */
		case '\n':
			postpone_newline ();
			synch_newlines ('\\');
			synch_newlines ('n');
			break;

		case '\"':
		case '\\':
		case 'b':
		case 'f':
		case 'n':
		case 'r':
		case 't':
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			synch_newlines ('\\');
			synch_newlines (c);
			break;
		}
	}				/* while not closing doublequote */
	input_context_end ();
	repress_whitespace ('\"');
}

static
repress_whitespace_string (str)
 register char *		str;
{
	while (* str)
		repress_whitespace (* str ++);
}

/*
 *
 *		repress_whitespace (character)
 *
 * Repress redundant whitespace.
 * Whitespace is (possibly) retained:
 *		After beginning of line. ('\n' or ';')
 *		Between symbols (when it is needed as a seperator).
 *		After 1st symbol of line. (Keeps assembler debuggers sane.)
 *				(Permits assembler to demand whitespace
 *				after keyword: catches some human bugs.)
 * Whitespace before whitespace or end-of-line ('\n', ':', ';') is repressed.
 *
 * value of				state:
 * prior:
 *
 * line_seperator		We are at beginning of line.
 *
 * whitespace		We should emit prior unless the next character is
 *				whitespace or newline.
 *
 * symbol_component		We have just emitted (part of) a symbol.
 *
 * other		We have just emitted a valid seperator. Any following
 *				whitespace is redundant and will be repressed.
 *
 *
 * We know we have seen the last char of a symbol when: IS_SYMBOL_COMPONENT(prior)
 * and NOT IS_SYMBOL_COMPONENT(chr).
 */

static int	prior;

		/* Number of (complete) symbols seen on this line. */
static int	completed_symbol_count;

static
repress_whitespace_begin ()
{						/* Set up lexical table. */
	register char *		p;

	synch_newlines_begin ();

	bzero (lex, sizeof(lex));		/* Trust NOBODY! */
	lex [' ']		|= LEX_IS_WHITESPACE;
	lex ['\t']		|= LEX_IS_WHITESPACE;
	for (p =symbol_chars;*p;++p)
		lex [*p] |= LEX_IS_SYMBOL_COMPONENT;
	lex ['\n']		|= LEX_IS_LINE_SEPERATOR;
	lex [':']		|= LEX_IS_LINE_SEPERATOR;
	lex [';']		|= LEX_IS_LINE_SEPERATOR;
	for (p=comment_chars;*p;p++)
		lex[*p] |= LEX_IS_COMMENT_START;
	for (p=line_comment_chars;*p;p++)
		lex[*p] |= LEX_IS_LINE_COMMENT_START;

	prior = '\n';		/* Remember we are at the start of a line. */
	completed_symbol_count = 0;
}

static
repress_whitespace(chr)		/* Repress redundant whitespace */
	 int chr;
{
	if (IS_SYMBOL_COMPONENT(prior) && ! IS_SYMBOL_COMPONENT(chr))
		completed_symbol_count ++;
	if (IS_LINE_SEPERATOR(chr))
		completed_symbol_count = 0;


	if (IS_WHITESPACE(chr)) {
		if (	 IS_LINE_SEPERATOR(prior)
			|| (IS_SYMBOL_COMPONENT(prior) && completed_symbol_count < 2)
			|| IS_WHITESPACE(prior))
			prior = completed_symbol_count ? ' ' : chr;
		else
			prior = '-';	/* Don't want ANY whitespace. */
					/* Any seperator will do. */
	} else {
		if ( ! IS_LINE_SEPERATOR(chr)) {
			/* Maybe we should give whitespace. */
			if (IS_WHITESPACE(prior))
				synch_newlines (prior);
		}
		synch_newlines (chr);
		prior = chr;
	}
}

/*
 *						postpone_newline ()
 *						synch_newlines (character)
 *
 * Whenever we see a newline, emit postponed newlines too, so we can keep
 * output file's newlines in synch, so error messages reflect correct
 * input file's line numbers.
 */

static
int		newline_count;

static
synch_newlines_begin ()
{
	newline_count = 0;		/* Pretend 1st char of input file */
					/* follows '\n'. */
}

static
postpone_newline ()
{
	newline_count ++;
}

static
synch_newlines (ch)
	 register char		ch;
{
	if(out_free == 0) {
		int	n;

		n = out_string-out_begin;
		out_begin = xrealloc(out_begin,out_length+OUT_INC);
		out_string = out_begin + n;
		out_length += OUT_INC;
		out_free += OUT_INC;
	}

	*out_string = ch;
	out_string++;
	out_free--;

	if (ch == '\n') {
		while (newline_count --) {
			if(out_free == 0) {
				int	n;

				n = out_string-out_begin;
				out_begin = xrealloc(out_begin,out_length+OUT_INC);
				out_string = out_begin + n;
				out_length+=OUT_INC;
				out_free+=OUT_INC;
			}

			*out_string = ch;
			out_string++;
			out_free--;
		}
		newline_count = 0;
	}
}

/* end: app.c */
