diff +recursive -c e:\fas_orig/as1805/as1805.y ./as1805/as1805.y
*** e:\fas_orig/as1805/as1805.y	Tue Dec 11 14:03:06 1990
--- ./as1805/as1805.y	Wed Nov 18 16:33:32 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as2650/as2650.y ./as2650/as2650.y
*** e:\fas_orig/as2650/as2650.y	Tue Dec 11 14:40:06 1990
--- ./as2650/as2650.y	Wed Nov 18 16:33:38 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as6301/as6301.y ./as6301/as6301.y
*** e:\fas_orig/as6301/as6301.y	Tue Dec 11 14:44:52 1990
--- ./as6301/as6301.y	Wed Nov 18 16:33:52 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as6502/as6502.y ./as6502/as6502.y
*** e:\fas_orig/as6502/as6502.y	Tue Dec 11 14:48:06 1990
--- ./as6502/as6502.y	Wed Nov 18 16:33:58 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as6805/as6805.y ./as6805/as6805.y
*** e:\fas_orig/as6805/as6805.y	Tue Dec 11 14:35:06 1990
--- ./as6805/as6805.y	Wed Nov 18 16:34:06 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as6809/as6809.y ./as6809/as6809.y
*** e:\fas_orig/as6809/as6809.y	Tue Dec 11 14:31:28 1990
--- ./as6809/as6809.y	Wed Nov 18 16:34:12 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as6811/as6811.y ./as6811/as6811.y
*** e:\fas_orig/as6811/as6811.y	Tue Dec 11 14:27:08 1990
--- ./as6811/as6811.y	Wed Nov 18 16:34:22 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as7000/as7000.y ./as7000/as7000.y
*** e:\fas_orig/as7000/as7000.y	Tue Dec 11 14:12:36 1990
--- ./as7000/as7000.y	Wed Nov 18 16:34:28 1992
***************
*** 41,46 ****
--- 41,47 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as8048/as8048.y ./as8048/as8048.y
*** e:\fas_orig/as8048/as8048.y	Tue Dec 11 14:16:00 1990
--- ./as8048/as8048.y	Wed Nov 18 16:34:36 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as8051/as8051.y ./as8051/as8051.y
*** e:\fas_orig/as8051/as8051.y	Tue Dec 11 14:09:10 1990
--- ./as8051/as8051.y	Wed Nov 18 16:34:42 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/as8096/as8096.y ./as8096/as8096.y
*** e:\fas_orig/as8096/as8096.y	Tue Dec 11 14:23:42 1990
--- ./as8096/as8096.y	Wed Nov 18 16:34:50 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
diff +recursive -c e:\fas_orig/asz8/asz8.y ./asz8/asz8.y
*** e:\fas_orig/asz8/asz8.y	Tue Dec 11 14:06:56 1990
--- ./asz8/asz8.y	Wed Nov 18 16:34:58 1992
***************
*** 34,43 ****
--- 34,45 ----
  			September 12, 1990 - short file names
  			September 14, 1990 - short variable names
  			September 17, 1990 - use yylex as external
+ 			December  24, 1990 - fixed error in REG/RREG (output was 0x00)  MS
  */
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
***************
*** 662,669 ****
  
  			if( ( $1 -> value & REGDEFDBL) && ( $1 -> value & 1) )
  				fraerror("double register not on even boundry");
! 
! 			prtequvalue("C: 0x%x\n",REGBITS & ((int) $1->value));
  		}
  		else
  		{
--- 664,671 ----
  
  			if( ( $1 -> value & REGDEFDBL) && ( $1 -> value & 1) )
  				fraerror("double register not on even boundry");
! /* *** error in original Yaccfile: %x replaced by %lx  MS */
! 			prtequvalue("C: 0x%lx \n",REGBITS & ((int) $1->value));
  		}
  		else
  		{
diff +recursive -c e:\fas_orig/asz80/asz80.y ./asz80/asz80.y
*** e:\fas_orig/asz80/asz80.y	Thu Dec 13 13:11:04 1990
--- ./asz80/asz80.y	Wed Nov 18 16:35:06 1992
***************
*** 38,43 ****
--- 38,44 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define yylex lexintercept
  
Only in .: fasdiff4
diff +recursive -c e:\fas_orig/fraosub.c ./fraosub.c
*** e:\fas_orig/fraosub.c	Tue Dec 11 13:58:58 1990
--- ./fraosub.c	Wed Nov 18 16:35:12 1992
***************
*** 27,32 ****
--- 27,33 ----
  #include <stdio.h>
  #include "frasmdat.h"
  #include "fragcon.h"
+ #include "proto.h"
  
  #define OUTRESULTLEN 256
  #define NUMHEXPERL 16
diff +recursive -c e:\fas_orig/frapsub.c ./frapsub.c
*** e:\fas_orig/frapsub.c	Tue Dec 11 13:59:00 1990
--- ./frapsub.c	Wed Nov 18 16:35:18 1992
***************
*** 24,30 ****
--- 24,32 ----
  
  #include "fragcon.h"
  #include <stdio.h>
+ #include <stdlib.h>
  #include "frasmdat.h"
+ #include "proto.h"
  
  #define STRALLOCSZ 4096
  
diff +recursive -c e:\fas_orig/frasmain.c ./frasmain.c
*** e:\fas_orig/frasmain.c	Tue Dec 11 13:59:00 1990
--- ./frasmain.c	Wed Nov 18 16:36:40 1992
***************
*** 1,12 ****
  /*
  HEADER: 	;
  TITLE: 		Frankenstein Cross Assemblers;
! VERSION: 	2.0;
  DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
  		Hex format object records.  ";
  KEYWORDS: 	cross-assemblers, 1805, 2650, 6301, 6502, 6805, 6809, 
  		6811, tms7000, 8048, 8051, 8096, z8, z80;
! SYSTEM: 	UNIX, MS-Dos ;
  FILENAME: 	frasmain.c;
  WARNINGS: 	"This software is in the public domain.  
  		Any prior copyright claims are relinquished.  
--- 1,12 ----
  /*
  HEADER: 	;
  TITLE: 		Frankenstein Cross Assemblers;
! VERSION: 	2.1;
  DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
  		Hex format object records.  ";
  KEYWORDS: 	cross-assemblers, 1805, 2650, 6301, 6502, 6805, 6809, 
  		6811, tms7000, 8048, 8051, 8096, z8, z80;
! SYSTEM: 	UNIX, MS-Dos, Atari ST;
  FILENAME: 	frasmain.c;
  WARNINGS: 	"This software is in the public domain.  
  		Any prior copyright claims are relinquished.  
***************
*** 33,47 ****
  #define	Global
  
  #include <stdio.h>
  #include "frasmdat.h"
  
  FILE * intermedf = (FILE *) NULL;
- char *interfn = 
  #ifdef DOSTMP
!  "frtXXXXXX";
  #else
   "/usr/tmp/frtXXXXXX";
  #endif
  char *hexfn, *loutfn;
  int errorcnt = 0, warncnt = 0;
  int listflag = FALSE, hexflag = FALSE, hexvalid = FALSE;
--- 33,50 ----
  #define	Global
  
  #include <stdio.h>
+ #include <stdlib.h>
  #include "frasmdat.h"
+ #include "proto.h"
  
  FILE * intermedf = (FILE *) NULL;
  #ifdef DOSTMP
! char interfn[256];
  #else
+ char *interfn =
   "/usr/tmp/frtXXXXXX";
  #endif
+ 
  char *hexfn, *loutfn;
  int errorcnt = 0, warncnt = 0;
  int listflag = FALSE, hexflag = FALSE, hexvalid = FALSE;
***************
*** 54,59 ****
--- 57,90 ----
  #ifdef NOGETOPT
  #include "getopt.h"
  #endif
+ 
+ /* print a brief description of command line options */
+ usage(char *name)
+ {
+ 	fprintf(stderr,"usage:\n"
+ 		"%s [-o binary] [-l listing] [-s symbols] [-p type] [-d] input\n"
+ 		"The input file must appear after the optional entries on the command line.\n"
+ 		"If the file name is a single minus sign, the standard input is used.\n"
+ 		"\n"
+ 		"Listing File: -l filename\n"
+ 		"An annotated listing will only be produced if an optional list file is\n"
+ 		"provided.\n"
+ 		"\n"
+ 		"Hex Output File: -h filename or -o filename\n"
+ 		"The binary output will only be produced if the optional file is provided.\n"
+ 		"\n"
+ 		"Symbol Listing File: -s filename\n"
+ 		"The symbol table is dumped with one entry per line.\n"
+ 		"\n"
+ 		"Debug: -d   (Saves the intermediate files)\n"
+ 		"\n"
+ 		"Processor Selection: -p string\n"
+ 		"The operand is scanned for unique substrings which identify the target\n"
+ 		"processor. The CPU pseudo-operation has precedence over the -p option.\n"
+ 		"\n"
+         ,name);
+ }
+ 
  main(argc, argv)
  	int argc;
  	char *(argv[]);
***************
*** 69,78 ****
--- 100,117 ----
  	return		exit(2) for error, exit(0) for OK
  */
  {
+ 	extern char *defaultname;
  	extern char *optarg;
  	extern int optind;
  	int grv;
+ #ifdef DOSTMP
+ 	char *p;
+ #endif
  
+ 	argv[0] = defaultname;  /* argv[0] not available on ST/TOS */
+ 	fprintf(stderr,"Frankenstein Cross-Assembler %s V2.1 by Mark Zenier\n"
+ 	               "Atari ST version by M. Schwingen\n",argv[0]);
+ 
  	grv = cpumatch(argv[0]);
  
  	while( (grv = getopt(argc, argv, "dh:o:l:s:p:")) != EOF)
***************
*** 133,144 ****
  	else
  	{
  		fprintf(stderr, "%s: no input file\n", argv[0]);
  		exit(1);
  	}
  
  	if(listflag)
  	{
! 		if(strcmp(argv[optind], loutfn) == 0) 
  		{
  			fprintf(stderr, "%s: list file overwrites input %s\n",
  				argv[0], loutfn);
--- 172,184 ----
  	else
  	{
  		fprintf(stderr, "%s: no input file\n", argv[0]);
+ 		usage(argv[0]);
  		exit(1);
  	}
  
  	if(listflag)
  	{
! 		if(strcmp(argv[optind], loutfn) == 0)
  		{
  			fprintf(stderr, "%s: list file overwrites input %s\n",
  				argv[0], loutfn);
***************
*** 157,162 ****
--- 197,215 ----
  		loutf = stdout;
  	}
  
+ #ifdef DOSTMP
+ 	p = getenv("TMP");
+ 	if (p == 0)
+ 		p = getenv("TEMP");
+ 	if (p == 0)
+ 		interfn[0] = 0;
+ 	else
+ 	{
+ 		strcpy(interfn,p);
+ 		strcat(interfn,"\\");
+ 	}
+ 	strcat(interfn,"frtXXXXX.tmp");
+ #endif
  	mktemp(interfn);
  	if( (intermedf = fopen(interfn, "w")) == (FILE *) NULL)
  	{
diff +recursive -c e:\fas_orig/frasmdat.h ./frasmdat.h
*** e:\fas_orig/frasmdat.h	Tue Dec 11 13:59:00 1990
--- ./frasmdat.h	Wed Nov 18 17:10:58 1992
***************
*** 174,180 ****
--- 174,183 ----
  char * savestring(), *findgen();
  long	strtol();
  void	reservedsym();
+ 
+ #ifndef __STDC__
  char	*calloc(), *malloc();
+ #endif
  
  extern struct symel * endsymbol;
  extern char ignosyn[] ;
diff +recursive -c e:\fas_orig/fryylex.c ./fryylex.c
*** e:\fas_orig/fryylex.c	Tue Dec 11 13:59:22 1990
--- ./fryylex.c	Wed Nov 18 16:35:34 1992
***************
*** 33,38 ****
--- 33,39 ----
  
  #include <stdio.h>
  #include "frasmdat.h"
+ #include "proto.h"
  #include "fraytok.h"
  
  #ifndef DEBUG
***************
*** 119,125 ****
  #define	 CXC25_BSLASH	25
  #define  NUMCHARSETS	26
  
! static char chartrantab[128] = {
  /* 00 nul soh stx etx*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
  /* 04 eot enq ack bel*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
  /* 08 bs  ht  nl  vt */  CXC00_SKIP, CXC01_SPACE, CXC02_NL, CXC00_SKIP,
--- 120,126 ----
  #define	 CXC25_BSLASH	25
  #define  NUMCHARSETS	26
  
! static char chartrantab[256] = {
  /* 00 nul soh stx etx*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
  /* 04 eot enq ack bel*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
  /* 08 bs  ht  nl  vt */  CXC00_SKIP, CXC01_SPACE, CXC02_NL, CXC00_SKIP,
***************
*** 151,157 ****
  /* 70  p  q  r  s */  CXC03_LETTER, CXC21_OQ, CXC03_LETTER, CXC03_LETTER,
  /* 74  t  u  v  w */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
  /* 78  x  y  z  { */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC05_OTHER,
! /* 7c vb  }  ~  del*/  CXC05_OTHER, CXC05_OTHER, CXC03_LETTER, CXC00_SKIP } ;
  
  
  #if DEBUG
--- 152,190 ----
  /* 70  p  q  r  s */  CXC03_LETTER, CXC21_OQ, CXC03_LETTER, CXC03_LETTER,
  /* 74  t  u  v  w */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
  /* 78  x  y  z  { */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC05_OTHER,
! /* 7c vb  }  ~  del*/  CXC05_OTHER, CXC05_OTHER, CXC03_LETTER, CXC00_SKIP,
! /* 80 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 84 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 88 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 8c */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 90 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 94 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 98 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* 9c */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* a0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* a4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* a8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* ac */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* b0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* b4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* b8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* bc */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* c0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* c4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* c8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* cc */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* d0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* d4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* d8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* dc */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* e0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* e4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* e8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* ec */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* f0 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* f4 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* f8 */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
! /* fc */              CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER } ;
  
  
  #if DEBUG
***************
*** 637,643 ****
  
  		while( (nextchar = *frainptr++) != '\0' )
  		{
! 			charset = chartrantab[nextchar & 0x7f];
  			do {
  				thisact =  & characttab [scanstate][charset];
  
--- 670,676 ----
  
  		while( (nextchar = *frainptr++) != '\0' )
  		{
! 			charset = chartrantab[nextchar & 0xff];
  			do {
  				thisact =  & characttab [scanstate][charset];
  
Only in .: getopt.c
diff +recursive -c e:\fas_orig/makefile.st ./makefile.st
*** e:\fas_orig/makefile.st	Wed Nov 18 17:45:44 1992
--- ./makefile.st	Wed Nov 18 16:03:24 1992
***************
*** 0 ****
--- 1,109 ----
+ # HEADER:	;
+ # TITLE:	Frankenstein Cross Assemblers;
+ # VERSION: 	2.0;
+ # SYSTEM:	Atari ST/TOS;
+ # FILENAME:	Makefile ;
+ # DESCRIPTION: "Reconfigurable Cross-assembler producing Intel (TM)
+ #		Hex format object records.  ";
+ # KEYWORDS: 	cross-assemblers, 1805, 2650, 6301, 6502, 6805, 6809, 
+ #		6811, tms7000, 8048, 8051, 8096, z8, z80;
+ # WARNINGS:	"This software is in the public domain.  
+ #		Any prior copyright claims are relinquished.  
+ #	
+ #		This software is distributed with no warranty whatever.  
+ #		The author takes no responsibility for the consequences 
+ #		of its use.
+ #	
+ #		Yacc (or Bison) required to compile."  ;
+ # AUTHORS:	Mark Zenier;
+ # COMPILERS:	Pure C;
+ #
+ #	usage	
+ #		make somename TARGET=somename 
+ #		make newmachine       clean out machine dependent *.o
+ #		make clean	      clean out for release disk
+ #
+ #	Conditional Compilation Flags
+ #
+ #	DOSTMP		use the current directory for temporary intermediate
+ #			file
+ #	NOGETOPT	use the getopt.h file
+ #	USEINDEX	redefine the strchr() library function to use
+ #			the older equivalent name index()
+ #	NOSTRING	use internal definitions if the <string.h> include
+ #			file does not exist
+ #
+ 
+ CC = e:\pc\pcc.ttp
+ LD = e:\pc\plink.ttp
+ YACC = byacc
+ 
+ TARGET = as8051
+ PRINTSPOOL = lpr
+ 
+ # LEXERDEBUG = -DDEBUG=1
+ LEXERDEBUG =
+ 
+ CFLAGS = -W-rvl -W-sig -W-pia -D__STDC__ -Ie:\pc\include -DDOSTMP
+ LDFLAGS = -S=32768 e:\pc\lib\pcstart.o e:\pc\lib\PCSTDLIB.LIB e:\pc\lib\PCEXTLIB.LIB e:\pc\lib\PCTOSLIB.LIB
+ YACCLEXLIB =
+ MAINNEEDS =
+ MAINDEPENDS =
+ 
+ asm:	$(TARGET).ttp
+ 
+ $(TARGET).ttp:	frasmain.o frapsub.o l$(TARGET).o $(TARGET).o fraosub.o x$(TARGET).o getopt.o mktemp.o
+ 	$(LD) $(LDFLAGS) -O=$(TARGET).ttp frasmain.o frapsub.o \
+ 		fraosub.o l$(TARGET).o x$(TARGET).o $(TARGET).o $(YACCLEXLIB) \
+ 		getopt.o mktemp.o
+ 	rm -f fraytok.h
+ 
+ getopt.o:	getopt.c
+ 	$(CC) $(CFLAGS) getopt.c
+ 	
+ mktemp.o:	mktemp.c
+ 	$(CC) $(CFLAGS) mktemp.c
+ 	
+ x$(TARGET).o:	target.c
+ 	$(CC) $(CFLAGS) -Ox$(TARGET).o -DTARGET='"$(TARGET)"' target.c
+ 
+ l$(TARGET).o:	fryylex.c frasmdat.h $(TARGET).h
+ 	cp $(TARGET).h fraytok.h 
+ 	$(CC) $(CFLAGS) $(LEXERDEBUG) -O=l$(TARGET).o fryylex.c
+ 
+ frasmain.o : frasmain.c  frasmdat.h $(MAINDEPENDS)
+ 	$(CC) $(CFLAGS) $(MAINNEEDS) frasmain.c
+ 
+ $(TARGET).c $(TARGET).h : $(TARGET)/$(TARGET).y
+ 	$(YACC) -d $(TARGET)/$(TARGET).y
+ 	mv ytab.c $(TARGET).c
+ 	mv ytab.h $(TARGET).h
+ 	rm -f fraytok.h
+ 
+ $(TARGET).o : $(TARGET).c  frasmdat.h fragcon.h
+ 	$(CC) $(CFLAGS) $(TARGET).c
+ 
+ frapsub.o : frapsub.c fragcon.h frasmdat.h fraeuni.h fraebin.h
+ 	$(CC) $(CFLAGS) frapsub.c
+ 
+ fraosub.o : fraosub.c  frasmdat.h fragcon.h fraeuni.h fraebin.h
+ 	$(CC) $(CFLAGS) fraosub.c
+ 
+ clean:
+ 	rm -f *.o fraytok.h *.pdb
+ 	rm -f ytab.[ch]
+ 	rm -f as*.[cho]
+ 	rm -f as*.lst *.bak
+ 	
+ clobber:	clean
+ 	rm -f as*.ttp
+ 
+ newmachine :
+ 	rm -f fraytok.h
+ 	rm -f fryylex.o
+ 	rm -f $(TARGET).c $(TARGET).h $(TARGET).o
+ 
+ test:	asm
+ 	-$(TARGET).ttp -l $(TARGET).lst $(TARGET)\$(TARGET).tst
+ 	-diff -c $(TARGET)\$(TARGET).tut $(TARGET).lst
+ 
diff +recursive -c e:\fas_orig/mktemp.c ./mktemp.c
*** e:\fas_orig/mktemp.c	Wed Nov 18 17:00:56 1992
--- ./mktemp.c	Sat Dec 22 17:29:10 1990
***************
*** 0 ****
--- 1,26 ----
+ /*
+    mini MKTEMP for FAS (ST-port)
+    (C) 1990 M. Schwingen
+ */
+ 
+ #include <stdio.h>
+ 
+ void mktemp(char *str)
+ {
+ 	static int tmpcnt = 0;
+ 	char buf[10];
+ 	char *p1,*p2;
+ 	
+ 	sprintf(buf,"%08d",tmpcnt++);
+ 	p1 = buf;
+ 	while (*p1)
+ 		p1++;
+ 	p2 = str;
+ 	p1--;
+ 	while (*p2)
+ 	{
+ 		if (*p2 == 'X')
+ 			*p2 = *p1--;
+ 		p2++;
+ 	}
+ }
diff +recursive -c e:\fas_orig/proctype.txt ./proctype.txt
*** e:\fas_orig/proctype.txt	Wed Nov 18 17:01:38 1992
--- ./proctype.txt	Mon Dec 24 16:27:14 1990
***************
*** 0 ****
--- 1,14 ----
+ AS1805: RCA 1802, RCA 1804/1805/1806
+ AS2650: 2650
+ AS6301: 6301
+ AS6502: R65C00/21, 65(C)02/6504/6510 
+ AS6805: 6305, 68(HC/L)05
+ AS6809: 6809
+ AS6811: 6800/6802/6808, 6801/6803, 6811
+ AS7000: TMS7000
+ AS8048: 80(C)48/80(C)35, 80(C)49/80(C)39, 80(C)50/80(C)40, 8041,8042
+ AS8051: 80(C)51
+ AS8096: 8096, 80C196
+ ASZ8:   Z8/Z8600, UPC/Z8090
+ ASZ80:  8080, 8085, Z80, 64180
+ 
diff +recursive -c e:\fas_orig/proto.h ./proto.h
*** e:\fas_orig/proto.h	Wed Nov 18 17:02:32 1992
--- ./proto.h	Sun Dec 23 15:39:24 1990
***************
*** 0 ****
--- 1,81 ----
+ #ifdef __STDC__
+ # define	P(s) s
+ #else
+ # define P(s) ()
+ #endif
+ 
+ /* fraosub.c */
+ int outphase P((void ));
+ int outeval P((void ));
+ int flushlisthex P((void ));
+ int listhex P((void ));
+ int listouthex P((void ));
+ int outhexblock P((void ));
+ int flushhex P((void ));
+ int intelout P((int type , long addr , int count , char data []));
+ int frp2undef P((struct symel *symp ));
+ int frp2warn P((char *str ));
+ int frp2error P((char *str ));
+ int flushsourceline P((void ));
+ static long dgethex P((void));
+ 
+ /* frapsub.c */
+ char *savestring P((char *stx , int len ));
+ int clrexpr P((void ));
+ int exprnode P((int swact , int left , int op , int right , long value , struct symel *symbol ));
+ struct symel *allocsym P((void ));
+ int syhash P((char *str ));
+ struct symel *symbentry P((char *str , int toktyp ));
+ void reservedsym P((char *str , int tok , int value ));
+ int buildsymbolindex P((void ));
+ int setophash P((void ));
+ int findop P((char *str ));
+ int opcodehash P((char *str ));
+ char *findgen P((int op , int syntax , int crit ));
+ int genlocrec P((int seg , long loc ));
+ void goutch P((char ch ));
+ int gout2hex P((int inv ));
+ int goutxnum P((unsigned long num ));
+ int geninstr P((char *str ));
+ int chtcreate P((void ));
+ int chtcfind P((int *chtab , char **sourcepnt , int **tabpnt , int *numret ));
+ int chtran P((char **sourceptr ));
+ int genstring P((char *str ));
+ int pevalexpr P((int sub , int exn ));
+ int polout P((char ch ));
+ int polnumout P((unsigned long inv ));
+ int pepolcon P((int esub ));
+ static struct symel *getsymslot P((char *str));
+ 	
+ /* frasmain.c */
+ int main P((int argc , char *(argv [])));
+ int frafatal P((char *str ));
+ int frawarn P((char *str ));
+ int fraerror P((char *str ));
+ int fracherror P((char *str , char *start , char *beyond ));
+ int prtequvalue P((char *fstr , long lv ));
+ int printsymbols P((void ));
+ int filesymbols P((void ));
+ int usage P((char *name));
+ 
+ /* fryylex.c */
+ int frareadrec P((void ));
+ int yylex P((void ));
+ int yyerror P((char *str ));
+ static char *erryytextex P((int type));
+ 
+ /* getopt.c */
+ int getopt P((int nargc , char **nargv , char *ostr ));
+ 
+ /* mktemp.c */
+ void mktemp P((char *str ));
+ 
+ /* as6502.c */
+ int lexintercept P((void ));
+ int setreserved P((void ));
+ int cpumatch P((char *str ));
+ int strcontains P((char *s1 , char *sm ));
+ int yyparse P((void ));
+ 
+ #undef P
+ 
diff +recursive -c e:\fas_orig/target.c ./target.c
*** e:\fas_orig/target.c	Wed Nov 18 17:04:30 1992
--- ./target.c	Wed Nov 18 14:04:42 1992
***************
*** 0 ****
--- 1,4 ----
+ #include <stdio.h>
+ 
+ char *defaultname = TARGET;
+ 
*** e:\fas_orig\getopt.c	Wed Nov 18 18:29:36 1992
--- .\getopt.c	Wed Nov 18 16:53:08 1992
***************
*** 0 ****
--- 1,3 ----
+ #include <stdio.h>
+ #include <string.h>
+ #include "getopt.h"
