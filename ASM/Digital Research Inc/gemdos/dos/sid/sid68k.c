/********************************************************/
/*							*/
/*	Usual filename:  SID68K.C			*/
/*	Remarks:  Main C module for SID68K		*/
/*	Author:  Timothy M. Benson			*/
/*	Control:  19 MAY 83  18:01  (TMB)		*/
/*   Revision History:					*/
/*		07 MAR 85 RDM - Update for GEMDOS	*/
/*							*/
/********************************************************/


#include "lgcdef.h"
#include "cputype.h"
#include "siddef.h"
#include "sidinc.h"
#include "stdio.h"
#include "bdosfunc.h"
#include "disas.h"

typedef long (*PFL)();

struct lmhedr *caput = NULL;	/* Symbol table--known globally */
extern long trap();

long	HMSYMS;

long inhalt;	/* Possible symbol value discovered during dissasembly */
int nomo;	/* Index to last symbol found by name */
int omega;	/* Index to last symbol in symbol table:*/
		/* 	Negative value => no symbols	*/
char ref;	/* Symbols for disassembly:		*/
		/*	'\0' => none			*/
		/*	'm' => text, data, or bss	*/
/**temp** Setting of 'a' not currently in use */
		/*	'a' => other			*/
int scope;	/* If zero, find all; otherwise find first */
int minus;	/* 1 => "-" in effect; 0 => "-" not in effect	*/
U16 pkawnt[HMPPTS];	/* Pass counts (0 => not in use)	*/
U16 *plocus[HMPPTS];	/* Values of pass points	*/
U16 ancien[HMPPTS];	/* Previous contents at pass point	*/

struct cpustate state;			/* state of user program regs */


main(OrigSSP, bpptr)
long	OrigSSP;
struct basepage * bpptr;
{
        char combuf[BUFLEN];
        char *cx;
        char *dispaddr; /* current display address */
	char *listaddr; /* current disassembly addr*/
	struct value curvals;	/* values relating to current file or pgm */
        register int i; /* workhorse integer */
 
	nomo = -1;
	omega = -1;
	scope = 0;
	trap(SETBLK,0,bpptr,bpptr->cslen+bpptr->dslen+bpptr->bslen+0x100L);
        /* phony machine state initialization */
        for (i=0; i<8; i++) {state.dreg[i]=0L; state.areg[i]=0L;}
        state.pc = 0x0;
        state.usp = 0x00001000L;
	state.areg[7]=state.usp;
        state.ssp = OrigSSP;
        state.status = 0x0000;
#ifdef MC68010
	state.vbr = GETVBR();
	state.sfc = GETSFC();
	state.dfc = GETDFC();
#endif
        dispaddr = 0L;
 	listaddr = 0L;
	curvals.kind = 0; /* no current file or program */
	zappas();	/* Purge pass points */
	init(bpptr, &state, &curvals, &dispaddr, &listaddr, &bpptr);
        while ( 1 ) { 
	   while ( ! (cx = readcom(combuf)) );
	   If *cx EQ '-' then BEGIN
		minus = 1;
		++cx;
	   END
	   otherwise minus = 0;
           switch ( *cx ) {
                /* one case for each possible command */
		case 'C':		/* Call subroutine ? */
				callrt(cx);
				break;

                case 'D' :		/* Display memory in hex & ascii */
					      display(cx, &dispaddr);
                                break;

                case 'E' :		/* Load program for execution */
						loadpgm((++cx), bpptr,
								 &state, &curvals, 
				     			&dispaddr, &listaddr, &bpptr);
                                break;

                case 'F' :		/* Fill memory block */
						fillmem(cx);
                                break;

                case 'G' :		/* Begin execution */
					      gocmd(cx,&state,&listaddr);
                                break;
 
                case 'H' :		/* Hex arithmetic */
					      hexmath(cx);
                                break;
 
                case 'I' :		/* Set file control block & command tail */
					      incomtl(cx, &curvals);
                                break;
 
		case 'K' :		/* Add, hide and display symbols? */
						koax(cx, bpptr);
				break;

                case 'L' :		/* List memory using MC68000 mneumonics */
					      disasm(cx, &listaddr);
                                break;
 
                case 'M' :		/* Move memory block */
					      movemem(cx);
                                break;
 
		case 'P' :		/* Set, clear and display pass points */
						passpt(cx);
				break;

                case 'R' :		/* Read disk file into memory */
					      readfl(cx, bpptr,
								 &curvals, &dispaddr);
                                break;
 
                case 'S' :		/* Set memory to new values */
					      setmem(cx);
                                break;
 
                case 'T' :		/* Trace program execution */
					      trace(cx, &state, &listaddr, (int)1);
                                break;
 
                case 'U' :		/* Untrace program monitoring */
					      trace(cx, &state, &listaddr, (int)0);
                                break;
 
                case 'V' :		/* Show memory layout of disk file read */
					      vcmd(cx, &curvals);
                                break;
 
                case 'W' :		/* Write contents of memory block to disk */
					      wrtfile(cx, &curvals);
                                break;
 
                case 'X' :		/* Examine & modify CPU state */
					      examine(cx, &state);
                                break;
 
                default  :      stout("Available commands are:\n");
							stout(" C, D, E, F, G, H, I, K, L, M, P, R, S, T, U, V, W, X\n");
                                break;
 
           }; /* end of switch on comx */ 
 
        };  /* end of while loop */
 
}  /* end of function main */


init(basep, statep, valuep, dap, lap, bppa)
struct	basepage *basep;
struct	cpustate *statep;
struct	value	 *valuep;
	char	**dap;
	char	**lap;
	long	 *bppa;
{
        /* if program file argument, then load it       */
        /* set up trap vectors                          */
        /* initialize tables                            */

 
	stout("\n***************************************************\n");
	stout("SID-68K for GEMDOS   3/22/85            Version 0.1\n");
	stout("Serial #XXXX-0000-654321        All Rights Reserved\n");
	stout("Copyright 1982,1983,1984,1985 Digital Research Inc.\n");
	stout("***************************************************\n\n");

	if (basep->comtail[0])
		loadpgm(&basep->comtail[1],basep,statep,valuep,dap,lap,bppa);

}
 
 
char *readcom(buf)      /* read one command line, return command type   */
register char *buf;
{
        register char *cx;
        register short int i,nc;
 
        do {
                stout("\r\r-");         /* prompt */
                *buf = BUFLEN-3;
                trap(READBUF, buf);     /* get command line */
                putchar('\n');        
 
        } while ( ( nc=buf[1]) == 0 );
        
        buf[2+nc] = 0;
 
        for ( cx = &buf[2]; *cx; *cx=toupper(*cx), cx++);
 
        for ( cx = &buf[2], i=0 ; iswhite(*cx) && (i<nc) ; cx++ , i++ );
 
        return( (i==nc) ? NULL : cx );
 
}
 
 
clean()
{
        /* restore trap vectors */
}


callrt(s)
char *s;
{
    struct cpustate tstate;
    int i;
    long ret;
    long n;
    long p[10];
    PFL rout;
    char c;


    if ( ! gethex(&s,&n) ) {
	bad();
	return(0);
    }

    for (i = 0; i < 10; i ++)
	p[i] = i;

    i = 0;
    while ( (i < 10) && ( (getsep(&s)) && (gethex(&s,&p[i])) ) ) {
	i++;
    }

    for (i = 0; i < 8; i++) {
	tstate.areg[i] = state.areg[i];
	tstate.dreg[i] = state.dreg[i];
    }
    tstate.pc = state.pc;
    tstate.usp = state.usp;
    tstate.ssp = state.ssp;
    tstate.status = state.status;


    rout = (PFL)n;
    ret = (*rout)(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9]);


    stout("Return value --> ");
    hexlzs(ret);
    stout("h\n");

    for (i = 0; i < 8; i++) {
	state.areg[i] = tstate.areg[i];
	state.dreg[i] = tstate.dreg[i];
    }
    state.pc = tstate.pc;
    state.usp = tstate.usp;
    state.ssp = tstate.ssp;
    state.status = tstate.status;

}
 

display(cx, dap)
char *cx;
char **dap;
{
        /* display memory in hex and ascii */
 	extern struct cpustate state;

           short int format;    /* 1=byte, 2=word, 4=long word */
                 char *s;       /* start address */
                 char *f;       /* end   address */
                 char *i;       /* working variable */
                 char *j;       /* ditto            */
             short int c;       /* column number */ 
 	long	SysStP;
 
        /* parse command and extract parameters */
 
	format = getform(&cx);

	if (*++cx == '@') {
	    if ((*++cx >= '0') && (*cx <= '7')) {
		s = state.areg[*cx - '0'];
		f = s + ((11*16) - 1);
	    }
	    else {
		bad();
		return(0);
	    }
	}
	else {
	cx--;
        if ( ! gethex(&cx, &s) ) {        /* get start address */
           if ( nomore(cx) ) s = *dap;    /* or use default    */
           else { bad(); return(0); }     /* junk on the line  */
        }
 
        if ( (format != 1) && (s & 1) ) s += 1;   /* force even */
 
        if ( GETSEP ) {if ( ! gethex(&cx, &f) ) {bad(); return;} }
        else f = s + (11*16-1);     /* not there, use def */
 
        if ( ! nomore(cx) ) {bad(); return;} /* rest of line must be empty */
 	}
 
        /* now do the display */
 
        f = f - format + 1;  /* first byte of last chunk to print */
 
        for ( ; s <= f ; s += 16 ) { /* one line per pass */
 
                if ( keyhit() ) return;
 
                puthexl(s); putchar(' '); putchar(' '); c = 10;

		SysStP = trap(SUPVMOD, 0L); /* Go to Supervisor mode */
 
                for ( i=s, j=min(s+15,f);
                      i <= j;
                      i += format ) {
 
                        switch ( format ) {
 
                                case 1 : puthexb(i->memb);
                                         break;
 
                                case 2 : puthexw(i->memw);
                                         break;
 
                                case 4 : puthexl(i->meml);
                                         break;
 
                        } /* end of switch */
 
                        putchar(' ');
 
                        c += (2*format+1);
 
                } /* end of loop across line */
                
                while ( c++ < 60 ) putchar(' ');
 
                for ( i=s, j=min(s+15,f); i<=j ; i++ ) putbyte(*i);

		trap(SUPVMOD, SysStP);		/* Return to User mode */
 
                putchar('\n');
 
        } /* end of loop through lines */
 
 
        *dap = f + format;
 
} /* end display */
 

 
loadpgm(pgm, basep, statep, valuep, dap, lap, bppa)
char		*pgm;
struct	basepage *basep;
struct	cpustate *statep;
struct	value	 *valuep;
	char	**dap;
	char	**lap;
	long	 *bppa;
{		/* load a program for execution */
	extern	int	omega;
		int	loaderr;
	struct	basepage *newbp;
		long	*stkptr,*pl;
		int	i,handl;
		char	*p;
		struct	hdr sector;
		long	stlen;
		long	symmem; /* allocated space for symbol table */

	/* open program file */
	while (*pgm == 0x20) pgm++;
	for (p = pgm; (*p != 0x20) && (*p != 0x0d) && *p; p++);
	*p = 0; /* null terminate command */
	if ( (handl = trap(OPEN,pgm)) <= 0)
	{
		stout("Cannot open program file\n");
		return;
	}
	if ( trap(READ,handl,(long) sizeof(struct hdr),&sector) != 
		sizeof(struct hdr))
	{
		stout("Can not read program file.\n");
		trap(CLOSE,handl);
		return;
	}
	trap(CLOSE,handl);

	stlen = sector.seglen[3]; /* symbol table length in bytes */
	if (stlen) caput = trap(MALLOC,stlen + sizeof(struct lmhedr));

	/* load 'em up, move 'em out */

	if ((newbp = trap(EXEC,3,pgm,0L,0L)) < 0L)
	{
		stout("program load error\n");
		return;
	}
	/* successful load */
	valuep->kind = 1;
	valuep->textbase = newbp->csstart;
	valuep->textlen  = newbp->cslen;
	valuep->database = newbp->dsstart;
	valuep->datalen  = newbp->dslen;
	valuep->bssbase  = newbp->bsstart;
	valuep->bsslen   = newbp->bslen;
	valuep->bpa	 = newbp;
	stkptr = newbp->hightpa;
	statep->pc = newbp->csstart;
	(*--stkptr) = newbp;
	(*--stkptr) = 0L;
	valuep->initstk  = stkptr;
	statep->usp = stkptr;
	statep->areg[7]= stkptr;
	statep->status = 0;
	*dap = newbp->csstart;
	*lap = newbp->csstart;

	zappas();	/* Delete all pass points */
	if (stlen) omega = simz(pgm,valuep->textbase); /*load symbol table*/
	else omega = -1;
	showvals(valuep);

}  /* end loadpgm */
 
 
fillmem(cx)
char *cx;
{
        /* fill memory with constant */
 
  register short int format;    /* 1=byte, 2=word, 4=long word */
                 char *s;       /* start address */
                 char *f;       /* end   address */
                 long  v;       /* value to stuff into memory */
 	long	SysStP;

        /* parse command and extract parameters */
 
	format = getform(&cx);

        if ( gethex(&cx, &s) );         /* get start address */
        else {bad(); return(0);}        /* not there, error  */
 
        if ( (format != 1) && (s & 1) ) /* must be even address, error */
                {bad(); return(0);}
 
        if ( GETSEP && gethex(&cx, &f) ); /* get end address  */
        else { bad(); return(0); }                /* not there, error */
 
        if ( GETSEP && gethex(&cx, &v) ); /* get value to stuff */
        else { bad(); return(0); }
 
        if ( ! nomore(cx) ) {bad(); return;} /* rest of line must be empty */
 
        if ((s>f) ||      /* test for junk or nonsense */
            ( (format == 1) && ((v > 255L)   || (v < 0)) ) ||
            ( (format == 2) && ((v > 65535L) || (v < 0)) )  )
        { bad(); return(0); }
 
 
        /* now do the stuffing */
 
	SysStP = trap(SUPVMOD, 0L);		/* Go to Supervisor mode */

        for ( ; (s+format) <= (f+1); s += format )
	{ 
                switch ( format ) {
 
                   case 1 : s->memb = (char)v;
                            if ((s->memb ^ (char)v) & 0xFF) badram(s);
                            break;
 
                   case 2 : s->memw = (short int)v ;
                            if ((s->memw ^ (short int)v) & 0xFFFF) badram(s);
                            break;
 
                   case 4 : s->meml = (long)v ;
                            if ( s->meml != v ) badram(s);
                            break;
 
		} /* end of switch */

	}   /* end of for */

	trap(SUPVMOD, SysStP);		/* Return to User mode */
 
} /* end of fillmem */

