/*
 * Turingol parser
 *  references:
 *      Donald E. Knuth "Semantics of Context-Free Languages"
 *      Mathematical Systems Theory, Vol. 2, No. 2, 1968
 */

%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "lexer.h"
#include "symtabs.h"
#include "output.h"

/* Get bison to dump it's behaviour to stderr */
#define YYDEBUG 1
extern int yydebug;

/* The cheap and easy alternative... */
#define YYERROR_VERBOSE 1

#define YYPRINT(file, type, value) yyprint(file, type, value)
/*void yyprint(FILE *file, int type, YYSTYPE value);*/
int yyerror(char *s);

SymNode *alphabet_lookup(char *symbol);
STNode *goto_lookup(char *label);

%}

/* Semantic datatypes */
%union {
	STNode *st;
	SymNode *sym;
	char *id;
	int dir;
}

/* Tokens */
%token TAI	/* tape alphabet is */
%token IF	/* if the tape symbol is */
%token THEN	/* then */
%token GOTO	/* to to */
%token MOVE	/* move */
%token PRINT	/* print */
%token <dir> DIR /* left | right*/
%token ONESQUARE /* one square */
%token <id> IDENT

%token COLON	/* : */
%token COMMA	/* , */
%token DQUOTE	/* " */
%token LBRACE	/* { */
%token PERIOD	/* . */
%token RBRACE	/* } */
%token SEMICOLON /* ; */

/* Semantic value: points to the state immediately following this statement */
%type <st> statement statements

%{

/* The parser functions */
int yyparse();
int yyprint(FILE *file, int type, YYSTYPE value);

%}

%%

program:	  declarations SEMICOLON statements PERIOD
		;

declarations:	  TAI IDENT { sym_insert(&alphabet, strdup($2), NULL); }
		| declarations COMMA IDENT { sym_insert(&alphabet, strdup($3), NULL); }
		;

statements:	  statement { $$ = $1; }
		| statements SEMICOLON statement { $$ = $3; }
		| error SEMICOLON {}
		;

statement:	  /* empty */ { $$ = st_last(); }
		| IF DQUOTE IDENT { $<st>$ = st_StartIF(alphabet_lookup($3)); }
		  DQUOTE THEN statement { $$ = st_EndIF($<st>4); }
		| IDENT { st_labelled($1); } COLON statement { $$ = $4; }
		| LBRACE statements RBRACE { $$ = $2; }
		| GOTO IDENT { $$ = goto_lookup($2); }
		| MOVE DIR ONESQUARE { $$ = st_MOVE($2); }
		| PRINT DQUOTE IDENT { $<sym>$ = alphabet_lookup($3); }
		  DQUOTE { $$ = st_PRINT($<sym>4); }
		;

%%

/* Lookup the alphabet and abort if symbol not found */
SymNode *alphabet_lookup(char *symbol)
{
  SymNode *sym = sym_lookup(&alphabet, symbol);

  if(sym == NULL) {
    /* error */
    yyerror(strcat("symbol \"", strcat(symbol, "\" not found.\n")));
    /* YYABORT;*/
  }
  return(sym);
}

STNode *goto_lookup(char *label)
{
  SymNode *sym = sym_lookup(&labels, label);

/*printf("GOTO(%s)\n", (sym == NULL) ? NULL : sym->name);*/

  if(sym == NULL) {
    sym_insert(&forwardrefs, strdup(label), st_last());
    return(st_GOTO(NULL));
  } else
    return(st_GOTO(sym->state));
}

/* Print out semantic values */
int yyprint(FILE *file, int type, YYSTYPE value)
{
  switch(type) {
  case DIR:
    fprintf(file, " %d", value.dir);
    break;
  case IDENT:
    fprintf(file, " %s", value.id);
    break;
  }
  return(0);
}

/* Trivial error handler */
int yyerror(char *s)
{
  printf("line %d: %s\n", line_num, s);
  return(0);
}

/* Fix forward-referencing GOTOs */
void postprocess()
{
  SymNode *node, *cur;
 
  for(node = forwardrefs; node != NULL; ) {
    if((cur = sym_lookup(&labels, node->name)) == NULL) {
      /* Label not defined */
      printf("turingol: label \"%s\" not defined.\n", node->name);
      exit(1);
    }

    node->state->data.dest = cur->state;
    cur = node;
    node = sym_traverse(&node);
    free(cur->name);
    free(cur);
  }

  forwardrefs = NULL;
}

void usage(char *name, char *err1, char *err2)
{
  printf("%s%s\nUsage: %s [-o outfile] [-r runfile] [-d] [sourcefile]\n", err1, err2, name);
  exit(1);
}

/*
handle command line parms:

"filename" == input filename			(default: stdin)
"-d" == debug
"-o filename" == output filename for tuples	(default: stdout)
"-r filename" == output filename for execution	(default: don't run)

*/

int main(int argc, char *argv[])
{
  int i;
  FILE *outfile = NULL, *runfile = stdout;

  yyin = stdin;
  if(argc > 1)
    for(i = 1; i < argc; i++) {
      if(argv[i][0] == '-') {
	if(!strcmp(argv[i], "-d"))
	  yydebug = 1;
	else if(!strcmp(argv[i], "-o")) {
	  if(++i < argc && outfile == stdout) {
	    if((outfile = fopen(argv[i], "w")) == NULL) {
	      /* file open error */
	      fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	      exit(1);
	    }
	  } else
	    usage(argv[0], "Bad option: ", argv[i - 1]);
	} else if(!strcmp(argv[i], "-r")) {
	  if(++i < argc && runfile == NULL) {
	    if((runfile = fopen(argv[i], "w")) == NULL) {
	      /* file open error */
	      fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	      exit(1);
	    }
	  } else
	    usage(argv[0], "Bad option: ", argv[i - 1]);
	} else
	  usage(argv[0], "Unknown option: ", argv[i]);
      } else {
	if((yyin = fopen(argv[i], "r")) == NULL) {
	  /* file open error */
	  fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	  exit(1);
	}
      }
    }

  st_init();
  i = yyparse();
  fclose(yyin);

  if(!i) {
    postprocess();
    if (outfile != NULL)
    {
	tuple_header(outfile);
	traverse_graph(outfile, tuple_out);
	fclose(outfile);
    }
    if(runfile != NULL) {
      st_run(runfile);
      fclose(runfile);
    }
    return(0);
  } else
    return(1);
}
