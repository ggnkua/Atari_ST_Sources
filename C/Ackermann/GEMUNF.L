%{
#include <aes.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define output(x)	(fputc(x,yyout))
%}
%%
[ \t]*\n\n				output('\n');output('\n');
[ \t]*\n[ \t]*.			yyless(1);output(' ');
.						ECHO;
%%
#include <stdarg.h>
void quit(void)
{
	appl_exit();
}
char *get_file(char *prompt);
int	alertf(int,char *,...);

void main(void)
{
	char	*fname;

	appl_init();
	atexit(quit);

	if(fname=get_file("formatted file"))
	{
		if((yyin=fopen(fname,"r"))==NULL)
		{
			alertf(1,"[3][Can't open |%s][ ok ]",fname);
			exit(EXIT_FAILURE);
		}
		if(fname=get_file("Unformatted file"))
		{
			if((yyout=fopen(fname,"w"))==NULL)
			{
				alertf(1,"[3][Can't create |%s][ ok ]",fname);
				exit(EXIT_FAILURE);
			}
			yylex();
		}
	}
	exit(EXIT_SUCCESS);
}

/* formatted alert box ansi style */
int alertf(int n, char *fmt,...)
{
	va_list	args;
	char buf[BUFSIZ];

	va_start(args,fmt);
	vsprintf(buf,fmt,args);
	va_end(args);
	return form_alert(1,buf);
}

/*  get full path via fileselector */
char *get_file(char *prompt)
{
	static char path[BUFSIZ]="",result[BUFSIZ],name[14];
	short	button;
	char	*p;

	if(path[0]=='\0')
	{
		getcwd(result,BUFSIZ);		/* get current dir. */
		strmfp(path,result,"*.*");	/* combine path, fname to complete*/
		memset(result,0,BUFSIZ);	/* clear result */
		*name='\0';
	}
	fsel_exinput(path,name,&button,prompt);	/* OK with LC5 else req. tos>=1.4 */
	if(button!=1 || *name=='\0')	/*  if cancel or no filename selected*/
		return NULL;
	strcpy(result,path);		/* copy path to result; */
	p=strrchr(result,'\\');		/* fsel always has at least one \ in path. */
	strcpy(p+1,name);			/* append filenname to path */
	return	result;
}

	