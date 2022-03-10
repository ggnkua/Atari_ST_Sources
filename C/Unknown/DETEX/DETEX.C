#define FALSE 0
#define TRUE 1
#define CTRL_D 4

#define MAX 200
#define LIMIT_REACHED "Too many entries in the argument file, ask ramaer@cs to increase the limit.\n"

#include <stdio.h>
#include <ctype.h>
#include <string.h>

int narg = 20,longest = 14,start = 14;
char line[256];
char *(arguments[MAX]) =
	{ "author{"
	, "begin{"
	, "begin{array}"
	, "begin{tabular}"
	, "cite{"
	, "documentstyle"
	, "end{"
	, "hspace{"
	, "label{"
	, "multicolumn{"
	, "multiput{"
	, "newcommand{"
	, "newcounter{"
	, "pageref{"
	, "put{"
	, "ref{"
	, "renewcommand{"
	, "setcounter{"
	, "special{"
	, "vspace{" };


fill_line()
{
	int cn;
	for (cn = 0; start < longest; ) line[cn++] = line[start++];
	while (cn < longest && !feof(stdin)) line[cn++] = getchar();
	while (cn < longest) line[cn++] = CTRL_D;
	start = 0;
}
#define void(len) {start = len;}

char rd()
{	if (start < longest) return line[start++];
	else if (feof(stdin)) exit(0);
	else return getchar();
}

VoidArgFrom(len)
int len;
{	char c;
	void(len);
	do	c = rd();
	while (c != '}');
}

VoidWord(c)
register char *c;
{
	do	*c = rd();
	while (isalpha(*c));
}

wrd_to_stdout(c)
register char *c;
{
	do {	putchar(*c);
		*c = rd();
	} while (isalpha(*c));
}




readargs(fn,commandname)
char * fn, *commandname;
{
	FILE * fd;
	int l,here;
char **wp;

	if ((fd = fopen(fn,"r")) == NULL) {
		fprintf(stderr,"Could not open argument file %s.\n",fn);
		exit(-4);
		}
	while (fgets(line,256,fd) != NULL && narg < MAX) {
		/* fscanf(fd,"%[^\n]\n",line); */
		l = strlen(line);
		if (line[l-1] == '\n') line[--l] = 0;
		if (l > longest) longest = l;
		if (l == 0)
		     fprintf(stderr,"Warning: empty line in argument file %s,\n\
this will yield rediculous results.\n",fn);
		for (here = narg;
		     here > 0 && strcmp(line,arguments[here-1]) < 0;
		     here--) arguments[here] = arguments[here-1];
		arguments[here] = (char*)malloc(l+1);
		strcpy(arguments[here],line);
		narg++;
		}
	if (!feof(fd)) {
		fprintf(stderr,LIMIT_REACHED);
		exit(-5);
		}
	start = longest;
		for (wp = arguments; wp < &arguments[narg]; wp++) puts(*wp);
}

main(argc,argv)
int argc; char **argv;
{

char c = '\n';
int i,cn,len;
char **wp;
int found;
int args_read = FALSE;
int stdin_assigned = FALSE;

i = 1;
for (i = 1; i < argc; i++) {
	if (strcmp(argv[i],"-parg") == 0) {
		for (wp = arguments; wp < &arguments[narg]; wp++) puts(*wp);
		exit(0);
		}
	else if (strcmp(argv[i],"-f") == 0 && i < argc - 1) {
		if (! args_read) {
			narg = 0;
			longest = 0;
			}
		readargs(argv[++i],argv[0]);
		args_read = TRUE;
		}
	else if (strcmp(argv[i],"-help") != 0) {
		if (stdin_assigned) {
			fprintf(stderr,"Can only process one file per run,\n\
use 'cat file.. | detex [-f argument-file].. > output'\
 to handle more files.\n");
			exit(-1);
			}
		if (freopen(argv[i],"r",stdin) == NULL) {
			fprintf(stderr,"Could not read %s.\n",argv[i]);
			exit(-2);
			}
		stdin_assigned = TRUE;
		}
	else	{fprintf(stderr,"\
usage: %s [-parg] [-f argument-file].. [tex-file] [< tex-file] > output\n\
for each command '\\cmd{arg}' where 'arg' needs to be removed\n\
the argument file should contain a line 'cmd{'.  \
See '%s -parg' for defaults\n",argv[0],argv[0]);
		 exit(-3);
		}
	}

c = rd();
while (TRUE) {
	if (c == '\\') {
		fill_line();
		found = FALSE;
		for (wp = &arguments[narg-1]; !found && wp >= arguments; wp--) {
			len = strlen(*wp);
			found = strncmp(*wp,line,len) == 0;
		}
		if (found) {
			VoidArgFrom(len);
			c=rd();
		} else VoidWord(&c);
	} else if (c == '%') {
		do {c = rd();} while (c != '\n');
		c = rd();
	} else
		wrd_to_stdout(&c);
}

}
