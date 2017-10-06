/* bob.c - the main routine */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include <stdio.h>
#include <setjmp.h>
#include "bob.h"

/* Revision history

	1.0		08/15/91	Initial version for DDJ article
	1.1		08/20/91	Fixed do_for to allow null statements
	1.2		08/28/91	Fixed problem with newobject()
	1.3		09/27/91	Fixed a bug in compact_vector()
	1.3ST	12/25/91	Ported to Mark Williams C for Atari ST
						Added external reference for fgetc
*/

#define BANNER	"Bob v1.3ST - Copyright (c) 1991, by David Betz\n             Atari ST 1991, by Peter Ismen"

/* global variables */
jmp_buf	  error_trap;
char	**bobargv;
int		  bobargc;

/* external variables */
extern int decode,trace;
extern  FILE fgetc();

/* main - the main routine */
main(argc,argv)
int   argc;
char *argv[];
{
    char fullname[20];
    int i;

    osputs(BANNER);						 /* display the banner */
    osputs("\n");

    initialize(SMAX,CMAX);				 /* initialize */
    bobargc = argc - 1;
    bobargv = argv + 1;

    for (i = 1; i < argc; ++i)			 /* load and execute some code */
    {
		if (strcmp(argv[i],"-d") == 0)
			decode = 1;
		else
		{
			if (strcmp(argv[i],"-t") == 0)
				trace = 1;
			else 
			{
				strcpy(fullname,argv[i]);
				strcat(fullname,".bob");
				compile_file(fullname);
			}
		}	
	}		
    if (!execute("main"))
		printf("Can't execute 'main'\n");
}

/* compile_file - compile definitions in a file */
static compile_file(name)
char *name;
{
    FILE *ifp;
    
    if ((ifp = fopen(name,"r")) != NULL) 
    {
		compile_definitions(fgetc,ifp);
		fclose(ifp);
    }
}

/* info - display progress information */
info(fmt,a1,a2,a3,a4,a5,a6)
char *fmt;
{
    char buf1[100],buf2[100];
    
    sprintf(buf1,fmt,a1,a2,a3,a4,a5,a6);
    sprintf(buf2,"[ %s ]\n",buf1);
    osputs(buf2);
}

/* error - print an error message and exit */
error(fmt,a1,a2,a3,a4)
char *fmt;
{
    char buf1[100],buf2[100];
    
    sprintf(buf1,fmt,a1,a2,a3,a4);
    sprintf(buf2,"Error: %s\n",buf1);
    osputs(buf2);
    longjmp(error_trap,1);
}

osputs(str)
char *str;
{
    fputs(str,stderr);
}
