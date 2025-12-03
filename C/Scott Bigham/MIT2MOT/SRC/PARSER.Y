%union {
  long numval;
  char str[256];
}

%token LPAREN RPAREN COMMA PLUS AT MINUS POUND COLON SLASH NL
%token <str> OP OP_MREG ID STRING REG
%token <str> D_COMM D_LCOMM D_ELIST D_IDLIST D_NONE D_OPTINT D_ORG
%token <str> D_SLIST D_UNS
%token <numval> NUMBER

%type <str> operand reglist regrange expr_val size_field
%type <str> expr_list id_list string_list
%type <numval> expr

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
     | ID COLON {fprintf(yyout, "%s:", $1);}
     ;

directive: D_COMM ID COMMA expr {
	     fprintf(yyout, "\t%s\t%s, %ld", $1, $2, $4);
	   }
	 | D_LCOMM ID COMMA expr {
	     fprintf(yyout, "%s:%s\t%s\t%ld", $2,
	       (strlen($2) <= 6 ? "" : "\n"), $1, $4
	     );
	   }
	 | D_ELIST expr_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_IDLIST id_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_NONE {fprintf(yyout, "\t%s", $1);}
	 | D_OPTINT {fprintf(yyout, "\t%s", $1);}
	 | D_OPTINT expr {fprintf(yyout, "\t%s", $1);}
	 | D_ORG expr_val {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_SLIST string_list {fprintf(yyout, "\t%s\t%s", $1, $2);}
	 | D_UNS {yyerror("Unsupported assembler directive %s", $1);}
	 ;

instr: OP {fprintf(yyout, "\t%s", $1);}
     | OP operand {fprintf(yyout, "\t%s\t%s", $1, $2);}
     | OP operand COMMA operand {fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);}
     | OP_MREG reglist COMMA operand {
	 fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);
       }
     | OP_MREG operand COMMA reglist {
	 fprintf(yyout, "\t%s\t%s, %s", $1, $2, $4);
       }
     ;

operand: POUND expr_val {sprintf($$, "#%s", $2);}
       | REG {strcpy($$, $1);}
       | REG AT {sprintf($$, "(%s)", $1);}
       | REG AT PLUS {sprintf($$, "(%s)+", $1);}
       | REG AT MINUS {sprintf($$, "-(%s)", $1);}
       | REG AT LPAREN expr_val RPAREN {sprintf($$, "%s(%s)", $4, $1);}
       | REG AT LPAREN expr_val COMMA REG size_field RPAREN {
	   sprintf($$, "%s(%s,%s%s)", $4, $1, $6, $7);
	 }
       | expr_val {strcpy($$, $1);}
       ;

size_field: /* nothing */  {$$[0] = '\0';}
	  | COLON ID {sprintf($$, ".%s", $2);}
	  ;

reglist: regrange {strcpy($$, $1);}
       | REG SLASH REG {sprintf($$, "%s/%s", $1, $3);}
       | REG SLASH regrange {sprintf($$, "%s/%s", $1, $3);}
       | reglist SLASH REG {sprintf($$, "%s/%s", $1, $3);}
       | reglist SLASH regrange {sprintf($$, "%s/%s", $1, $3);}
       ;

regrange: REG MINUS REG {sprintf($$, "%s-%s", $1, $3);}
	;

expr_val: expr {sprintf($$, "%ld", $1);}
	| ID {strcpy($$, $1);}
	;

expr: NUMBER {$$ = $1;}
    | expr PLUS expr {$$ = $1 + $3;}
    | expr MINUS expr {$$ = $1 - $3;}
    | MINUS expr {$$ = -$2;}
    ;

expr_list: expr_val {strcpy($$, $1);}
	 | expr_list COMMA expr_val {sprintf($$, "%s, %s", $1, $3);}
	 ;

id_list: ID {strcpy($$, $1);}
       | id_list COMMA ID {sprintf($$, "%s, %s", $1, $3);}
       ;

string_list: STRING {strcpy($$, $1);}
	   | string_list COMMA STRING {sprintf($$, "%s, %s", $1, $3);}
	   ;

%%

#include <stdarg.h>
#include <string.h>
#include "global.h"

main(ac, av)
     int ac;
     char *av[];
{
  char *s, buf[40];

  if ((ac != 2) && (ac != 4)) {
    fprintf(stderr, "usage: %s [-o filename] filename\n", av[0]);
    exit(1);
  }
  if (!(yyin = fopen(av[ac - 1], "r"))) {
    fprintf(stderr, "%s: cannot open input file %s\n", av[0], av[ac - 1]);
    exit(1);
  }
  if (ac == 4) {
    strcpy(buf, av[2]);
  } else {
    strcpy(buf, av[ac - 1]);
    s = strrchr(buf, '.');
    if (!s)
      strcat(buf, ".s");
    else
      strcpy(s + 1, "s");
  }
  if (!(yyout = fopen(buf, "w"))) {
    fprintf(stderr, "%s: cannot open output file %s\n", av[0], buf);
    exit(1);
  }
  init_hash();
  yyparse();
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
