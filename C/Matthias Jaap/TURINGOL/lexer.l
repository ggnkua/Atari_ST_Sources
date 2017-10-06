/* Turingol lexical analyzer. */

%{
#include "symtabs.h"
#include "y.tab.h"

int line_num = 1;

static void count();
int yywrap();

%}

/* Character classes */
ID	[a-z]+
WS	[ \t\n]+

%%
"#".*\n	/* Strip comments */		{ count();			}

tape{WS}alphabet{WS}is			{ count(); return(TAI);		}
if{WS}the{WS}tape{WS}symbol{WS}is	{ count(); return(IF);		}
then					{ return(THEN);			}
go{WS}to				{ count(); return(GOTO);	}
move					{ return(MOVE);			}
print					{ return(PRINT);		}
left					{ yylval.dir = -1; return(DIR);	}
right					{ yylval.dir = +1; return(DIR);	}
one{WS}square				{ count(); return(ONESQUARE);	}

{ID}					{ yylval.id = yytext; return(IDENT); }

":"					{ return(COLON);		}
","					{ return(COMMA);		}
"\""					{ return(DQUOTE);		}
"{"					{ return(LBRACE);		}
"."					{ return(PERIOD);		}
"}"					{ return(RBRACE);		}
";"					{ return(SEMICOLON);		}

{WS}					{ count();			}

.           				{ printf("Unrecognized character: %s\n", yytext); }
%%

/* Maintain the line counter
 * (called whenever a newline could appear in the input)
 */
static void count()
{
	int i;

	for(i = 0; yytext[i] != '\0'; i++)
		if(yytext[i] == '\n')
			line_num++;
}

/* Trivial yywrap() to keep lex happy (only ever one source file) */
int yywrap()
{
	return(1);
}
