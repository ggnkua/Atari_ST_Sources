%{
extern unsigned long tmp_labels[10][2], tmp_label_cnt;
%}

%union {
  long numval;
  char str[256];
}

%token NL
%token <str> OP OP_MREG ID STRING REG TMPLABEL TMPLABELfb
%token <str> D_COMM D_LCOMM D_ELIST D_IDLIST D_NONE D_OPTINT D_ORG
%token <str> D_SLIST D_UNS
%token <numval> NUMBER

%type <str> operand reglist regrange expr sym_expr size_field
%type <str> expr_list id_list string_list
%type <numval> num_val op

%left '+' '-'
%left '&' '^' '!' '|'
%left '*' '/' '%' '>' '<'
%left UMINUS

%%

prog: linelist;

linelist: /* nothing */
        | linelist line {fputc('\n', yyout);}
        ;

line: label directive NL
    | label instr NL
    | label NL
    ;

label: /* nothing */
     | ID ':' {fprintf(yyout, "%s:", $1);}
     | TMPLABEL {
       int i = $1[0] - '0';
	 if (tmp_labels[i][1] == 0)
	   tmp_labels[i][0] = ++tmp_label_cnt;
	 else
	   tmp_labels[i][0] = tmp_labels[i][1];
	 tmp_labels[i][1] = 0;
	 fprintf(yyout, "LT%lu:", tmp_labels[i][0]);
       }
     ;

directive: D_COMM ID ',' num_val {
	     fprintf(yyout, "\t%s\t%s, %ld", $1, $2, $4);
	   }
	 | D_LCOMM ID ',' num_val {
	     fprintf(yyout, "%s:%s\t%s\t%ld", $2,
	       (strlen($2) <= 6 ? "" : "\n"), $1, $4
	     );
	   }
	 | D_ELIST expr_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_IDLIST id_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_NONE {fprintf(yyout, "\t%s", $1);}
	 | D_OPTINT {fprintf(yyout, "\t%s", $1);}
	 | D_OPTINT num_val {fprintf(yyout, "\t%s", $1);}
	 | D_ORG expr {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_SLIST string_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_UNS {yyerror("warning: unsupported assembler directive %s", $1);}
	 ;

instr: OP {fprintf(yyout, "\t%s", $1);}
     | OP operand {fprintf(yyout, "\t%s\t%s", $1, $2);}
     | OP operand ',' operand {fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);}
     | OP_MREG reglist ',' operand {
	 fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);
       }
     | OP_MREG operand ',' reglist {
	 fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);
       }
     ;

operand: '#' expr {sprintf($$, "#%s", $2);}
       | REG {strcpy($$, $1);}
       | REG '@' {sprintf($$, "(%s)", $1);}
       | REG '@' '+' {sprintf($$, "(%s)+", $1);}
       | REG '@' '-' {sprintf($$, "-(%s)", $1);}
       | REG '@' '(' expr ')' {sprintf($$, "%s(%s)", $4, $1);}
       | REG '@' '(' expr ',' REG size_field ')' {
	   sprintf($$, "%s(%s,%s%s)", $4, $1, $6, $7);
	 }
       | expr {strcpy($$, $1);}
       ;

size_field: /* nothing */  {$$[0] = '\0';}
	  | ':' ID {sprintf($$, ".%s", $2);}
	  ;

reglist: regrange {strcpy($$, $1);}
       | REG '/' REG {sprintf($$, "%s/%s", $1, $3);}
       | REG '/' regrange {sprintf($$, "%s/%s", $1, $3);}
       | reglist '/' REG {sprintf($$, "%s/%s", $1, $3);}
       | reglist '/' regrange {sprintf($$, "%s/%s", $1, $3);}
       ;

regrange: REG '-' REG {sprintf($$, "%s-%s", $1, $3);}
	;

expr: num_val {sprintf($$, "%ld", $1);}
    | sym_expr {strcpy($$, $1);}
    ;

sym_expr: ID {strcpy($$, $1);}
	| TMPLABELfb {
	  int i = $1[0] - '0';
	  unsigned long l;
	    if ($1[1] == 'f') {
	      if (tmp_labels[i][1] == 0)
		tmp_labels[i][1] = ++tmp_label_cnt;
	      l = tmp_labels[i][1];
	    } else {
	      l = tmp_labels[i][0];
	      if (l == 0)
		yyerror("Unresolved temporary label %db", i);
	    }
	    sprintf($$, "LT%lu", l);
	  }
	| sym_expr op sym_expr {sprintf($$, "%s%c%s", $1, (char)$2, $3);}
	| num_val op sym_expr {sprintf($$, "%ld%c%s", $1, (char)$2, $3);}
	| sym_expr op num_val {sprintf($$, "%s%c%ld", $1, (char)$2, $3);}
	;

op: '+' {$$ = '+';}
  | '-' {$$ = '-';}
  | '&' {$$ = '&';}
  | '^' {$$ = '^';}
  | '!' {$$ = '!';}
  | '|' {$$ = '|';}
  | '*' {$$ = '&';}
  | '/' {$$ = '/';}
  | '%' {$$ = '%';}
  | '<' {$$ = '<';}
  | '>' {$$ = '>';}
  ;

num_val: NUMBER {$$ = $1;}
       | num_val '+' num_val {$$ = $1 + $3;}
       | num_val '-' num_val {$$ = $1 - $3;}
       | num_val '&' num_val {$$ = $1 & $3;}
       | num_val '^' num_val {$$ = $1 ^ $3;}
       | '!' num_val {$$ = !$2;}
       | num_val '|' num_val {$$ = $1 | $3;}
       | num_val '*' num_val {$$ = $1 & $3;}
       | num_val '/' num_val {$$ = $1 / $3;}
       | num_val '%' num_val {$$ = $1 % $3;}
       | num_val '<' num_val {$$ = $1 << $3;}
       | num_val '>' num_val {$$ = $1 >> $3;}
       | '-' num_val %prec UMINUS {$$ = -$2;}
       | '(' num_val ')' {$$ = $2;}
       ;

expr_list: expr {strcpy($$, $1);}
	 | expr_list ',' expr {sprintf($$, "%s, %s", $1, $3);}
	 ;

id_list: ID {strcpy($$, $1);}
       | id_list ',' ID {sprintf($$, "%s, %s", $1, $3);}
       ;

string_list: STRING {strcpy($$, $1);}
	   | string_list ',' STRING {sprintf($$, "%s, %s", $1, $3);}
	   ;

%%

#include <stdarg.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "global.h"
#include "patchlev.h"

unsigned long tmp_labels[10][2];
unsigned long tmp_label_cnt;

main(ac, av)
     int ac;
     char *av[];
{
  char *s, buf[40], outfnam[40];
  int i;
  time_t t;
  struct tm *T;

  if ((ac != 2) && (ac != 4)) {
    fprintf(stderr, "usage: %s [-o filename] filename\n", av[0]);
    exit(1);
  }
  if (!(yyin = fopen(av[ac - 1], "r"))) {
    fprintf(stderr, "%s: cannot open input file %s\n", av[0], av[ac - 1]);
    exit(1);
  }
  if (ac == 4) {
    strcpy(outfnam, av[2]);
  } else {
    strcpy(outfnam, av[ac - 1]);
    s = strrchr(outfnam, '.');
    if (!s)
      strcat(outfnam, ".s");
    else
      strcpy(s + 1, "s");
  }
  if (!(yyout = fopen(outfnam, "w"))) {
    fprintf(stderr, "%s: cannot open output file %s\n", av[0], outfnam);
    exit(1);
  }
  time(&t);
  T = localtime(&t);
  strftime(buf, 40, "%b %d %Y %H:%M:%S", T);
  fprintf(yyout, "; Generated by mit2mot v%d.%d.%d on %s\n\n",
    M2M_VERSION, M2M_RELEASE, M2M_PATCHLEVEL, buf);
  init_hash();
  if (yyparse() != 0) {
    clear_hash();
    fclose(yyin);
    fclose(yyout);
    unlink(outfnam);
    exit(1);
  }
  for (i = 0; i < 10; i++)
    if (tmp_labels[i][1] != 0) {
      yyerror("Unresolved temporary label %df", i);
      fprintf(yyout, "LT%lu:\n", tmp_labels[i][1]);
    }
  clear_hash();
  fclose(yyin);
  fclose(yyout);
  return 0;
}

void yyerror(s)
     char *s;
{
  va_list ap;

  fprintf(stderr, "At line %lu:  ", line_num);
  va_start(ap, s);
  vfprintf(stderr, s, ap);
  va_end(ap);
  fputc('\n', stderr);
}

#ifndef yywrap
yywrap() {return 1;}
#endif
