%{
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "ytab.h"
#include "global.h"

unsigned long line_num = 1;
%}

ID	[A-Za-z_\.][A-Za-z0-9_]*
NUM	([0-9]+)|(0x[0-9a-fA-f]+)
WS	[ 	][	 ]*

%%

{WS}			;
"|".*$			;
{NUM}			{yylval.numval=strtol(yytext, NULL, 0); return NUMBER;}
{ID}			{
			int n=lookup(yytext, yylval.str);
			  if (n==0) {
			    strcpy(yylval.str, yytext); return ID;
			  } else return n;
			}
\"([^"\n\\]|\\\")*\"	{strcpy(yylval.str, yytext); return STRING;}
"("			return LPAREN;
")"			return RPAREN;
","			return COMMA;
":"			return COLON;
"@"			return AT;
"+"			return PLUS;
"-"			return MINUS;
"/"			return SLASH;
"#"			return POUND;
"\n"			line_num++; return NL;
.			yyerror("Illegal character %c", *yytext);
