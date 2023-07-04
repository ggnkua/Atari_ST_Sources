
/* program to piss about with TT headers */

/* syntax: TTHEAD -options filename(s)
	default: show them
	-f	make fastload
	-F	unmake fastload
	-l	load into TT RAM
	-L	dont load
	-m	malloc into TT RAM
	-M	dont
	-qQ	dont wait
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <osbind.h>

#define SET	1
#define	CLEAR -1

char fastflag,loadflag,mallocflag;
char writeflag; long memsize;
char waitflag;

struct stheader {
	short magic;
	long len[4];
	long res1;
	long res2;
	short reloc;
} sthead;

void do_exit(short ret)
{
	if ( (waitflag) && (getenv("SHELL")==NULL) )
		{
		printf("Press any key");
		Cconin();
		}
	exit(ret);
}

void do_filename(char *name)
{
FILE *fp;
#define old sthead.res2

	fp=fopen(name,writeflag ? "rb+" : "rb");
	printf("\r%s\t",name);
	if (fp==NULL)
		{
		printf("cannot open\n");
		return;
		}
	if (fread(&sthead,sizeof(sthead),1,fp)!=1)
		printf("read error\n");
	else if (sthead.magic!=0x601a)
		printf("not executable\n");
	else
		{
		if (writeflag==0)
			{
			unsigned long size;
			if (old&1)
				printf("Fast ");
			if (old&2)
				printf("Load ");
			if (old&4)
				printf("Malloc ");
			size=old;
			size=(size>>28)*128;
			printf("%ldk",size+128);
			putchar('\n');
			}
		else
			{
			if (fastflag==SET)
				old|=1;
			else if (fastflag==CLEAR)
				old&=~1;
			if (loadflag==SET)
				old|=2;
			else if (loadflag==CLEAR)
				old&=~2;
			if (mallocflag==SET)
				old|=4;
			else if (mallocflag==CLEAR)
				old&=~4;
			rewind(fp);
			if (memsize)
				{
				memsize>>=7;			/* /128 */
				old&=0x0FFFFFFF;
				old|=((--memsize)<<28);
				}
			if (fwrite(&sthead,sizeof(sthead),1,fp)!=1)
				printf("write error\n");
			else
				printf("OK\n");
			}
		}
	fclose(fp);
}

int main(int argc, char *argv[])
{
int count;
	waitflag=1;
	printf("TTHEAD 1.1 Copyright Andy Pennell 1991. All Rights Reserved\n");
	count=1;
	if (argc==1) goto badargs;
	while (count<argc)
		{
		if (argv[count][0]=='-')
			{
			char *s,c;
			s=argv[count++];
			s++;
			while (c=*s++)
				{
				switch (c)
					{
					case 'f': fastflag=SET; break;
					case 'F': fastflag=CLEAR; break;
					case 'l': loadflag=SET; break;
					case 'L': loadflag=CLEAR; break;
					case 'm': mallocflag=SET; break;
					case 'M': mallocflag=CLEAR; break;
					case 'q': case 'Q': waitflag=0; break;
					default:
					if (!isdigit(c))
						goto badargs;
					memsize=(long)(c-'0');
					while ( (c=*s++) && (isdigit(c)) )
						{
						memsize=(memsize*10L)+c-'0';
						}
					s--;
					break;
					}
				if ( (c!='q') && (c!='Q') )
					writeflag=1;
				}
			}
		else
			break;
		}
	while (count<argc)
		do_filename(argv[count++]);
	do_exit(0);

badargs:
	printf("\
args: [-options] filenames\n\
Attribute Set Clear\n\
========= === =====\n\
Fast load f   F\n\
TT Load   l   L\n\
TT Malloc m   M\n\
size      123 (in Kbytes)\n\
");
	do_exit(5);
	return 0;			/* nonsense */
}

