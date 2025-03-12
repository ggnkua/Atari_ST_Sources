/************************************************/
/*            SCANNER.C  von 15.10.1990         */
/*        (w) & (c) 1990 by Grischa Ekart       */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "formula.h"

YYTYPE   yylval;
int      position;
char     *string;
extern   FUNC func_tab[];

void     yyinit(char *string);
int      yylex(void);
void     yyback(void);
void     yyerror(int message);
int      func_cmp(char *func_name);

void
yyinit(char *input)
{
   string = input;
   position = -1;
}

int
yylex(void)
{
   char  func_name[80];
   int   func_pos = 0;

   position++;
   switch(string[position])
   {
      case '\0':
         return(EOS);
      case '+':
         return(PLUS);
      case '-':
         return(MINUS);
      case '*':
         return(STAR);
      case '/':
         return(SLASH);
      case '(':
         return(LPAREN);
      case ')':
         return(RPAREN);
   }
   if(isdigit(string[position]))
   {
      sscanf(&string[position], "%lf",
         &yylval.number);

      while(isdigit(string[position]) ||
         string[position] == '.')
      {
         position++;
      }
      position--;
      return(NUMBER);
   }
   if(isalpha(string[position]))
   {
      do
      {
         func_name[func_pos++] =
            string[position++];

      } while(isalpha(string[position]));
      position--;
      func_name[func_pos] = '\0';
      if(func_cmp(func_name))
         return(FUNCTION);
      else
         yyerror(UNKNOWN_FUNC);
   }
   yyerror(UNKNOWN_CHAR);
}

void
yyback(void)
{
   position--;
}

int
func_cmp(char *func_name)
{
   int   index = 0;

   while(TRUE)
   {
      if(func_tab[index].name == 0)
         break;

      if(strcmp(func_name, func_tab[index].name)
         == 0)
      {
         yylval.function = index;
         return(TRUE);
      }
      index++;
   }
   return(FALSE);
}
