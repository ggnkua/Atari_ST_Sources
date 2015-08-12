/************************************************/
/*						*/
/*	Usual filename:  SID04.C		*/
/*	Remarks:  Third C module for SID68k	*/
/*	Author:  Timothy M. Benson		*/
/*	Control:  9 MAY 83   13:59  (TMB)	*/
/*						*/
/************************************************/

#include "lgcdef.h"
#include "cputype.h"
#include "siddef.h" 
#include "sidinc.h"
#include "stdio.h"
#include "bdosfunc.h"
#include "disas.h"

/********************************************************************
*	ISSPACE character
*
*	Return TRUE if the character is a whitespace character
********************************************************************/

isspace(ch)
int ch;
{
    return(ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r');
}

putchar(x)
register char x;
{
	trap(CONOUT, x);
	if (x == '\n') trap(CONOUT, '\r');
}
 
int stout(s)            /* write a string */
register char *s;
{
        register int nc;
 
        nc = 0;
        while ( *s ) { putchar( *s++ ); nc++; }
        return(nc);
}

/************************************************/
/* Starting at byte after **cpp get longest	*/
/* possible hex number from string or evaluate	*/
/* longest possible symbol.			*/
/* Fill in *np with value found.  Return # of	*/
/* digits if hex, 8 if symbol, or 0 if invalid. */
/* Leave **cpp pointing to next position after	*/
/* chars processed.				*/
/************************************************/

gethex(cpp,np)
char **cpp;
long *np;
{
/**temp** This function extensively modified for SID */
	extern struct lmhedr *caput;
	extern int omega;
	extern int nomo;
	union ambig BLOCK	/* Machine dependent */
	    long all32;
	    int last16[2];
	    char last8[4];
	UNBLOCK triad;
        register char *cp;
	U16 *d16;	/* For '@' values */
	U32 *d32;	/* For '!' values */
	char *deixis;	/* For '=' values */
        long n;
        register int nd;
	char px;	/* . = @ ! */
	register char qu;

	px = *(*cpp + 1);
	If px EQ '.' or px EQ '=' or px EQ '@' or px EQ '!' then BEGIN
	    cp = ++*cpp;	/* Locate prefix */
	    ++*cpp;	/* Skip prefix */
	    while((qu = *++cp) and qu NE ' ' and qu NE ',' and qu NE '+'
	    and qu NE '-' and qu NE '/' and qu NE '*')
		;	/* Find char after supposed name */
	    If nd = 8 * (omega GE 0
	    and (1 EQ indica((int)(cp - *cpp),*cpp
	    ,caput AT sump,'B',&n,&nomo))) then
	    If px NE '=' and px NE '.' and n AND 1L then nd = 0;
	    otherwise BLOCK
		triad.all32 = 0;
		switch (px) begin
		    case '.':
			triad.all32 = n;
			break;
		    case '=':
			deixis = n;
			triad.last8[3] = *deixis;
			break;
		    case '@':
			d16 = n;
			triad.last16[1] = *d16;
			break;
		    case '!':
			d32 = n;
			triad.all32 = *d32;
			break;
		end
		n = triad.all32;
	    UNBLOCK
	END
        otherwise for (n=0, nd=0, cp = *cpp;
              ishex(*++cp);
              nd++, n=(n<<4)+hexval(*cp));
 
        *cpp = --cp;
        *np  = n;
	return(nd);
}
 
int ishex ( c )
register char c;
{
        return ( ( ('0'<=c) && (c<='9') ) || ( ('A'<=c) && (c<='F') ) );
}
 
 
 
int hexval ( c )
register char c;
{
        if ( ('0'<=c) && (c<='9') ) return ( c-'0');
        else return ( 10 + c - 'A' );
}
 
 
 
char hexchar(n)
register char n;
{
         return ( n<10 ? '0'+n : 'A'+n-10 );
}
 



int puthex(n, i, zs)
register long n;
register int i;
register int zs;
{
	register char d;

	while ( i >= 4 )
	{
		i -= 4;
		d = hexchar( (char)((n>>i) & 0xf) );
		if ( d != '0' ) zs = 0;
		if ( (! zs) || (! i) ) putchar(d);
	}
}

 
int puthexl(n)  /* write a long integer in hex */
long n;
{
	puthex(n, 32, 0);
}
 
 
int puthexw(n)  /* write an integer in hex */
short int n;
{
	puthex((long)n, 16, 0);
}
 
 
 
puthexb(n)  /* write a byte in hex */
char n;
{
	puthex((long)n, 8, 0);
}

 
 
int putbyte(c)  /* write an ascii byte.  if not printable, write '.' */
register char c;
{
        char d[2];
 
        d[1] = 0;
        d[0] = ( ( (c < 0x20) || (c > 0x7E) ) ? '.' : c );
        stout(d);
}
 
 
        
bad()
{
         stout("?\n");
}
 
badram(a)
long a;
{
        stout("Bad or non-existent RAM at ");
        puthexl(a);
        putchar('\n');
}


nomore(cx)
char *cx;
{
	++cx;
	while (*cx)
	{
		if (!isspace(*cx)) return(0);
		else ++cx;
	}
	return(1);
}
 
 
getsep(cxp)
register char **cxp;
{
        register char *cx;
 
        cx = (*cxp) + 1;
        if ((*cx != ' ') && (*cx != ',')) return(0);
        while ( *cx == ' ' ) ++cx;
        if ( ! *cx ) return(0);
        if ( *cx != ',' ) {*cxp = --cx; return(1);}
        ++cx;
	while ( *cx == ' ' ) ++cx;
        *cxp = --cx;
        return(1);
}               


deblank(cxp)
register char **cxp;
{
	++*cxp;
	while ( isspace(**cxp) ) ++*cxp;
	--*cxp;
}
 


short int getform(cxp)
register char **cxp;
{
	register char *cx;
	register short int format;

	cx = *cxp;

	if ( *++cx == 'W' )	format = 2;
	else if ( *cx == 'L' )	format = 4;
	else { format = 1; cx--; }

	*cxp = cx;

	deblank(cxp);

	return(format);
}



int keyhit()
{
	if ( trap(CONSTAT, 0L) & 0xFFFFL ) {
		trap(CONIN, 0L);
		return(1);
	}
	else return(0);
}


showvals(vp)
register struct value *vp;
{
	register int i, j;
	register long * lp;

	switch ( vp->kind ) 
	{
	   case 0: stout("ERROR, no program or file loaded.");
		   break;

	   case 1: /* do program vals */
		   for ( i = 0; i < 2; ++i )
		   {
			lp = &(vp->textbase);
			lp += i;
			for (j = 0; j < 3; ++j)
			{
			   switch ( j )
			   {
				case 0: stout("text "); break;
				case 1: stout("data "); break;
				case 2: stout("bss ");  break;
			   }
			   switch ( i )
			   {
				case 0: stout(" base  "); break;
				case 1: stout(" length"); break;
			   }
			   stout(" = ");
			   puthexl(*lp);
			   lp += 2;
			   stout("   ");
			}
		   	putchar('\n');
		   }
		   stout("base page address = ");
		   puthexl(vp->bpa);
		   stout("       initial stack pointer = ");
		   puthexl(vp->initstk);
		   break; /* end of program values */

	   case 2: /* do file values */
		   stout("Start = ");
		   puthexl(vp->textbase);
		   stout("     End = ");
		   puthexl((vp->textbase)+(vp->textlen)-1L);
		   break;
	}

	putchar('\n');

} /* end of showvals */
 
/**/


/****************************************************************/
/*                                                              */
/*      Examine/Alter CPU Registers                             */
/*                                                              */
/****************************************************************/
 
 
examine(cx, statep)
char *cx;
struct cpustate *statep;
{
        if        (nomore(cx))
		{showstate(statep);
		 return;
		}
        else if (cmp("PC",cx))    pregl("PC", &(statep->pc));
        else if (cmp("USP",cx))   { if (pregl("USP",&(statep->usp)) &&
                                        ((statep->status & SUPER) == 0 ))
                                        statep->areg[7] = statep->usp;
             }
        else if (cmp("SSP",cx))   { if (pregl("SSP",&(statep->ssp)) &&
                                        (statep->status & SUPER)  )
                                        statep->areg[7] = statep->ssp;
             }
        else if (cmp("ST", cx))	  { pregw("ST",&(statep->status) );
		if ( statep->status & SUPER)	statep->areg[7] = statep->ssp;
		else				statep->areg[7] = statep->usp; 
	     }
#ifdef MC68010
	else if (cmp("VBR",cx))	   pregl("VBR", &(statep->vbr));
	else if (cmp("SFC",cx))   pregn("SFC", &(statep->sfc));
	else if (cmp("DFC",cx))   pregn("DFC", &(statep->dfc));
#endif
        else if (*++cx == 'D')    pdareg('D', cx, statep->dreg);
        else if   (*cx == 'A')    pdareg('A', cx, statep->areg);
	else bad();

	if ( statep->status & SUPER)	statep->ssp = statep->areg[7];
	else				statep->usp = statep->areg[7]; 
}
 
 
 
showstate(statep)
register struct cpustate *statep;
{
	long	SysStP;
/**temp** Next several lines added recently */
	extern int scope;
	extern struct lmhedr *caput;
/**temp** End of added stuff */	
        register short int status;

        stout("PC=");  puthexl(statep->pc);  putchar(' ');
        stout("USP="); puthexl(statep->usp); putchar(' ');
        stout("SSP="); puthexl(statep->ssp); putchar(' ');
        stout("ST=");  puthexw(status = statep->status);
        stout("=>");
        if (status & TRACE)  stout("TR ");
        if (status & SUPER)  stout("SUP ");
        stout("IM=");  putchar(((status & INTMSK)>>8)+'0');
        if (status & EXTEND) stout(" EXT");
        if (status & NEG)    stout(" NEG");
        if (status & ZERO)   stout(" ZER");
        if (status & OFLOW)  stout(" OFL");
        if (status & CARRY)  stout(" CRY");
        putchar('\n');
#ifdef MC68010
	stout("VBR="); puthexl(statep->vbr); putchar(' ');
	stout("SFC="); puthex(statep->sfc, 4, 0); putchar(' ');
	stout("DFC="); puthex(statep->dfc, 4, 0); putchar('\n');
#endif
        preglrow('D', statep->dreg);     /* D registers */
        preglrow('A', statep->areg);     /* A registers */
        dot = statep -> pc;
	SysStP = trap(SUPVMOD, 0L);	/* Go to supervisor mode */
	spell(statep AT pc,caput AT sump,scope,'m','h');
					/* Label, if any */
        pinstr();                       /* disassembled instruction */
	trap(SUPVMOD, SysStP);		/* Return to User mode */
        putchar('\n');
}
 
pdareg(da, cx, rp)      /* print data or address register contents */
char  da;
register char *cx;
long *rp;
{
 
        char str[3];
 
        if ( ('0' <= *++cx) && (*cx <= '7') && nomore(cx) ) {
                str[0] = da;
                str[1] = *cx;
                str[2] = 0;
                pregl(str, rp + *cx - '0');
        }
	else bad();
}

pregl(rname, regp)       /* print register contents as long */
char *rname;
long *regp;
{
	return(preg(rname, regp, 4));
}

pregn(rname, regp)
char *rname;
long *regp;
{
	return(preg(rname, regp, 0));
}


pregw(rname, regp)       /* print register contents as word */
char *rname;
long *regp;
{
	return( preg(rname, regp, 2) );
}
 
preg(rname, regp, size)       /* print register contents */
register char *rname;
register long *regp;
register int   size;
{
        char buf[BUFLEN];
        register short int nc;
        long int newval;
        char *bp;
        register int modify; 
 
        modify = 0;
        stout(rname);
        putchar('=');
 	switch(size)
	{
		case 0 : puthex(regp->meml, 4, 0);
			 break;
		case 1 : puthexb(regp->memb);
			 break;
		case 2 : puthexw(regp->memw);
			 break;
		case 4 : puthexl(regp->meml);
			 break;
	}
        putchar(' ');
        *buf = BUFLEN-2;
        trap(READBUF, buf);
	putchar('\n');
        if ((nc=buf[1])>0) {
                buf[nc+2]=0;
                bp = buf + 1;
                while (*++bp) *bp = toupper(*bp);
                bp = buf + 1;
                if (gethex(&bp, &newval) && nomore(bp)) {
                   switch(size)
		   {
			case 0 : regp->meml = newval & 0xffL;
				 break;
			case 1 : regp->memb = (char)(newval & 0xffL);
				 break;
			case 2 : regp->memw = (int)(newval & 0xffffL);
				 break;
			case 4 : regp->meml = newval;
				 break;
		   }
                   modify = 1;
                }
                else if ( ! nomore(buf+1) ) bad();
        }
        return(modify);
}
 
preglrow(ch, rowp)
char ch;
long *rowp;
{
        register int n;
        
        putchar(ch);
        putchar(' ');
        for (n=0; n<8; n++) {
                putchar(' ');
                puthexl(*rowp++);
                if (n==3) putchar(' ');
        }
        putchar('\n');
}
 
tryflags(cx, statep)
register char *cx;
register struct cpustate *statep;
{
	bad();
}
 
cmp(str, ctl)
register char *str;
register char *ctl;
{
        while (*str && (*str++ == *++ctl)) ;
        if ( ( ! *str) && nomore(ctl) ) return(1);
        else return(0);
}
