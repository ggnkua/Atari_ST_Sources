%{
#include <stdlib.h>
#include <string.h>
#undef YY_DECL
#define YY_DECL	int yylex(int *lib,char **text)
#define FORUM	1
#define LIB		2
#define FNAME	3
#define PROMPT	'\007'		/* MY prompt char. change accordinly.*/
%}
forum		[a-z]+
num			[0-9]+
lib			[ \t]+"Lib:"[ \t]*
fname		[^\n\\]+
%x	skip get_number
%%
^{forum}/[ \t\n]			*text=strdup(yytext);BEGIN(skip);return FORUM;
^{fname}/\/					*text=strdup(yytext);BEGIN(skip);return FNAME;
^\[{num},{num}\]{lib}/[0-9]	BEGIN(get_number);
\n							/**/
.							BEGIN(skip);
<get_number>{num}			*lib = atoi(yytext);BEGIN(skip);return LIB;
<skip>.*\n					BEGIN(INITIAL);
%%
static char *forum,*fname;
static int lib;

void main(int ac,char *av[])
{
	char *text;
	int	new_lib,c;

	if((yyin=fopen(av[1],"r"))==NULL)
	{
		fprintf(stderr,"Can't open %s\n",av[1]);
		exit(1);
	}
	if((yyout=fopen(av[2],"w"))==NULL)
	{
		fprintf(stderr,"Can't create %s\n",av[2]);
		exit(1);
	}
	forum = strdup("?");		/* strdup copies string to malloced memory */
	fname = strdup("?");
	lib = -1;

	while(c=yylex(&new_lib,&text))
		switch(c)
		{
		case FORUM:
			if(strcmp(forum,text)!=0)
			{
				free(forum);
				forum = text;
				fprintf(yyout,"g %s|\n>WA \"%c\"|\n",text,PROMPT);
			}
			else
				free(text);
			break;
		case LIB:
			if(lib!=new_lib)
			{
				lib = new_lib;
				fprintf(yyout,"LIB %d|\n>WA \"%c\"|\n",new_lib,PROMPT);
			}
			break;
		case FNAME:
			if(strcmp(fname,text)!=0)
			{
				free(fname);fname=text;
				fprintf(yyout,"DOW %s|\n>WA \"omputer:\"|\n%s|\n"
								">WA \"%c\"|\n",text,text,PROMPT);
			}
			else
				free(text);
		}
	exit(0);
}
