#include <stdio.h>
#include "link68.h"

char *errst1 = 0;
char *errst2 = 0;
long errnum1 = 0;
long errnum2 = 0;

char progname[] = PROGNAME;

extern endit();
extern int exstat;

/************************************************************************/
/*									*/
/* banner() -- print the sign-on message				*/
/*									*/
/************************************************************************/

banner()
{
  printf("--------------------------------------------------\n");
  printf("LINK68 Overlay Linker for GEMDOS       Release 1.2\n");
  printf("08/11/86                       All Rights Reserved\n");
  printf("Copyright (c) 1983-86       Digital Research, Inc.\n");
  printf("--------------------------------------------------\n\n");
}


/************************************************************************/
/*									*/
/* errorx(errnum, ptr) -- error processor for all modules.		*/
/*									*/
/*	Does the action specified for the error number.  The usual	*/
/*	action is to print a message and exit.				*/
/*									*/
/*	Any values other than those passed through the two parameters	*/
/*	are passed in the global variables errst1, errval1, & errval2.	*/
/*									*/
/************************************************************************/

extern putarrow();
VOID
errorx(errnum, st)

int errnum;				/* error number			*/
BYTE *st;				/* usually a string, not always	*/

{
switch (errnum)
{
	case BADCHAR:
		putarrow();
		printf("%s: ILLEGAL CHARACTER: '%s'\n",
			progname, st);
		endit(-1);
	case BADSYNT:
		putarrow();
		printf("%s: SYNTAX ERROR, EXPECTED: %s\n", 
			progname, st);
		endit(-1);
	case CMDTRUNC:
		putarrow();
		printf("%s: UNEXPECTED END OF COMMAND STREAM\n", progname);
		endit(-1);
	case BADOPT:
		putarrow();
		printf("%s: UNRECOGNIZED OR MISPLACED OPTION NAME: \"%s\"\n",
			progname, st);
		endit(-1);
	case NOROOM:
		printf("%s: HEAP OVERFLOW -- NOT ENOUGH MEMORY\n");
		endit(-1);
	case BADNUM:
		putarrow();
		printf("%s: IMPROPERLY FORMED HEX NUMBER: \"%s\"\n",
			progname, st);
		endit(-1);
	case MORECMD:
		putarrow();
		printf("%s: PARSE END BEFORE COMMAND STREAM END\n", progname);
		endit(-1);
	case BADINFIL:
		printf("%s: CANNOT OPEN %s FOR INPUT\n", progname, st);
		endit(-1);
	case XTRACFIL:
		putarrow();
		printf("%s: NESTED COMMAND FILES NOT ALLOWED\n", progname);
		endit(-1);
	case XESSOVLS:
		printf("%s: TOO MANY OVERLAYS\n", progname);
		endit(-1);
	case CMDLONG:
		printf("%s: COMMAND LINE TOO LONG\n", progname);
		endit(-1);
	case OVTODEEP:
		putarrow();
		printf("%s: OVERLAYS NESTED TOO DEEPLY\n", progname);
		endit(-1);
	case DISCONTIG:
		printf("%s: CANNOT SET DATA OR BSS BASE WHEN USING OVERLAYS\n",
			progname);
		endit(-1);
	case BADOVREF:
	  printf("%s: ILLEGAL REFERENCE TO OVERLAY SYMBOL %s FROM MODULE %s\n",
		 progname, st, errst1);
	  exstat++;
	  return;
	case READERR:
	  printf("%s: READ ERROR ON FILE: %s\n", progname, st);
	  endit(-1);
	case FORMATERR:
	  printf("%s: FILE FORMAT ERROR IN %s\n", progname, st);
	  endit(-1);
	case NORELOC:
	  printf("%s: NO RELOCATION BITS IN %s\n", progname, st);
	  endit(-1);
	case BADSYMFLG:
	  printf("%s: INVALID SYMBOL FLAG IN %s, SYMBOL: \"%s\"\n", 
		progname, st, errst1);
	  endit(-1);
	case DUPDEF:
	  printf("%s: \"%s\" DOUBLY DEFINED IN %s\n", progname, errst1, st);
	  return;
	case SYMOFL:
	  printf("%s: SYMBOL TABLE OVERFLOW\n", progname);
	  endit(-1);
	case BADTEMP:
	  printf("%s: UNABLE TO OPEN TEMPORARY FILE: %s\n", progname, st);
	  endit(-1);
	case INTERR:
	  printf("%s: INTERNAL ERROR IN %s\n", progname, st);
	  endit(-1);
	case UNDEF:
	  printf("%s: UNDEFINED SYMBOL(S):\n", progname);
	  return;
	case BADOUT:
	  printf("%s: UNABLE TO CREATE FILE: %s\n", progname, st);
	  endit(-1);
	case SEEKERR:
	  printf("%s: SEEK ERROR ON FILE: %s\n", progname, st);
	  endit(-1);
	case SHRTOFL:
	  printf("%s: SHORT ADDRESS OVERFLOW AT %lx IN %s\n", progname,
							errnum1, st);
	  return;
	case TSZERR:
	  printf("%s: TEXT SIZE ERROR IN %s\n", progname, st);
	  return;
	case OWRTERR:
	  printf("%s: WRITE ERROR ON FILE: %s\n", progname, st);
	  return;
	case REOPNERR:
	  printf("%s: UNABLE TO REOPEN FILE: %s\n", progname, st);
	  endit(-1);
	case RELADROFL:
	  printf("%s: RELATIVE ADDRESS OVERFLOW AT %lx IN %s\n", progname,
							errnum1, st);
	  return;
	case BADRELOC:
	  printf("%s: INVALID RELOCATION FLAG IN %s\n", st);
	  endit(-1);
	default:
		printf("%s: INTERNAL ERROR -- UNSPECIFIED ERROR\n", progname);
		endit(-1);
}
}


/************************************************************************/
/*									*/
/* usage() -- prints a simple help message				*/
/*									*/
/*	This routine is called if only the program name is typed	*/
/*									*/
/************************************************************************/

VOID
usage()
{
printf("USAGE: %s [options] output = file, file, ...\n\n", progname);
printf("THE OPTIONS ARE:\n\n");
printf("\tABSOLUTE\n");
printf("\tBSSBASE[hex number]\n");
printf("\tCOMMAND[filename]\n");
printf("\tCHAINED\n");
printf("\tDATABASE[hex number]\n");
printf("\tIGNORE\n");
printf("\tLOCALS\n");
/*printf("\tMAP\n");*/
printf("\tNOLOCALS\n");
printf("\tSYMBOLS\n");
printf("\tTEMPFILES[drive]\n");
printf("\tTEXTBASE[hex number]\n");
printf("\tUNDEFINED\n");
}


