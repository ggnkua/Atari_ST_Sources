/*	con.c
** 
** GEMDOS console system
** 
** Originally written by JSL as noted below.
** 
** MODIFICATION HISTORY
** 
** 	10 Mar 85	SCC	Added xauxout(), xprtout(), xauxin().
** 				(getch() can be used to perform function 7.)
** 				Updated rawconio() to spec (no 0xFE).
** 				Register optimization.
** 
** 	11 Mar 85	SCC	Further register optimization.
** 				Added xconostat(), xprtostat(), xauxistat(), &
** 				xauxostat().
** 	12 Mar 85	SCC	Fixed xauxin().
** 	14 Mar 85	SCC	Extended path from BIOS character input
** 				through to returning the character to the
** 				user to be long.
** 				OOPS!  Repaired a '=' to a '==' in rawconio().
** 	19 Mar 85	SCC	Modified tests in conbrk() to just check low
** 				byte of character (ignoring scan code info).
** 	21 Mar 85	SCC	Modified conin()'s echo of long input
** 				character to int.
** 				Added definition of 'h' to conout parameters.
** 	25 Mar 85	SCC	Changed constat return to -1 (to spec).
** 				Modified xauxistat() to use constat() rather
** 				than bconstat() directly.
** 	 1 Apr 85	SCC	Added x7in().  getch() cannot be used directly
** 				for function 0x07.
** 	10 Apr 85	EWF	Installed circular buffer for typeahead.
** 	11 Apr 85	EWF	Modified ^R handling in cgets().
** 	12 Apr 85	EWF	Installed 'ring bell' on typeahead full.
** 			SCC	Installed EWF's changes of 10, 11 & 12 Apr 85.
** 	26 Apr 85	SCC	Modified ^X & ^C handling to flush BIOS buffer
** 				as well as BDOS buffer.
** 	29 Apr 85	SCC	Modified buffer flushing to flush just BDOS
** 				buffer, but to re-insert ^X into buffer.
** 
** 	11 Aug 85	SCC	Modified references that convert p_uft[] entry
** 				to BIOS handle to use HXFORM() macro.
** 				Added 'extern int bios_dev[]' for HXFORM().
** 
** 	16 Aug 85	SCC	Modified xtabout().  The character parameter
** 				was omitted from the the call to tabout()
** 				inadvertently in the course of the previous
** 				changes.
** 
** 				Modified xconin().  It was not checking for
** 				possible break.
** 
** 				Modified x8in().  It was checking for break
** 				after getting a character, rather than before.
** 
** 	18 Aug 85	SCC	Modified constat() to return input status
** 				for all new character devices.
** 
** 				Modified all references of p_uft[3] (for PRN:)
** 				to p_uft[4], because of insertion of stderr.
** 
** 				Modified all references of p_uft[2] (for AUX:)
** 				to p_uft[3], because of insertion of stderr.
** 
**	15 Oct 85	KTB	M01.01.01: code to accomodate split of fs.h
**				into fs.h and bdos.h
**
**	21 Oct 85	KTB	M01.01.02: included portab.h
** 	
** NAMES
** 
** 	JSL	Jason S. Loveman
** 	SCC	Steve C. Cavender
** 	EWF	Eric W. Fleischman
**	KTB	Karl T. Braun (kral)
*/

/* console system for GEMDOS 3/6/85 JSL */

#include	"gportab.h"			/*  M01.01.02		*/
#include 	"fs.h"
#include	"bios.h"			/*  M01.01.01		*/

#ifdef	OLDCODE
/* *************************** typeahead buffer ************************* */
/*						*/	/* EWF  12 Apr 85 */
/* The following data structures are used for the typeahead buffer:	  */
/*									  */
long glbkbchar[3][KBBUFSZ];		/* The actual typeahead buffer	  */
					/* The 3 elements are prn,aux,con */
char kbchar[3];				/* size of typeahead buffer for   */
					/* each element			  */
long *insptr[3];			/* insertion ptr for each buffer  */
long *remptr[3];			/* removal ptr for each buffer	  */
/* ********************************************************************** */
#else
/* *************************** typeahead buffer ************************* */
/* The following data structures are used for the typeahead buffer:	  */
/*									  */
long glbkbchar[3][KBBUFSZ];		/* The actual typeahead buffer	  */
					/* The 3 elements are prn,aux,con */
int	add[3] ;			/*  index of add position	  */
int	remove[3] ;			/*  index of remove position	  */
/* ********************************************************************** */
#endif

int glbcolumn[3];

extern int bios_dev[];

extern PD *run;

extern long trap13();

#define UBWORD(x) (((int) x) & 0x00ff)

#define   ctrlc  0x03
#define   ctrle  0x05
#define   ctrlq  0x11
#define   ctrlr  0x12
#define   ctrls  0x13
#define   ctrlu  0x15
#define   ctrlx  0x18

#define   cr      0x0d
#define   lf      0x0a
#define   tab     0x09
#define   rub     0x7f
#define   bs      0x08
#define   space   0x20

#define warmboot xterm(-32)

/*****************************************************************************
**
** constat -
**
******************************************************************************
*/

long
constat(h)
int h;
{
	if (h > BFHCON)
		return(0);

	return( add[h] > remove[h] ? -1L : bconstat(h) );
}

/*****************************************************************************
**
** xconstat - 
**	Function 0x0B - Console input status
**
**	Last modified	SCC	11 Aug 85
**
******************************************************************************
*/

long
xconstat()
{
	return(constat(HXFORM(run->p_uft[0])));
}

/*****************************************************************************
**
** xconostat -
**	Function 0x10 - console output status
**
**	Last Modified	SCC	11 Aug 85
******************************************************************************
*/

long
xconostat()
{
	return(bconostat(HXFORM(run->p_uft[1])));
}

/*****************************************************************************
**
** xprtostat -
**	Function 0x11 - Printer output status
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
xprtostat()
{
	return(bconostat(HXFORM(run->p_uft[4])));
}

/*****************************************************************************
**
** xauxistat -
**	Function 0x12 - Auxillary input status
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
xauxistat()
{
	return(constat(HXFORM(run->p_uft[3])));
}

/*****************************************************************************
**
** xauxostat -
**	Function 0x13 - Auxillary output status
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
xauxostat()
{
	return(bconostat(HXFORM(run->p_uft[3])));
}


/********************/
/* check for ctrl/s */
/* used internally  */
/********************/
conbrk(h)
int h;
{
    register long ch;
    register int stop, c;

    stop = 0;
    if ( bconstat(h) )
	do
	{
		c = (ch = bconin(h)) & 0xFF;
		if ( c == ctrlc )
		{
			buflush(h);	/* flush BDOS & BIOS buffers */
			return(warmboot);
		}

		if ( c == ctrls )
			stop = 1;
		else if ( c == ctrlq )
			stop = 0;
		else if ( c == ctrlx )
		{
			buflush(h);
			glbkbchar[h][add[h]++ & KBBUFMASK] = ch;
		}
		else
		{
			if ( add[h] < remove[h] + KBBUFSZ )
			{
				glbkbchar[h][add[h]++ & KBBUFMASK] = ch;
			}
			else
			{
				bconout(h, 7);
			}
		}
	} while (stop);
}

buflush(h)
int h;
{
	/* flush BDOS type-ahead buffer */

	add[h] = remove[h] = 0;
}

/******************/
/* console output */
/* used internally*/
/******************/

conout(h,ch)
int h, ch;
{
    conbrk(h);			/* check for control-s break */
    bconout(h,ch);		/* output character to console */
    if (ch >= ' ') glbcolumn[h]++;	/* keep track of screen column */
    else if (ch == cr) glbcolumn[h] = 0;
    else if (ch == bs) glbcolumn[h]--;
}

/*****************************************************************************
**
** xtabout -
**	Function 0x02 - console output with tab expansion
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

xtabout(ch)
int ch;
{
	tabout(HXFORM(run->p_uft[1]),ch);
}

/*****************************************************************************
**
** tabout -
**
******************************************************************************
*/

tabout(h,ch)
int h;
int ch;		/* character to output to console	*/
{
    if (ch == tab) do
	conout(h,' ');
    while (glbcolumn[h] & 7);
    else conout(h,ch);
}

/*******************************/
/* console output with tab and */
/* control character expansion */
/*******************************/

cookdout(h,ch)
int h;
int ch;		/* character to output to console	*/
{
    if (ch == tab) tabout(h,ch); /* if tab, expand it	*/
    else
    {
	if ( ch < ' ' )
	{
            conout( h,'^' );
	    ch |= 0x40;
	}
    conout(h,ch);			/* output the character */
    }
}

/*****************************************************************************
**
** xauxout -
**	Function 0x04 - auxillary output
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long	xauxout(ch)
	int ch;
{
	return(  bconout(HXFORM(run->p_uft[3]),ch)  );
}

/*****************************************************************************
**
** xprtout -
**	Function 0x05 - printer output
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long	xprtout(ch)
	int ch;
{
	return(  bconout(HXFORM(run->p_uft[4]),ch)  ) ;
}


long
getch(h)
int h;
{
	long temp;

	if ( add[h] > remove[h] )
	{
		temp = glbkbchar[h][remove[h]++ & KBBUFMASK];
		if ( add[h] == remove[h] )
		{
			buflush(h);
		}
		return(temp);
	}

	return(bconin(h));
}

/*****************************************************************************
**
** x7in -
**	Function 0x07 - Direct console input without echo
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
x7in()
{
	return(getch(HXFORM(run->p_uft[0])));
}


long
conin(h)		/* BDOS console input function */
int h;
{
    long ch;

    conout( h,(int)(ch = getch(h)) );
    return(ch);
}

/*****************************************************************************
**
** xconin -
**	Function 0x01 - console input
**
**	Last modified	SCC	16 Aug 85
******************************************************************************
*/

long
xconin()
{
	int h;

	h = HXFORM( run->p_uft[0] );
	conbrk( h );
	return( conin( h ) );
}

/*****************************************************************************
**
** x8in -
**	Function 0x08 - Console input without echo
**
**	Last modified	SCC	24 Sep 85
******************************************************************************
*/

long
x8in()
{
	register int h;
	register long ch;

	h = HXFORM(run->p_uft[0]);
	conbrk(h);
	ch = getch(h);
	if ((ch & 0xFF) == ctrlc)
		warmboot;
	else
		return(ch);
}

/*****************************************************************************
**
** xauxin -
**	Function 0x03 - Auxillary input
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
xauxin()
{
	return(bconin(HXFORM(run->p_uft[3])));
}

/*****************************************************************************
**
** rawconio -
**	Function 0x06 - Raw console I/O
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

long
rawconio(parm)
int parm;
{
	int i;

	if (parm == 0xFF)
	{
		i = HXFORM(run->p_uft[0]);
		return(constat(i) ? getch(i) : 0L);
	}
	bconout(HXFORM(run->p_uft[1]), parm);
}

/*****************************************************************************
**
** xprt_line -
**	Function 0x09 - Print line up to nul with tab expansion
**
**	Last modified	SCC	11 Aug 85
******************************************************************************
*/

xprt_line(p)
char *p;
{
	prt_line(HXFORM(run->p_uft[1]),p);
}

prt_line(h,p)
int h;
char *p;
{
    while( *p ) tabout( h, *p++ );
}


/**********************************************/
/* read line with editing and bounds checking */
/**********************************************/

/* Two subroutines first */

newline(h,startcol)
int startcol,h;
{
    conout(h,cr);			/* go to new line */
    conout(h,lf);
    while(startcol)
    {
	conout(h,' ');
	startcol -= 1;		/* start output at starting column */
    }
}


backsp(h,cbuf,retlen, col) /* backspace one character position */
int h;
int retlen;
char *cbuf;
int col;			/* starting console column	*/
{
    register char	ch;		/* current character		*/
    register int	i;
    register char	*p;		/* character pointer		*/

    if (retlen) --retlen;
				/* if buffer non-empty, decrease it by 1 */
    i = retlen;
    p = cbuf;
    while (i--)			/* calculate column position 	*/
    {				/*  across entire char buffer	*/
	ch = *p++;		/* get next char		*/
	if ( ch == tab )
	{
	    col += 8;
	    col &= ~7;		/* for tab, go to multiple of 8 */
	}
	else if ( ch < ' ' ) col += 2;
				/* control chars put out 2 printable chars */
	else col += 1;
    }
    while (glbcolumn[h] > col)
    {
	conout(h,bs);		/* backspace until we get to proper column */
	conout(h,' ');
	conout(h,bs);
    }
    return(retlen);
}

/*****************************************************************************
**
** readline -
**	Function 0x0A - Read console string into buffer
******************************************************************************
*/

readline(p)
char *p; /* max length, return length, buffer space */
{
	p[1] = cgets(HXFORM(run->p_uft[0]),(((int) p[0]) & 0xFF),&p[2]);
}

cgets(h,maxlen,buf)
int h;	/* h is special handle denoting device number */
int maxlen;
char *buf;
{
	char ch;
	int i,stcol,retlen;

	stcol = glbcolumn[h];		/* set up starting column */
	for (retlen = 0; retlen < maxlen; )
	{
		switch(ch = getch(h))
		{
			case cr:
			case lf: conout(h,cr); goto getout;
			case bs:
			case rub:
				retlen = backsp(h,buf,retlen,stcol);
				break;
			case ctrlc: warmboot;
			case ctrlx:
				do retlen = backsp(h,buf,retlen,stcol);
				while (retlen);
				break;
			case ctrlu:
				conout(h,'#'); 
				newline(h,stcol);
				retlen = 0;
				break;
			case ctrlr:
				conout(h,'#');
				newline(h,stcol);
				for (i=0; i < retlen; i++)
					cookdout(h,buf[i]);
				break;
			default:
				cookdout(h,buf[retlen++] = ch);
		}
	}
getout:	return(retlen);
}
