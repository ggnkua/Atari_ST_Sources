/* konvertiert WORDPLUS dictionary to ascii */

#include "stdio.h"
#include "stdlib.h"

#define  DICT		"D:\SPELLING.DIC"
#define  ASCII		"\SPELLING.ASC"
#define  TEST		"\SPELLING.DIC"

void main(void)
{
char st[100]="";
register char c;
register int i=0;
FILE *f,*g;
register long wd=0L;

f=fopen(TEST,"rb");
g=fopen(ASCII,"w");
if (!f)
	{
	puts("File not open\n");
	exit(1);
	}
fgetc(f);fgetc(f);
do
	{
	c=fgetc(f);
	if (c<32)
		{
		fputs(st,g);
		fputc('\n',g);
		i=c;
		st[i+1]='\0';
		wd++;
		if (wd % 1000 == 0)
			printf("%7ld %30s\n",wd,st);
		}
	else
		{
		st[i++]=c;
		st[i]='\0';
		}
	}
while (!feof(f));
fclose(f);
fclose(g);
exit(0);
}

		

