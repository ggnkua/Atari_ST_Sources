/* A Unix similar "GREP" utility by Dany Roth, Zurich,Switzerland
   written as an example and as a tool for searching a directory
   for a search pattern.
   This program was written using Latice C V 5.06.02 from Hisoft
   Users of command line or NEODESK can easily redirect the output
   to a printer or a file using the >Filename or >PRT: redirection
*/  

#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <osbind.h>

#define MAXLINE 256

void showdir(char *,char *);
int search(char *, FILE *, char *);
int getline(char *line,int max, FILE *);

/* find: print lines that match a pattern */
/* global options for
	-i: ignore case
	-x: except the search string
	-n: include line number
*/
int except=0,number=0,ignore=0;

void main(int argc, char **argv)
{
	int c,i=1,parm=1;	/* parm is used for the proper argv[parm] */
	if(argc==4)			/* in case of options */
		parm=2;
	if(argc>2 && argv[1][0] == '-')	/* are there options ? */
		while( (c= argv[1][i++]) != '\0')
			switch(c)		/* yes so check them */
			{
				case 'x':	/* case it is only excluding lines */
				case 'X':
					except=1;
					break;
				case 'n':	/* include line numbers */
				case 'N':
					number=1;
					break;
				case 'i':	/* ignore case */
				case 'I':
					ignore=1;
					break;
				default:	/* user gave us unknown option */
					printf("find: illegal option %c\n",c);
					argc=0;
					break;
			}
	if(argc <3)
	{
		printf("GREP by Dany Roth V.1 1991, Switzerland\n\n");
		printf("Usage: find [-x][-n][-i] files pattern\n");
		printf("   -x: Lines excluding search pattern\n");
		printf("   -n: Include line number\n");
		printf("   -i: Ignore case X=x\n");
		exit(1);
	}
	else 					/* everything OK do the search */
	{
		showdir(argv[parm],argv[parm+1]);
		exit(0);	/* everything OK */
	}
}

/* this routine gets a file pointer and searches the file for pattern */ 
int search(char *strng, FILE *fp,char *path)
{
	long lineno=0,found=0;
	char line[MAXLINE];
	while(getline(line,MAXLINE,fp)>0)	/* check all lines in the file */
	{
		lineno++;
		if(ignore)		/* -i was used, turn it to lower case */
		{
			strlwr(line);
			strlwr(strng);
		}
		if( (strstr(line, strng) !=NULL) !=except)
		{
			if(number)		/* with line number */
				printf("%s:(%ld) %s",path,lineno,line);
			else			/* without numbering */
				printf("%s: %s",path,line);
			found++;
		}
	}
	return found;
}

/* reads a line untill a return '\n' or max line lebgth exceeded*/
int getline(char *s, int lim,FILE *fp)
{
	int c,i;
	i=0;
	while(--lim>0 && (c=getc(fp) ) !=EOF && c!='\n')
		s[i++]=c;
	if(c=='\n')
		s[i++]=c;
	s[i]='\0';
	return i;
}

/* travels through a directory of file pattern */
void showdir(char *name,char *strng)
{
	long total_found=0,files=0,found;
	FILE *fp;
	char *p,path[120];
	struct FILEINFO info;
	strcpy(path,name);
	Fsetdta(&info);
	if(!Fsfirst(name,0))
		do
		{			/* first concatenate path+filename */
			if( (p=strrchr(path,'\\')) !=NULL)
				p++;
			else
				p=path;
			strcpy(p,info.name);
			fp=fopen(path,"rb");		/* open the file for read */
			if(fp!=NULL)
			{
				if( (found=search(strng,fp,path))>0)
				{
					printf("%ld lines were found\n\n",found);
					total_found +=found;
					files++;
				}
				fclose(fp);
			}
			else
				return;
		} while(Fsnext()==0);
		printf("\n%ld lines were found in %ld files\n",total_found,files);
}

