/************************************************/
/*            PARSER.C  von 15.10.1990          */
/*        (w) & (c) 1990 by Grischa Ekart       */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/

#include <setjmp.h>
#include "formula.h"

double   value;
static   int token;
jmp_buf  err_buf;
extern   YYTYPE yylval;
extern   FUNC func_tab[];

int      parse(char *string);
double   expr(void);
double   term(void);
double   factor(void);
void     yyerror(int message);

int
parse(char *string)
{
   if(setjmp(err_buf) != 0)
      return(FALSE);

   yyinit(string);
   value = expr();
   return(TRUE);
}

double
expr(void)
{
   double   ret_val;
   
   token = yylex();
   ret_val = term();
   token = yylex();
   while(token == PLUS || token == MINUS)
   {
      if(token == PLUS)
      {
         token = yylex();
         if(token == EOS)
            return(ret_val);

         ret_val += term();
      }
      if(token == MINUS)
      {
         token = yylex();
         if(token == EOS)
            return(ret_val);

         ret_val -= term();
      }
      token = yylex();
   }
   yyback();
   return(ret_val);
}

double
term(void)
{
   double   ret_val;

   ret_val = factor();
   token = yylex();
   while(token == STAR || token == SLASH)
   {
      if(token == STAR)
      {
         token = yylex();
         ret_val *= factor();
      }
      if(token == SLASH)
      {
         token = yylex();
         ret_val /= factor();
      }
      token = yylex();
   }
   yyback();
   return(ret_val);
}

double
factor(void)
{
   int      function;
   double   ret_val;

   if(token == FUNCTION)
   {
      function = yylval.function;
      if(yylex() != LPAREN)
         yyerror(MIS_LPAR);

      ret_val = func_tab[function].function(
         expr());

      if(yylex() != RPAREN)
         yyerror(MIS_RPAR);

   }
   else if(token == LPAREN)
   {
      ret_val = expr();
      if(yylex() != RPAREN)
         yyerror(MIS_RPAR);
   }
   else if(token == NUMBER)
      ret_val = yylval.number;
   else
      yyerror(UNEXP_CHAR);

   return(ret_val);
}

void
yyerror(int message)
{
   error_msg(message);
   longjmp(err_buf, 1);
}
