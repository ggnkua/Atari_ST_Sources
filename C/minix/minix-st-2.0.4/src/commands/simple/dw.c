/* dw - find duplicate words in a file		Author: Nelson Beebe */

/* Usage: dw [file] */

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(int get_token, (FILE *f ));
_PROTOTYPE(void make_lower, (void));
_PROTOTYPE(void other, (void));
_PROTOTYPE(void word, (void));

char last_word[1024];
char yytext[1024];
int yyleng;
long last_line_number = 0L;
long line_number = 1L;

#define	T_EOF	EOF
#define	T_WORD	0
#define T_WHITE	1
#define T_OTHER	2

#define	isinitial(c)	(isalpha(c) || ((c) == '_'))
#define ismiddle(c)	(isinitial(c) || isdigit(c))

int main(argc, argv)
int argc;
char *argv[];
{
  register int token;
  FILE *f;

  if (argc > 2) {
	fprintf(stderr, "Usage: dw [file]\n");
	exit(1);
  }

  if (argc == 2) {
	f = fopen(argv[1], "r");
	if (f == NULL) {
		fprintf(stderr, "dw: cannot open file %s\n", argv[1]);
		exit(1);
	}
  } else {
	f = stdin;
  }
  last_word[0] = '\0';

  while ((token = get_token(f)) != T_EOF) {
	switch (token) {
	    case T_WORD:	word();		break;
	    case T_WHITE:			break;
	    case T_OTHER:	other();	break;
	    default:				break;
	}
  }
  exit(EXIT_SUCCESS);
  return(0);			/* keep optimizers happy */
}

int get_token(f)
FILE *f;
{
  register int c;
  register char *p;
  register int token;

  p = yytext;
  c = fgetc(f);
  if (c == EOF)
	token = T_EOF;
  else if (isinitial(c)) {
	token = T_WORD;
	while (ismiddle(c)) {
		*p++ = c;
		c = fgetc(f);
	}
	ungetc(c, f);		/* push back lookahead */
  } else if (isspace(c)) {	/* whitespace forms single token */
	token = T_WHITE;
	while (isspace(c)) {
		if (c == '\n') line_number++;
		*p++ = c;
		c = fgetc(f);
	}
	ungetc(c, f);		/* push back lookahead */
  } else {			/* all other tokens are single char */
	token = T_OTHER;
  }
  *p = '\0';			/* terminate token in yytext[] */
  yyleng = (int) (p - yytext);
  return(token);
}

void make_lower()
{
  int n;
  for (n = 0; n < yyleng; ++n)
	if (isupper(yytext[n])) yytext[n] = tolower(yytext[n]);
}

void other()
{
  strcpy(last_word, yytext);	/* so intervening 'words' do not */
  /* Trigger output of duplicates */
}

void word()
{
  make_lower();
  if (strcmp(yytext, last_word) == 0) {
	if (last_line_number == line_number)
		printf("%ld: %s\n", line_number, yytext);
	else
		printf("%ld-%ld: %s\n", last_line_number, line_number, yytext);
  }
  strcpy(last_word, yytext);
  last_line_number = line_number;
}
