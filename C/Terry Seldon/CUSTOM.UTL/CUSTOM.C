#include <d:stdio.h>
/*
 * CUSTOM [input file] [output file]
 *
 * Written by Terry Seldon ( 25/1/88 )
 * Public Domain  -  This may be copied freely
 *
 * This utility is written in Public Domain C
 * It is a file Inspection/Editing utility designed specifically for
 * editing Resource and Program files (i.e. Customising Programs).
 * It's main use being as an editor for text in menus and alerts.
 * Thus enabling foreign programs to be ported to English versions.
 *
 * When using the utility as an editor GREAT CARE must be exercised.
 * Always ensure you have a copy of the original file incase things
 * go wrong ! ( preferably on a seperate disc ).
 *
 *
 * To make a working version (from within command.tos):
 *
 * Boot as normal and remove GEM development files from d: then
 * insert the disk with custom.c and exlib.c
 * d:
 * copy a:exlib.c d:
 * cc exlib.c
 * ren yc.out exlib.a
 * copy a:custom.c d:
 * cc custom.c
 * as d:ttp.s yc.out -l d:lib.a d:exlib.a
 * ren ya.out custom.ttp
 * rm yc.out
 * custom <infile> <outfile>
 *
 *
 */ 
#define SIZE 1600
int block;		/* block number */
unsigned endp,		/* position in block after last character */
	 csr,		/* cursor positon in block */
	 flen;		/* find string length */
unsigned char
	 buf[SIZE],	/* buffer (one block) */
         p[80],		/* parameter buffer for commands */
	 fstring[31];	/* Current find string */
FILE *infile, *outfile;	/* File pointers */



change()
/* This Shows the line (as characters) from the present position.
 * On The next line down it asks for input. Any characters typed
 * replace the existing ones except the '~' character which does
 * not get copied (thus allowing letters to be skipped)
 */
{
   int x;
   look();		/* SHOW LINE */
   ask("",p,endp-csr);	/* ASK FOR INPUT (NO PROMPT) */
   /* COPY CHARACTERS RETURNED IN P[] TO BUF[] */
   for (x=csr; csr<endp & p[x-csr]!=0; ++x)
	 if ( p[x-csr] != '~' ) buf[x] = p[x-csr];
   look();		/* SHOW EFFECT  OF CHANGES */
   /* POSITION CURSOR AT CHARACTER AFTER INPUT */
   if (x<endp) csr=x; else csr=endp-1;
}



decimal()
/* This displays a character at a time and asks for a new decimal
 * value for the position. Input is stopped by pressing return.
 */
{
   int x;
   putchar('\n');	/* START ON A NEW LINE */
   do			/* UNTIL NO INPUT OR END OF BLOCK  */
	{
	 display(csr);		/* SHOW DETAILS OF POSITION */
	 ask("	Dec =",p,3);	/* ASK FOR DECIMAL INPUT (3 CHARS) */
	 if (isdigit(p[0]))	/* IF START IS DIGIT */
	   {
		x=atoi(p);	/* GET NUMBER */
		if (x<256)	/* IF IN RANGE */
	  	   {
			buf[csr]=x;	/* CHANGE VALUE */
			display(csr);	/* SHOW EFFECT */
			++csr;		/* POINT TO NEXT */
			putchar('\n');
	  	   }
		else		/* OTHERWISE REPORT ERROR */
			printf(" Too big!\n");
	   }
	else	/* IF INVALID INPUT REPORT */
		if (p[0]!=0) printf(" Not Numeric!\n");
	}
   while (p[0]!=0 & csr<endp);
   if (csr==endp) csr=endp-1;	/* REPOSITION CURSOR IF GONE OFF END */
}



find()
/* This finds asks for a word to find. If a word is entered it is looked
 * for. If return is pressed the last find is repeated. The search starts
 * from the cursor and continues to the end of block, it then starts
 * again from the start of the block to the cursor position. If found
 * change mode is entered.
 */
{
   char c;			/* USED IN COMPARISONS */
   int x,			/* CONSIDERING POSITION - */
       y,			/* COMPARISON BEING MADE AT - */
       found;			/* FOUND FLAG (1=FOUND) */
   found=0;
   printf("\nFind [%s] >",fstring);	/* PROMPT (WITH OLD FIND STING) */
   ask("",p,30);		/* ASK FOR NEW VALUE (PROMPT ALREADY DONE) */
   c=p[0];
   if (c>0)			/* IF WORD ENTERED (I.E. NOT 0 LENGTH STRING) */
	for (flen=0; c!=0; ++flen)	/* COPY WORD TO FIND STRING */
	    { c=p[flen]; fstring[flen]=c; }
   for (x=csr+1; x<endp & !found; ++x)	/* CONSIDER FROM CURSOR TO END BLOCK */
     {
	for (y=x; y<endp & fstring[y-x]==buf[y]; ++y);	/* COMPARE */
	if (y-x+1==flen) found=1;	/* IF MATCHED ALL, THEN FOUND IT */
     }
   if ( found ) { csr=x-1; change(); return; }	/* CHANGE AND RETURN */
   for (x=0; x<csr & !found; ++x)	/* CONSIDER FROM START TO CURSOR */
     {
	for (y=x; y<endp & fstring[y-x]==buf[y]; ++y);	/* COMPARE */
	if (y-x+1==flen) found=1;	/* IF MATCHED ALL, THEN FOUND IT */
     }
   if ( found ) { csr=x-1; change(); return; }	/* CHANGE AND RETURN */
   printf("\nCan't find it !");		/* BETTER LUCK NEXT TIME */
}



dispch(c)
/* This displays the character if not a control character
 * otherwise it displays a small cross. Note I had to put
 * the '| c<0' in, because despite declaring it as unsigned
 * PD-C still treats it as signed. (Elsewhere I have got
 * round the same problem by assigning the char to an unsigned
 * integer - which then has the correct value).
 */
char c;
{
   if ( c>31 | c<0 )		/* IF NOT A CONTROL CHAR */
	   putchar(c);		/* DISPLAY CHAR */
   else			/* OTHERWISE DISPLAY SMALL CROSS */
	   putchar(187);
}



look()
/* This displays 79 characters from present position, Non printable
 * characters are displayed as a small cross.
 */
{
   int x,		/* POSITION IN BLOCK (BUF) */
       n;		/* COUNT OF CHARACTERS OUTPUT */
   n=0;
   printf("\n ");	/* START ON NEWLINE,ONE CHAR IN (SO MATCH CHANGE) */
   for (x=csr; x<endp & n<79; ++x)	/* FOR 79 CHARACTERS (OR END BUFFER) */
	{
		dispch(buf[x]);		/* DISPLAY CHARACTER */
		++n;
	 }
   if (n<79) putchar(174);	/* IF LESS THAN FULL LINE OUTPUT, MARK END */
   putchar('\n');
}

show()
/* This shows the whole block on screen. The cursor position is marked with
 * an unusual chacter (not sure of it's name). Also a display of the cursor
 * positions details are displayed.
 */
{
   int x,				/* BUFFER POSITION */
       n;				/* COUNT OF CHARS OUTPUT TO LINE */
   printf("\nBlock %d\n",block);	/* SHOW BLOCK NUMBER */
   n=0;
   for (x=0; x<endp; ++x)		/* FOR EACH CHAR IN BLOCK */
	{
	 if (x==csr)			/* IF CURSOR POSITION MARK IT */
		 putchar(189);
	 else				/* OTHERWISE DISPLAY CHAR */
		dispch(buf[x]);
	 ++n;
	 if (n==80) { n=0; putchar('\n'); }	/* NEW LINE AT END SCREEN */
	}
   putchar('\n');
   display(csr);		/* DISPLAY CURSOR POSITION DETAILS */
}



display(x)
/* This displays details about the character at position x.
 */
int x;
{
   unsigned int c;		/* THE CHARACTER - Note this has to be int
				 * with PD-C otherwise it insists on printing
				 * negative values when over 127 even when
				 * declared as: unsigned char
				 */
   printf(" %d: ",csr);		/* SHOW CURSOR POSITION */
   c=buf[x];			/* GET CHARACTER */
   putchar('\'');
   dispch(c);			/* SHOW CHARACTER */
   putchar('\'');
   printf(" dec=%d hex=%x",c,c);	/* SHOW DECIMAL AND HEX VALUES */
}


main(argc,argv)
/*
 * Custom editor/inspection tool- main control loop
 */
int argc;	/* ARGUMENT COUNT */
char *argv[];	/* ARGUMENT VALUES */
{
 int newch,		/* NEW CHARACTER (LAST READ FROM FILE) */
     x;			/* GENERAL WORK VARIABLE */
 unsigned fndblock;	/* BLOCK TO FIND BEFORE RE-ENTERING COMMAND LOOP */
 char com;		/* SINGLE CHARACTER COMMAND */
 printf("%cw",27);	/* WRAP OFF */
 if (argc>1)		/* IF ONE PARAMETER OR MORE */
	{
	 printf("Infile: %s   ",argv[1]);	/* DISPLAY INFILE NAME */
	 strcpy(p,argv[1]);			/* COPY TO PARAMETER STRING */
	}
 else			/* OTHERWISE ASK FOR INFILE NAME */
        ask("Which File >",p,66);
 infile = fopen(p,"r");	/* TRY TO OPEN INPUT FILE */
 if (!infile)		/* IF OPEN FAILED */
	{
	 printf("- Can't open !\n");	/* ABORT */
	 exit();
	}
 if (argc>2)		/* IF SECOND PARAMETER SUPLIED */
	{
	 strcpy(p,argv[2]);		/* COPY TO PARAMETER STRING */
	 outfile = fopen(p,"w");	/* TRY TO OPEN FILE */
	}
 else			/* NO OUTPUT FILE */
	outfile=NULL;
 if (outfile)		/* IF OUTFILE OPENED OK */
	 printf("- Outfile: %s",p);	/* DISPLAY OUTFILE NAME */
 else			/* OTHERWISE INFORM OF NO OUTPUT FILE */
	 printf("- Inspection Only");
 fndblock=1;		/* ENTER COMMAND LOOP TO START WITH */
 block=1;		/* SET BLOCK NUMBER */
 fstring[0]=0; flen=1;	/* INITIALISE FIND STRING */
 newch=0; endp=0;	/* SET NEW CHAR AND END POSITION */
 while ( newch != EOF )	/* TO END OF FILE */
  {
   while ( newch !=  EOF & endp < SIZE )	/* TO END OF BLOCK (OR FILE) */
	{
	 newch = getc(infile);		/* GET NEW CHARACTER */
	 buf[endp]=newch;		/* PUT CHAR IN BUFFER */
	 ++endp;			/* NEW END POSITION */
	}
   if (newch==EOF) --endp;	/* EOF IS NOT PART OF FILE SO REMOVE */
   csr=0;			/* POINT TO FIRST CHARACTER IN BLOCK (BUF) */
   if (block>=fndblock)	/* IF BLOCK FOUND ENTER COMMAND LOOP */
   {
    show();		/* SHOW BLOCK */
    do			/* UNTIL COMMAND=N (NEXT BLOCK) */
	{
	 printf("\n > ");	/* PROMPT */
	 /*
	  * NOTE IN PD-C GETCHAR WORKS IMMEDIATELY I.E. AS SOON AS A KEY IS
	  * PRESSED THE CHARACTER (FUNCTION) IS DISPLAYED (OBEYED) AND THE
	  * CHARACTER RETURNED. IF THIS IS BEING USED WITH A DIFFERENT C
	  * COMPILER THIS COMMAND WILL PROBABLY HAVE TO BE CHANGED TO A
	  * READ TRAP (OR FUNCTIONALY EQUIVALENT LIBRARY ROUTINE)
	  */
	 com=getchar();	/* GET COMMAND LETTER */
	 switch (com)	/* PROCESS COMMAND */
	  {
	   case 8:	if (csr>0) --csr;	/* BACKSPACE */
			putchar('\n');		/* DISPLAY NEW POSITION */
			display(csr);
			break;
	   case '\n':	if (csr<endp-1) ++csr;	/* RETURN (FORWARD) */
			display(csr);		/* DISPLAY -NO NEED FOR
						 * RETURN AS PERFORMED BY
						 * GETCHAR WHEN KEY READ
						 */
			break;
	   case 'n':
	   case 'N':	com='n';		/* NEXT BUFFER */
			break;
	   case 'b':
	   case 'B':	ask("\nBlock >",p,4);	/* FIND BLOCK */
			fndblock=atoi(p);
			com='n';
			break;
	   case 'c':
	   case 'C':	change(); break;	/* CHARACTER INPUT */
	   case 'd':
	   case 'D':	decimal(); break;	/* DECIMAL INPUT */
	   case 'f':
	   case 'F':	find(); break;		/* FIND AND CHANGE */
	   case 'l':
	   case 'L':	look(); display(csr); break;	/* LOOK AT CSR POS */
	   case 'p':
	   case 'P':	ask("\nOffset >",p,4);	/* POSITION CURSOR */
			csr=atoi(p);
			if (csr>=endp) csr=endp-1;	/* ENSURE INSIDE BUF */
			look(); display(csr);	/* LOOK AT NEW CSR POSITION */
			break;
	   case 'q':
	   case 'Q':	printf("\nQuit (y/n) > ");	/* QUIT */
			p[0]=getchar();			/* CONFIRM */
			if (p[0]=='y' | p[0]=='Y') exit(); /* QUIT IF OK */
			break;
	   case 's':
	   case 'S':	fndblock=9999;			/* SAVE -SET FIND */
			com='n';			/* BLOCK NUM HIGH */
			break;
	   case ' ':	show();				/* SHOW BLOCK */
			break;
	   default:	/* UNKNOWN COMMAND SO GIVE LIST OF VALID COMMANDS */
			printf("\n B	- Go to Block <n>	");
			printf("<SPACE>	- Show Block");
			printf("\n <BS>	- Back			");
			printf("<RET>	- Forward");
			printf("\n P	- Position Cursor	");
			printf("L	- Look at Position");
			printf("\n C	- Character input	");
			printf("D	- Decimal input");
			printf("\n F	- Find			");
			printf("S	- SAVE and Exit");
			printf("\n Q	- QUIT\n");
			display(csr);
			break;
	  }
	}
    while (com != 'n');		/* REPEAT UNTIL ASKED FOR NEXT BUFFER */
   }
   if (outfile!=0)		/* WRITE BLOCK IF OUTFILE EXISTS */
	for ( x=0; x<endp; ++x ) putc( buf[x],outfile );
   endp=0;			/* RESET END POSITION */
   ++block;			/* NEXT BLOCK */
  }
 fclose( infile ); fclose( outfile );	/* TIDY UP */
 printf("\n*~|~*\n");			/* GO HOME */
}
