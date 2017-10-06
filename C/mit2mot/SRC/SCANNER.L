%{
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "ytab.h"
#include "global.h"

unsigned long line_num = 1;
%}

ID	[A-Za-z_\.][A-Za-z0-9_]*(\.?)
NUM	([0-9]+)|(0x[0-9a-fA-f]+)
WS	[ 	][	 ]*
ES	\\([abfnrtv'"?\\]|[0-7]{1,3}|x[0-9a-fA-F]+)

%%

{WS}			;
"|".*$			;
^"#".*$			;
{NUM}			{
			  yylval.numval = strtoul(yytext, NULL, 0);
			  return NUMBER;
			}
{ID}			{
			  int n = lookup(yytext, yylval.str);

			  if (n == 0) {
			    char *s = yylval.str + yyleng - 1;

			    strcpy(yylval.str, yytext);
			    if (*s == '.') *s = '_';
			    return ID;
			  } else return n;
			}
[0-9]:			{strcpy(yylval.str, yytext); return TMPLABEL;}
[0-9][fb]		{strcpy(yylval.str, yytext); return TMPLABELfb;}
\"([^"\n\\]|{ES})*\"	{strcpy(yylval.str, yytext); return STRING;}
[-+(),:@&^!*/%<>#]	return *yytext;
"\n"			{line_num++; return NL;}
.			yyerror("Illegal character %c", *yytext);
