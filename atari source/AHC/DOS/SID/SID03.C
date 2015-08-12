/************************************************/
/*						*/
/*	Usual filename:  SID03.C		*/
/*	Remarks:  Second C module for SID68K	*/
/*	Author:  Timothy M. Benson		*/
/*	Control:  19 MAY 83   16:52  (TMB)	*/
/*						*/
/************************************************/
 
#include "lgcdef.h"
#include "cputype.h"
#include "siddef.h"
#include "sidinc.h"
#include "stdio.h"
#include "bdosfunc.h"
#include "disas.h" 
 
gocmd(cx,statep,nulist) /* begin executing (optional breakpoints) */
char *cx;
struct cpustate *statep;
int **nulist;
{
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];
	extern	U16	ancien[HMPPTS];
	extern	int	minus;	/* 1 => no intermediate display	*/
        int   nbp;
        long  brkpt[MAXBP];
        short brkwd[MAXBP];
        long  newpc;
        long  x;
        int   i;
	short	itsapp;	/* 1 => ILLEGAL identified as pass point */
 	short	mor;	/* 1 => nonzero pass count, so GO again */
	union asis BEGIN
	    long i32;
	    char *p8;
	    int *p16;
	END strand; /* General purpose pointer */
	int	jetsam;	/* Place to save word after system call	*/

 	deblank(&cx);
        newpc = statep->pc;
        if (gethex(&cx, &x)) newpc = x;
	nbp = 0;
        while ( GETSEP ) {
           if (nbp >= MAXBP) {bad(); return;}
           else { if (gethex(&cx,&x)) brkpt[nbp++]=x;
                  else {bad(); return;}
           }
        }
        if ( ! nomore(cx) ) {bad(); return(0);}
	statep->pc = newpc;

	/* Execute one instruction */

	if (STEP(statep)) return;	/* exit if error */

/* Repeatedly set up pass points, break points, GO, restore	*/
/*    after break, restore after pass, process pass point if	*/
/*    applicable, continuing until pass point with count of one	*/
/*    is encountered or until break point is encountered.	*/ 
	for (mor = 1; mor and NOT keyhit();) BEGIN 
	    stick();	/* Set up pass points */
	    for (i=0; i<nbp; i++) {
		/* Set break points, saving previous contents.	*/
		brkwd[i]=(brkpt[i])->memw;
		brkpt[i]->memw = ILLEGAL;
	    }
	    GO(statep);
	    /* Restore previous contents at break points.	*/
	    for (i=0; i<nbp; i++) brkpt[i]->memw = brkwd[i];
	    yank(); /* Restore original contents at pass points. */
	    newpc = statep AT pc;
	    /* Determine if pass point */
	    for(i=0,itsapp=0; i LT HMPPTS and NOT itsapp; i++) BLOCK
		strand.p16 = plocus[i];
		If pkawnt[i] and strand.i32 EQ newpc then begin
		    itsapp = 1;
		    i--;
		end
	    UNBLOCK
	    strand.i32 = newpc;
	    If *strand.p16 EQ ILLEGAL then BLOCK
		showstate(statep);
		stout("\nEncountered the ILLEGAL instruction\n");
		goto trotz;
	    UNBLOCK
	    If itsapp then BLOCK
		If pkawnt[i] EQ (U16) 1 or NOT minus then begin
		    shopas(i);
		    showstate(statep);
		end
		If ancien[i] NE BDOSCALL and ancien[i] NE BIOSCALL
		    then STEP(statep);
		else begin /* Execute system call normally */
		    strand.i32 = newpc + 2;
		    jetsam = *strand.p16;
		    *strand.p16 = ILLEGAL;
		    GO(statep);	
		    *strand.p16 = jetsam;
		end
		newpc = statep AT pc;
		If pkawnt[i] GT (U16) 1 then --pkawnt[i];
		otherwise begin
		    mor = 0;
		    showstate(statep);
		end
	    UNBLOCK
	    otherwise BLOCK
		mor = 0;
		showstate(statep);
	    UNBLOCK
	END
trotz:
	*nulist = statep AT pc;
}  /* end of go command */

/************************************************/
/* H alone: Spill symbol table			*/
/* Ha format:  Print hex, ASCII, symbols	*/
/* Ha,b format:  Do arithmetic			*/
/************************************************/

hexmath(cx)
char *cx;
{
	extern struct lmhedr *caput;
	extern int omega;
	extern int scope;
        long a, b;
 
	deblank(&cx);
	If nomore(cx) then BEGIN
	    If omega GE 0 then deluge(caput AT sump,omega);
	    else stout("\nNo symbols\n");
	END
	otherwise BEGIN
	    If gethex(&cx,&a) and nomore(cx) then BLOCK
		putchar('\n');
		puthexl(a);
		putchar(' ');
		If qotbyt(a) then putchar(' ');
		spell(a,caput AT sump,scope,'b','h');
		putchar('\n');
	    UNBLOCK
	    else If GETSEP && gethex(&cx,&b) && nomore(cx) then BLOCK
		putchar('\n'); 
                puthexl(a+b);
                putchar(' ');
                puthexl(a-b);
                putchar('\n');
	    UNBLOCK
	    else bad();
	END
}

incomtl(cx, valuep)
char *cx;
struct value *valuep;
{	/* process command tail */
	register char *p;
	register char *q;
	register char nc;
	register struct basepage *bpp;

	if ( (valuep->kind) != 1 ) {bad(); return;} /* no pgm loaded */

	bpp = valuep->bpa;
	p = cx + 1;
	q = &(bpp->comtail[1]);
	nc = 0;
	while (*p) { *q++ = *p++; nc += 1;}
	*q = *p;
	bpp->comtail[0] = nc;

}

disasm(cx,dap)
char *cx;
char **dap;
{		/* display memory in assembly format */
	extern	struct	lmhedr	*caput;
	extern	int	scope;
	char *s;       /* start address */
	char *f;       /* end   address */
        register short int deflt;
        register short int nl;
 	long	SysStP;

	/* parse command and extract parameters */
	deblank(&cx);
        if ( ! gethex(&cx, &s) ) {      /* get start address */
           if (nomore(cx)) s = *dap;    /* or use default    */
           else {bad(); return(0);}     /* junk on the line  */
        }
 
        if ( s & 1) { bad(); return(0);} /* must use even address */
 
        if ( GETSEP ) {			/* get end address */
	  if ( gethex(&cx, &f) ) deflt=0; /* got it */
	  else { bad(); return(0); }
	}
        else { f = s; deflt = 1; }            /* not there, use def */
 
        if((!nomore(cx)) || (s>f)) {bad(); return(0);} /* junk or nonsense */
 
 
        /* now do the display */
 
        nl = 0;
        while ( (s<=f) || (deflt && (nl<12)) ) {
 
                if ( keyhit() ) return;
		SysStP = trap(SUPVMOD, 0L);	/* Go to supervisor mode */
		If caput then nl INCBY 
		    spell((U32) s,caput AT sump,scope,'m','v');
		putchar(' ');
		putchar(' '); 
                puthexl(s); putchar('\t');
                dot = s;
                pinstr();
		trap(SUPVMOD, SysStP);	/* Return to User mode */
                putchar('\n');
                s += dotinc;
                nl++;
                *dap = s;
        } /* end of loop through instructions */
} /* end disassembly */

movemem(cx)
char *cx;
{	/* move memory block */
        char *s;       /* start address       */
        char *f;       /* end   address       */
        char *d;       /* destination address */
 	long	SysStP;

        /* parse command and extract parameters */
	deblank(&cx);
        if ( gethex(&cx, &s) );         /* get start address */
        else {bad(); return(0);}        /* not there, error  */
 
        if ( GETSEP && gethex(&cx, &f) ); /* get end address  */
        else { bad(); return(0); }                /* not there, error */
 
        if ( GETSEP && gethex(&cx, &d) ); /* get dest address */
        else { bad(); return(0); }
 
        if ((!nomore(cx)) || (s>f) )   /* test for junk or nonsense */
           { bad(); return(0); }
 
        /* now do the moving */
	SysStP = trap(SUPVMOD, 0L);	/* Go to supervisor mode */
        for ( ; s <= f; s++, d++ ) d->memb = s->memb;
	trap(SUPVMOD, SysStP);		/* Return to User mode */
} /* end of movemem */
 
readfl(cx, basep, valuep, dap)
char *cx;
struct basepage *basep;
struct value	*valuep;
char **dap;
		/* read a file into memory */
{
		long	lotpa;
		long	hitpa;
		long	curdma, n, fl;
		int	endofile, handl;

	deblank(&cx);
	++cx;
	if ( (handl = trap(OPEN,cx)) < 0)
	{
		stout("Cannot open file\n");
		return;
	}
	curdma = trap(MALLOC,10000L);
	endofile = 0;
	fl = trap(LSEEK, 0L, handl, 2);	/* Find the size of the file */
	trap(LSEEK, 0L, handl, 0);	/* and return to the beginning */
	if ((n = trap(READ, handl, fl, curdma)) != fl)
		stout("\nFile too big -- read truncated.\n");
	trap(CLOSE, handl);
	valuep->kind = 2;
	valuep->textbase = curdma;
	valuep->textlen = n;
	showvals(valuep);
	*dap = lotpa;
}

setmem(cx)
char *cx;
{
        /* set memory */
 
  register short int format;    /* 1=byte, 2=word, 4=long word */
                 char *s;       /* start address */
                 long  v;       /* value to stuff into memory */
                 char buf[BUFLEN]; /* input buffer */
                 char *bx;         /* points into buf */
           short int   nc;         /* num of hex digits input */
 	long	SysStP;

        /* parse command and extract parameters */
 
	format = getform(&cx);

        if ( gethex(&cx, &s) );         /* get start address */
        else {bad(); return(0);}        /* not there, error  */
 
        if ( (format != 1) && (s & 1) ) /* must be even address, error */
                {bad(); return(0);}
 
        if (!nomore(cx)) { bad(); return(0); } /* test for junk */
 
 
        /* now do the stuffing */

 
        for ( ; ; s += format ) {
 
                puthexl(s); putchar(' ');
		SysStP = trap(SUPVMOD, 0L);	/* Go to supervisor mode */
                switch ( format ) {
 
                   case 1: puthexb(s->memb);
                           break;
 
                   case 2: puthexw(s->memw);
                           break;
 
                   case 4: puthexl(s->meml);
                           break;
 
                } /* end of switch */
		trap(SUPVMOD, SysStP);		/* Return to User mode */

                putchar(' ');
 
                *buf = BUFLEN - 2;
                trap( READBUF, buf );
                putchar('\n');
 
                buf[2+(nc=buf[1])] = 0;
                if ( nc > 0 ) {
 
                        if ( buf[2] == '.' ) {return(0);}
 
                        for ( bx = &buf[1] ; *++bx ; ) *bx = toupper(*bx) ;
 
                        bx = &buf[1];
                        if ( gethex( &bx, &v ) );
                        else { bad(); return(0); }
 
                        while ( (*++bx) == 0x20 ) ; /* skip blanks */
 
                        if ( (*bx != 0) ||      /* test for bad input */
                             ( (format == 1) && ((v>255L)   || (v<0)) ) ||
                             ( (format == 2) && ((v>65535L) || (v<0)) )  )
                           { bad(); return(0); }
 
                        /* stuff the value */
 
			SysStP = trap(SUPVMOD, 0L); /* Go to supervisor mode */

                        switch ( format ) {
 
                           case 1 : s->memb = (char)v ;
				    if ( (s->memb ^ v) & 0x0ffL ) badram(s);
                                    break;
 
                           case 2 : s->memw = (short int)v ;
				    if ( (s->memw ^ v) & 0x0ffffL ) badram(s);
                                    break;
 
                           case 4 : s->meml = (long)v ;
				    if ( s->meml ^ v ) badram(s);
                                    break;
 
                        } /* end of switch */
			trap(SUPVMOD, SysStP);	/* Return to User mode */
 
                } /* end of nc > 0 */
 
        } /* end of for */  

 
} /* end of setmem */
 
trace(cx, statep, dap, tr)
char *cx;
struct cpustate *statep;
char **dap;
int tr;
{		/* trace program execution for n steps */
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];
	extern	U16	ancien[HMPPTS];
	extern	int	minus;	/* 1 => no intermediate display	*/
	extern	int	omega;	/* If negative, SID thinks no symbols */
	int	iota;	/* Place to keep true value of "omega" */
			/*	while kidding oneself	       */
	short	itsapp;	/* 1 => ILLEGAL identified as pass point */
	union asis32 BEGIN
	    long i32;
	    char *p8;
	    U16 *p16;
	END strand; /* General purpose pointer */
/**temp** Watch this:  "strand" declared "*strand" elsewhere and */
/**temp** seems to work.  Not sure why it works there, so it may */
/**temp** not work here.					 */
	int	jetsam;	/* Place to save word after system call	*/
	long nsteps;
	register int underw;	/* 1 => trace without call */
	int oxbow;	/* 0 => trace; otherwise it = length */
	register int inst;
	register long addr;
	int	jt;	/* General purpose loop index */
	short	mor;	/* 1 => not finished with GO */
	int	kt;	/* Loop index for GO */
	int	steperr; /* set if an error exception occurs during step */

	iota = omega;	/* Save true value of "omega" */
	deblank(&cx);
	underw = vecina(&cx,'W');
	if ( ! gethex(&cx, &nsteps)) nsteps = 1;
	if ( ! nomore(cx) ) {bad(); return;}
/* Warning:  Let there be no explicit returns here to end */
/*	of function, lest symbols be accidentally zapped. */
	If tr and minus then omega = -1;
	while(nsteps--) {
	    inst = (addr = (statep->pc))->memw;
	    If inst EQ ILLEGAL then BEGIN
		showstate(statep);
		stout("\nEncountered the ILLEGAL instruction\n");
		goto reject;
	    END
	    /* GO thru traps, ignoring pass points */
	    If (inst & 0xFFF0) EQ 0x4E40 then BEGIN
		inst = (addr INCBY 2) AT memw;
		addr AT memw = ILLEGAL;
		GO(statep);
		addr AT memw = inst;
		goto refuse;
	    END
	    If underw and ((inst & 0xFF00) EQ 0x6100
	    or (inst & 0xFFC0) EQ 0x4E80) then BEGIN
		If NOT (inst & 0x00FF) then oxbow = 4;	/* Long BSR */
		else If (inst & 0xFF00) EQ 0x6100 then oxbow = 2;
							/* Short BSR */
		else BLOCK				/* JSR */
		    inst ANDWITH 0x003F;
		    If inst GE 0x0038 then begin
			If inst EQ 0x0039 then oxbow = 6;
			otherwise oxbow = 4;
		    end
		    else begin
			inst ANDWITH 0x0038;
			If inst EQ 0x0010 then oxbow = 2;
			otherwise oxbow = 4;
		    end
		UNBLOCK
	    END
	    otherwise oxbow = 0;
	    strand.i32 = addr;
	    for(jt=0,itsapp=0;jt LT HMPPTS and NOT itsapp;jt++)
	      If pkawnt[jt] and strand.p16 EQ plocus[jt] then BEGIN
		itsapp = 1;
		jt--;
	      END
	    If itsapp then BEGIN
		If pkawnt[jt] GT (U16) 1 then --pkawnt[jt];
		otherwise nsteps = 0;
		If NOT nsteps or NOT tr and NOT minus then BLOCK
		    shopas(jt);
		    showstate(statep);
		UNBLOCK
	    END
	    If oxbow then BEGIN
		inst = (addr INCBY oxbow) AT memw;
		addr AT memw = ILLEGAL;
		steperr = STEP(statep);
		for (mor=1;mor;) BLOCK
		  stick();
		  GO(statep);
		  yank();
		  If (strand.i32 = statep AT pc) EQ addr then mor = 0;
		  otherwise begin
		    for(kt=0,itsapp=0;kt LT HMPPTS and NOT itsapp;kt++)
		      If pkawnt[kt] and strand.p16 EQ plocus[kt] then {
			itsapp = 1;
			kt--;
		      }
		    If itsapp and pkawnt[kt] GT (U16) 1 then --pkawnt[kt];
		    else {mor = 0; nsteps = 0;}
		    If *strand.p16 EQ ILLEGAL then {
			showstate(statep);
			stout("\nEncountered the ILLEGAL instruction\n");
			addr AT memw = inst;
			goto reject;
		    }
		    If NOT nsteps or NOT tr and NOT minus then {
			shopas(kt);
			showstate(statep);
		    }
		    steperr = STEP(statep);
		    If keyhit() then {mor = 0; nsteps = 0; tr = 0;}
		  end
		UNBLOCK
		addr AT memw = inst;
	    END
	    otherwise steperr = STEP(statep);
refuse:
	    if (tr) showstate(statep);
	    if ( keyhit() || steperr ) nsteps = 0;
	}
	if ( ! tr ) showstate(statep);
reject:
	*dap = statep->pc;
	omega = iota;	/* Reenable symbols. */
}

vcmd(cx, valuep)
char *cx;
struct value *valuep;
{/* display start and end of stuff loaded with R or E commands */
	if (nomore(cx)) showvals(valuep);
	otherwise bad();
}

wrtfile(cx, valuep)
char *cx;
struct value *valuep;
	/* write memory contents to disk */
{
	int handl;
	char *p;

	deblank(&cx);
	++cx;
	if ( (valuep->kind) != 2 ) {bad(); return;}
	trap(UNLINK,cx);
	handl = trap(CREATE, cx, 0);
	trap(WRITE,handl, valuep->textlen, valuep->textbase);
	trap(CLOSE,handl);
}
 
int dummy(s)
char *s;
{
        stout("\n\nUnimplemented Function: ");
        stout(s);
        stout("\n\n");
}

shopas(jsh)	/* Display pass-point data */
int jsh;
{
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];

	putchar('\n');
	puthexw(pkawnt[jsh]);
	stout("  PASS  ");
	puthexl(plocus[jsh]);
	putchar('\n');
}

stick()	/* Set pass points, saving original contents.	*/
{
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];
	extern	U16	ancien[HMPPTS];
	int	kst;

	for (kst=0; kst LT HMPPTS; kst++)
		If pkawnt[kst] then BLOCK
			ancien[kst] = *plocus[kst];
			*plocus[kst] = ILLEGAL;
		UNBLOCK
}

yank()	/* Restore original contents at pass points.	*/
{
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];
	extern	U16	ancien[HMPPTS];
	int	kya;

	for (kya=0; kya LT HMPPTS; kya++)
		If pkawnt[kya] then *plocus[kya] = ancien[kya];
}
