/*
	Copyright 1982
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121

	@(#)symt.c	2.1	7/10/84
*/

#include "lo68.h"

char tfilname[];
char etexstr[];
char edatstr[];
char eendstr[];
int debug;
int exstat;

/* get one symbol entry from the input file and put it into*/
/*  the symbol table entry pointed to by lmte*/
getsym()	/* rewritten for vax */
{
	register int i;
	long lvalue;
	char *p;
	short wvalue;

	p = lmte;
	for(i=SYNAMLEN; --i != -1; )	/* 2 may 83 */
		*p++ = getc(&ibuf);	        /* get name */
	if (lgetw(&wvalue, &ibuf) == -1)
		printf(": error reading symbol table entry\n");
	else if (lgetl(&lvalue ,&ibuf) == -1)
		printf(": error reading symbol table entry\n");	/* symbol value */
	((struct symtab *)lmte)->flags = wvalue;
	((struct symtab *)lmte)->vl1 = lvalue;
#ifdef DEBUG
	printf("\tname= %s, flags= %o, val= %d\n", ((struct symtab *)lmte)->name, 
			((struct symtab *)lmte)->flags, ((struct symtab *)lmte)->vl1);
#endif
}

/* relocate the symbol value pointed to by lmte according to*/
/*  symbol type and corresponding relocation base*/
relocsym()
{
	long l;

	if(((struct symtab *)lmte)->flags&SYXR)            /*external*/
		return;
	if(((struct symtab *)lmte)->flags&SYTX)
		l = textbase;
	else if(((struct symtab *)lmte)->flags&SYDA)
		l = database;
	else if(((struct symtab *)lmte)->flags&SYBS)
		l = bssbase;
	else if(((struct symtab *)lmte)->flags&SYEQ)       /*equated*/
		return;                 /* abs*/
	else {
		printf(": name = %s -- Invalid ",((struct symtab *)lmte)->name);
		printf("symbol flags: 0%o\n",(int)((struct symtab *)lmte)->flags);
		endit(-1);
	}
	((struct symtab *)lmte)->vl1 += l;
}

#define ADDSYM	"addsym: file=%s symbol=%s flags=%o\n"
/*
 * add a symbol to the symbol table
 * if symbol is an external, put it on eirt even if it does
 * already exist
 * if symbol is a global, put it on girt and error if it exists
 * in any case, add it to the end of the symbol table
 * if libflg is set, we are searching a library.  In this case, when
 * a global is encountered, search the external symbols and set
 * extmatch if a match is found.
 */
addsym(libflg)
{
	register char *p;

#ifdef DEBUG
    if(debug)
    	printf(ADDSYM,ifilname,lmte,(int)((struct symtab *)lmte)->flags);
#endif
	
	if(((struct symtab *)lmte)->flags&SYXR) {  /*external*/
		p = lemt(eirt);
		mmte();
	}
	else if(((struct symtab *)lmte)->flags&SYGL) {     /*global*/
		if(libflg) {            	/*global in a library*/
			p = lemt(eirt); 		/*look up in externals*/
			if(p != lmte) {         /*found a match*/
				extmatch++;
			}
		}
		p = lemt(girt);
		if(p == lmte)
			mmte();
		else if(((struct symtab *)p)->flags!=((struct symtab *)lmte)->flags || 
				((struct symtab *)p)->vl1 != ((struct symtab *)lmte)->vl1) {
dupdef:
			if(libflg) {
				noload++;
				lastdup = p;
			}
			else
				prdup(p);               /*dup defn msg*/
		}
		else {
			addmte();	/* put entry in for external #`s */
		}
	}
	else {          /*normal symbol*/
		if(((struct symtab *)lmte)->name[0] == 'L')    /*compiler label*/
			return;
		if(Xflag==0)            		/*dont save local symbols*/
			return;
		addmte();
	}
}

prdup(p)
char *p;
{
	printf(": %s duplicate definition in %s\n",p,ifilname);
	exstat++;
}

/* initialize the symbol table and the heads of the hash lists*/
intsytab()
{
	register char **p1, **p2;
	register i;
	long longtmp;

#ifndef VMS
	bmte = sbrk(SYTESIZE*SZMT+2);
#else
	/* sub 1 from sbrk size on vax since in rounds up to next multiple of 512 */
	bmte = sbrk(SYTESIZE*SZMT+1);
#endif
	longtmp = (long)bmte; /* 11 apr 83, for vax */
	if(longtmp&1L)  /* 11 apr 83, for vax */
		bmte++;
	emte = bmte + SYTESIZE*SZMT;            /*end of main table*/
	lmte=bmte;      /*beginning main table*/
	cszmt = SZMT;   /*current size of main table*/
	p1 = eirt;
	p2 = girt;
	for(i=32; --i != -1; ) {	/* 2 may 83 */
		*p1++ = (char *)p1;
		*p1++ = (char *)0;
		*p2++ = (char *)p2;
		*p2++ = (char *)0;
	}
}

/*
 * method for looking up entries in the main table
 *
 * Note:   The entry to be looked up must be placed at the end
 *         of the main table.  The global cell 'lmte'(last main
 *         entry) points to the next available entry in the main
 *         table.  The address of an initial reference table must
 *         also be provided.

 *   1)    Compute the hash code for the symbol and add it to the base address
 *         of the initial reference table given as input.  Thus, two words are
 *         accessed which define the chain on which the symbol must be if it is
 *         in the table at all.

 *   2)    Alter the table link of the last symbol in the chain so that it 
 *         points to the symbol being looked up.  Note that the symbol to be 
 *         looked up is always placed at the end of the main table before 
 *         calling the lookup routine.  This essentially adds one more element
 *         to the end of the chain, namely the symbol to be looked up.

 *   3)    Now start at the first symbol in the chain and follow the chain
 *         looking for a symbol equal to the smbol being looked up.  It is
 *         quaranteed that such a symbol will be found because it is always 
 *         the last symbol on the chain.

 *   4)    When the symbol is found, check to see if it is the last symbol
 *         on the chain.  If not, the symbol being looked for is in the table
 *         and has been found.  If it is the last symbol, the symbol being 
 *         looked up is not in the table.

 *   5)    In the case the looked up symbol is not found, it is usually added
 *         to the end of the table.  This is done simply by changing the 
 *         initial reference table entry which points to the previous
 *         last symbol on the chain so that is now points to the symbol at the
 *         end of the main table.  In case the symbol just looked up is not to
 *         be added to the main table then no action is needed .  This means
 *         that the table link of the last symbol on a chain may point any-
 *         where.

 * look up entry in the main table
 *              call with:
 *                      address of initial reference table
 *                      entry to be looked up at the end of the main table
 *              returns:
 *                      a pointer to the entry.  if this pointer is equal to
 *                      lmte then the symbol was not previously in the table.
 */
char *
lemt(airt)
char **airt;
{
	register struct symtab *mtpt;	/* 14 apr 83, from char * */

	pirt = airt + hash();   /*pointer to entry in irt*/
	  /*pointer to first entry in chain*/
	mtpt = (struct symtab *)((struct irts *)((struct irts *)pirt)->irfe);
	if(mtpt==0)             /*empty chain*/
		mtpt = (struct symtab *)lmte;  	   /*start at end of main table*/
	else					/*last entry in chain is new symbol*/
		((struct symtab *)((struct irts *)pirt)->irle)->tlnk = lmte;
	return(nextsy(mtpt));   /*return next match on chain*/
}

/*
 * locate the next symbol on a given hash chain with the same name as lmte
 *  return a pointer to it.  When this pointer is equal to lmte, the
 *  chain has been completely searched.
 */
char *
nextsy(amtpt)
char *amtpt;
{

	register char *mtpt;
	register char *p1, *p2;
	register int i;

	mtpt = amtpt;

/*loop to locate entry in main table*/
lemtl:
	p1 = &((struct symtab *)mtpt)->name[0];
	p2 = &((struct symtab *)lmte)->name[0];
	for(i=SYNAMLEN; --i != -1; ) {	/* 2 may 83 */
		if(*p1++ != *p2++) {	    /* changed to char ptr compares */
			mtpt = ((struct symtab *)mtpt)->tlnk; /*go to next entry in chain*/
			goto lemtl;
		}
	}
	return(mtpt);
}

/*
 *make an entry in the main table
 * assumes:
 *      entry to be made is pointed at by lmte
 *      pirt points to the correct initial reference table entry
 */
mmte()
{

	((struct irts *)pirt)->irle = lmte;    /*pointer to last entry in chain*/
	if(((struct irts *)pirt)->irfe == 0)   /*first entry in chain*/
		((struct irts *)pirt)->irfe = lmte;
	addmte();
}

/* add the symbol pointed to by lmte to symbol table*/
addmte()
{

	lmte += SYTESIZE;	/*bump last main table entry pointer*/
	if(lmte>=emte) {		/*main table overflow*/
#ifndef VMS
		if(sbrk(SYTESIZE*ICRSZMT) == (char *)-1){   /*get more memory*/
#else
	/* sub 1 from sbrk size on vax since in rounds up to next multiple of 512 */
		if(sbrk(SYTESIZE*ICRSZMT-1) == (char *)-1){   /*get more memory*/
#endif
			printf(": symbol table overflow\n");
			exit(-1);
		}
		else {			/*move end of main table*/
			emte += SYTESIZE*ICRSZMT;
			cszmt += ICRSZMT;
		}
	}
}

/* compute a hash code for the last entry in the main table*/
/*      returns the hash code*/
hash()
{
	register ht1, i;        /*temps*/
	register char *p;

	ht1 = 0;
	p = &((struct symtab *)lmte)->name[0];
	for(i=SYNAMLEN; --i != -1; ) 	/* 2 may 83 */
		ht1 += *p++;
	return(ht1&(SZIRT-2));       /*make hash code even and between 0 and 62*/
}

/*
 * pack a string into an entry in the main table
 *      call with:
 *              pointer to the string
 *              pointer to desired entry in the main table
 */
pack(apkstr,apkptr)
char *apkstr;
char *apkptr;
{
	register i;
	register char *pkstr, *pkptr;

	pkstr = apkstr;
	pkptr = apkptr;
	for(i=SYNAMLEN; --i != -1; ) /* 2 may 83 */
		*pkptr++ = *pkstr++;	 /* changed to char ptr move */
}

/*save the current state of the symbol table -- it may be restored later*/
savsymtab()
{
	register char **p1, **p2;
	register i;

	savlmte = lmte;
	p2 = eirt;
	p1 = saveirt;
	for(i = SZIRT; --i != -1; )	/* 2 may 83 */
		*p1++ = *p2++;
	p2 = girt;
	p1 = savgirt;
	for(i = SZIRT; --i != -1; )	/* 2 may 83 */
		*p1++ = *p2++;
}

/*restore the symbol table as it was when we last saved it*/
restsymtab()
{
	register char **p1, **p2;
	register i;

	lmte = savlmte;
	p1 = eirt;
	p2 = saveirt;
	for(i = SZIRT; --i != -1; )	/* 2 may 83 */
		*p1++ = *p2++;
	p1 = girt;
	p2 = savgirt;
	for(i = SZIRT; --i != -1; )	/* 2 may 83 */
		*p1++ = *p2++;
}

/*
 * resolve the external variable addresses and set the
 *  base address of the data and bss segments.
 *  also allocate storage for the common variables.
 */
resolve()
{
	register char *p;

	textsize = textbase - textstart;
	datasize = database;
	bsssize = bssbase;
	if(Dflag)
		database = datastart;
	else if(shtext) {       /*shared text - move start of data*/
		if(shtext == -1) {      /* 2k boundary */
			database = (textbase+SH2BOUND)&~(SH2BOUND-1);
			datastart = database;
		}
		else {          /* 4k boundary */
			database = (textbase+SHBOUND)&~(SHBOUND-1);
			datastart = database;
		}
	}
	else if(isplit) {       /* i & d split*/
		database = 0;
		datastart = 0;
	}
	else {
		database = (textbase+1)&~1;
		datastart = database;
	}
	if(Bflag)
		bssbase = bssstart;
	else {
		bssbase = (database+datasize+1)&~1;
		bssstart = bssbase;
	}
	textbase = textstart;
	fixsyms();              /*relocate symbols with addresses*/
	fixexts();              /*fix external addresses & commons*/
	if(etextptr) {
		pack(etexstr,lmte);
		p = lemt(eirt);
		do {
			((struct symtab *)p)->vl1 = textbase + textsize;	/*[vlh]4.2*/
			((struct symtab *)p)->flags &= ~SYXR;      /*no longer external*/
			((struct symtab *)p)->flags |= SYDF|SYGL;
		} while((p = nextsy(((struct symtab *)p)->tlnk)) != lmte);
	}
	if(edataptr) {
		pack(edatstr,lmte);
		p=lemt(eirt);
		do {
			((struct symtab *)p)->vl1 = database+datasize;	/*[vlh]4.2*/
			((struct symtab *)p)->flags &= ~SYXR;      /*no longer external*/
			((struct symtab *)p)->flags |= SYDF|SYGL;
		} while((p = nextsy(((struct symtab *)p)->tlnk)) != lmte);
	}
	if(endptr) {
		pack(eendstr,lmte);
		p = lemt(eirt);
		do {
			((struct symtab *)p)->vl1 = bssbase+bsssize;	/*[vlh]4.2*/
			((struct symtab *)p)->flags &= ~SYXR;      /*no longer external*/
			((struct symtab *)p)->flags |= SYDF|SYGL;
		} while((p = nextsy(((struct symtab *)p)->tlnk)) != lmte);
	}
}

/* fix symbol addresses that have been assigned by adding in*/
/*  database and bssbase*/
fixsyms()  					/*look at each symbol*/
{
	register struct symtab *p;

	for(p = (struct symtab *)bmte; p<(struct symtab *)lmte; p++) {
		if(p->flags&SYXR)
			continue;
		if(p->flags&SYDA)        /*data symbol*/
			p->vl1 += database;
		else if(p->flags&SYBS)   /* bss symbol*/
			p->vl1 += bssbase;
	}
}

/* get addresses for all external symbols and common symbols*/
fixexts()
{
	register char *p;
	register char **sx1, **sx2;

	for(sx1=eirt; sx1<&eirt[63]; sx1 += 2) {        /*go thru externals*/
		if(*(sx2 = sx1+1)==0)   /*this chain empty*/
			continue;

/* go thru symbols on chain*/
		sx2 = (char **)*sx2;             /*first entry on this chain*/
		while(1) {
			if(((struct symtab *)sx2)->vl1)
				asgncomn(sx2);  /*assign a common address*/
			else
				asgnext(sx2);   /*match to a global*/
			p = (char *)sx2;
			if(p == *sx1)       /*end of chain*/
				break;
			sx2 = (char **)((struct symtab *)sx2)->tlnk; /*next entry in chain*/
		}
	}
}

/* print a symbol name for an error message*/
prtsym(ap)
char *ap;
{
	register i;
	register char *p;

	p = ap;
	for(i = SYNAMLEN; --i != -1; ) {	/* 2 may 83 */
		if(*p)
			putchar(*p++);
		else
			break;
	}
	putchar('\n');
}

/* output symbol table to file*/
osymt()
{
	register struct symtab *p;
	register int cnt;

	stlen = 0;
	cnt = 0;
	if(sflag)       /*no symbol table desired*/
		return;

/* now output the symbols deleting externals*/

	for(p = (struct symtab *)bmte; p < (struct symtab *)lmte; p++) {
		if(p->flags&SYXR)	/*external symbol*/
			continue;
		if((p->flags&SYGL)==0 && (p->name[0]=='L' || Xflag==0))
			continue;
		osyme(p);
		cnt++;
	}
}

/* output symbols in a form to be read by a debugger*/
/* call with pointer to symbol table entry*/
osyme(aosypt)
struct symtab *aosypt;
{
	register struct symtab *osypt;
	register char *p1;
	register int i;

	osypt = aosypt;					/*pointer to symbol table entry*/
	stlen += OSTSIZE;				/*one more symbol out*/

/*output symbol to loader file*/
	p1 = &(osypt->name[0]);
	for(i = SYNAMLEN; --i != -1; )		/*output symbol name*/
		putc(*p1++,&obuf);

	lputw(&osypt->flags,&obuf);		/*output symbol flags*/
	lputl(&osypt->vl1,&obuf);		/*output symbol value*/
}

