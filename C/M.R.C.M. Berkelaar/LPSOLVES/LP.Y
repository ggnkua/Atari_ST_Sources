/* ========================================================================= */
/* NAME  : lp.y                                                              */
/* ========================================================================= */


%token VAR CONS SIGN AR_M_OP RE_OP END_C COMMA


%{
#include "defines.h" 
#include "globals.h"

/* globals */
char Last_var[NAMELEN];
int Rows;
int Lin_term_count;
double f;
int x;
int Sign;
int isign; 	/* internal_sign variable to make sure nothing goes wrong */
		/* with lookahead */
int make_neg;	/* is true after the relational operator is seen in order */
		/* to rember if lin_term stands before or after re_op */
%}



%start inputfile
%%

inputfile	:
{
  init_read();
  isign = 0;
  make_neg = 0;
} 
		  objective_function
		  constraints
                  int_declarations
		;

constraints	: constraint
		| constraints
		  constraint
		;

constraint	: x_lineair_sum
		  RE_OP
{
  store_re_op();
  make_neg = 1; 
}
		  x_lineair_sum
                  END_C
{
  if(Lin_term_count == 0)
    
    {
      fprintf(stderr, "WARNING line %d: constraint contains no variables\n",
	      yylineno);
      null_tmp_store();
    }
  if(Lin_term_count  > 1)
    Rows++;
  if(Lin_term_count == 1)
    store_bounds();
  Lin_term_count = 0;
  isign = 0 ; make_neg = 0;
}
		;

int_declarations: /* EMPTY */
                | real_int_decls
                ;

real_int_decls  : int_declaration
                | real_int_decls int_declaration
                ;

int_declaration : int_declarator vars END_C
                ;

int_declarator  : VAR {/* check_decl(yytext);*/}/* check it here !! */
                ;

vars            : VAR {add_int_var(yytext);}
                | vars VAR {add_int_var(yytext);}
                | vars COMMA VAR {add_int_var(yytext);}
                ;

x_lineair_sum	: x_lineair_term 
		| SIGN
{
  isign = Sign; 
}
		  x_lineair_term
		| x_lineair_sum
		  SIGN
{
  isign = Sign; 
}
		  x_lineair_term
		;

x_lineair_term	: lineair_term
		| CONS
{
  if (isign ^ (!make_neg))
    f = -f;
  rhs_store(f);
  isign = 0;
}
		;

lineair_sum	: lineair_term 
		| SIGN
{
  isign = Sign;
}
		  lineair_term
		| lineair_sum
		  SIGN
{
  isign = Sign;
}
		  lineair_term
		;

lineair_term	: VAR
{
  if (isign ^ make_neg)
    var_store(Last_var, Rows, (double)-1);
  else
    var_store(Last_var, Rows, (double)1);
  isign = 0;
}
		| CONS 
		  VAR
{
  if (isign ^ make_neg)
    f = -f;
  var_store(Last_var, Rows, f);
  isign = 0;
}
		| CONS 
		  AR_M_OP
		  VAR
{
  if (isign ^ make_neg)
    f = -f;
  var_store(Last_var, Rows, f);
  isign = 0;
}
		;

objective_function: lineair_sum
		    END_C
{
  Rows++;
  Lin_term_count  =  0;
  isign = 0;
  make_neg = 0;
}
		;
%%
# include "lexyyx.c"
