/********************************************************/
/*							*/
/*	Usual filename:  SIDFUN.C			*/
/*	Remarks:  Functions specific to SID68K		*/
/*	Author:  Timothy M. Benson			*/
/*	Control:  19 MAY 83   17:36   (TMB)		*/
/*							*/
/********************************************************/

#include "lgcdef.h"
#include "cputype.h"
#include "siddef.h"
#include "sidinc.h"
#include "stdio.h"
#include "bdosfunc.h"
#include "disas.h"


/************************************************/
/*  Load and initialize symbol table, returning */
/*  int sized index to last valid symbol aut	*/
/*  negative error code.			*/
/************************************************/

simz(fnamp,hwer)
char *fnamp; /* file path pointer */
long hwer;
{
	extern struct lmhedr *caput;
	extern int nomo;
	U32 rano();	/* Returns second argument incremented by one */
	struct asymbl *icon;
	int goods;	/* # symbol bytes in first symbol record */
	int i;
	int irate;	/* Zero iff no input errors */
	int junk;	/* # bytes preceding symbols in first symbol record */
	register long kount;	/* Scratch loop counter */
	char *oint;	/* Scratch byte pointer */
	U32 randy;	/* Current random record number */
	int zulu;	/* Index to last symbol in current table */
	int relocate;	/* Logical -- whether or not file is relocatable */
	int handl;
	struct hdr buf;

	handl = trap(OPEN,fnamp);
	trap(READ,handl,((long) sizeof(struct hdr)),&buf);
	
	caput->tceps = hwer;
	caput->dceps = caput->tceps;
	caput->dceps += buf.seglen[0];
	caput->bceps = caput->dceps;
	caput->bceps += buf.seglen[1];
	randy = 28;	/* # bytes in contiguous header */
	If NOT(buf.seglen[3]) then BEGIN
		stout("No symbols\n");
/**temp** Need to allot space for added symbols */
/**temp** Need to deallocate extra space */
		nomo = -1;
		return(-1);
	END
	randy += buf.seglen[0] + buf.seglen[1];
		/* I.e., compute # bytes preceding symbols */
	trap(LSEEK,randy,handl,0);
	oint = caput->sump;
	icon = oint;	/* Save addr of symbol table. */

/**temp** May want to compute end of symbol table here	*/
/**temp**	and/or deallocate unused storage	*/

	trap(READ,handl,buf.seglen[3],oint);

/**temp** When symbol table allocated dynamically, make */
/**temp**	sure zulu still reflects subscript of	*/
/**temp**	last symbol at this point in program	*/

	zulu = buf.seglen[3] / sizeof(struct asymbl);
	for(i = 0; i <= zulu; i++)
		if (icon[i].symtyp & 0x0700)
			icon[i].symval += caput->tceps;

	return(zulu);
}

deluge(tabula,zulu)
struct asymbl tabula[];
register int zulu;
{
	register int i;
	register int j;
	register char litt;
	register int reply;
	U16	simbl;

	for(i = 0, reply = 2; i LE zulu and reply; i++) BEGIN
	    putchar('\n');
	    puthexw(i);
	    putchar('(');
	    If (simbl = tabula[i].symtyp) IS TREL then putchar('T');
		else If simbl IS DREL then putchar('D');
		else If simbl IS BREL then putchar('B');
		else putchar('A');	    
	    stout(")(");
	    If simbl IS GONE then putchar('H');
	    otherwise putchar('V');
	    stout("): ");
	    puthexl(tabula[i].symval);
	    stout(" = ");
/**temp** Call to kobold in next line may need parameters */
	    If simbl IS TLONG then kobold();
	    otherwise for(j = 0; j LT 8; j++)
		If litt = tabula[i].namae[j] then putchar(litt);
		else putchar(' ');
	    If reply EQ 2 then reply = 1;
	    otherwise If NOT (i % 10) then reply = pause();
	END
	putchar('\n');
}

kobold()
{
/* Will handle printing long symbols here; for now print message */
	stout("** Long COBOL-style symbol **");
}

pause()
{
	register char mor;

	stout("\n    Continue listing? (y/n)");
	mor = getchar();
	mor = toupper(mor);
	putchar('\n');
	return(mor NE 'N');
}

/****************************************************************/
/* For a given numerical value, find and print corresponding	*/
/* symbols in indicated table, with certain options.  Return	*/
/* int number of symbols found.					*/
/****************************************************************/

spell(value,table,scope,class,orient)
U32 value;
struct asymbl table[];
int scope;	/* If zero, then find all; otherwise find first. */
char class;	/* 'm' implies only want segment references. */
char orient;	/* 'h' or 'H' horizontal, anything else vertical: */
		/* If 'H' then prefix '.'; if 'h' then append ':'.*/
{
	extern int omega;
	int hmany;	/* Counter for # of symbols with given value */
	register int i;
	char it;	/* Hold char while deciding what to do. */
	register int j;
	register U16 simbol;	/* Hold symtyp here for inspection. */

	hmany = 0;	/* Alcyon compiler does not allow this	*/
			/* to be initialized in declaration:	*/
			/*	I protest!			*/
	for(i = 0; i LE omega; i++) BEGIN
	    If table[i].symval NE value then IGNORE;
	    simbol = table[i].symtyp;
	    If class EQ 'm' and NOT (simbol IS SEGREF)
			then IGNORE;
	    /* I.e. ignore e.g. stack references */
	    If simbol IS GONE then IGNORE;
		/* I.e. ignore hidden symbol */
/* Next line is dummy call to routine to handle long symbols */
	    If simbol IS TLONG then roam();
	    If orient EQ 'H' then putchar('.');
	    for(j = 0; j LT 8 and (it = table[i].namae[j]); j++)
		putchar(it);
	    If orient NE 'H' then putchar(':');
	    If orient EQ 'H' or orient EQ 'h' then putchar(' ');
	    otherwise putchar('\n');
	    hmany++;
	    If scope then break;
	END
	If hmany and orient EQ 'h' then putchar('\n');
	return(hmany);
}

roam()
{
/* dummy routine:  will later handle symbols longer than 8 chars */
}

/************************************************/
/*  For given string of given length find first	*/
/*  corresponding symbol table entry, updating	*/
/*  value and putting subscript at *whence.	*/
/*  Return int 1 if found, 0 if not found,	*/
/*  -1 if the bizarre happens, and -2 if an	*/
/*  attempt is made to utilize a feature not	*/
/*  yet implemented.				*/
/************************************************/

indica(leqth,logos,tesoro,phylum,value,whence)
int leqth;
char logos[];	/* String containing name */
struct asymbl tesoro[];		/* Short symbol table */
char phylum;	/* Type of symbol wanted */
U32 *value;	/* Place to stick value if and when found */
int *whence;	/* Place to stick subscript to symbol table */
{
	extern	int	omega;
	register int	i;	/* To sweep symbol table */
	register int	j;	/* To sweep string */
	register short	match;	/* 1 iff strings equivalent */
	register char	nxch;	/* Next char in logos */
	U16	symbol;		/* Type of last symbol considered */

    for(i = 0; i LE omega; i++) BEGIN
	symbol = tesoro[i].symtyp;
	switch(phylum) BLOCK
	case 'M':	/* Address value wanted */
	    If NOT (symbol IS SEGREF) then IGNORE;
	    break;
	case 'A':	/* Nonaddress numerical value wanted */
	    If symbol IS SEGREF then IGNORE;
	    break;
	case 'B':
	    break;	/* Accept any kind of symbol */
	default:
	    return(-1);		/* This shouldn't happen */
	UNBLOCK
	If symbol IS GONE then IGNORE;
/**temp** Call in next statement will require parameters.	*/
/**temp**	For now just returns (int) -2.			*/
	If symbol IS TLONG then return(trek());
	for(j = 0, match = 1; j LT 8 and match; j++) BLOCK
	    If j LT leqth then nxch = logos[j];
		otherwise nxch = '\0';
	    If nxch NE toupper(tesoro[i].namae[j]) then match = 0;
	UNBLOCK
	If match then BLOCK
	    *whence = i;
	    *value = tesoro[i].symval;
	    return(1);
	UNBLOCK
    END
    return(0);
}

trek()
{
/* dummy routine:  will later handle symbols longer than 8 chars */

return(-2);

}

/****************************************/
/*  K command:  Play with symbol table	*/
/****************************************/

koax(cx, bpptr)
char *cx;
struct basepage * bpptr;	/* For display purposes only */
{
	extern	struct	lmhedr	*caput;
	extern	int	omega;
	extern	int	SIDSTRT();
	struct	asymbl	*galaxy;
	int	seqno;	/* Subscript to symbol table */
	long	spot;	/* Symbol value input */
	char	task;
	char	uppr;	/* For entering new name */

	galaxy = caput->sump;
	If nomore(cx) then BEGIN
	    stout("SID begins at ");
	    puthexl(SIDSTRT);
	    stout("H with basepage at ");
	    puthexl(bpptr);
	    putchar('H');
	    putchar('\n');
	    If omega LT 0 then BLOCK
		stout("No symbols");
		If caput then begin
		    stout("; file header at:  ");
		    puthexl(caput);
		end
		putchar('\n');
	    UNBLOCK
	    else {stout("Symbol table at:  ");
		  puthexl(galaxy);
		  putchar('\n');
		 }
	    return;
	END
	deblank(&cx);
	task = *++cx;
	switch(task) BEGIN
	case 'A':
		/* Add a symbol; e.g. KAname,value,type		*/
		/* where name is converted to upper case and 	*/
		/* comma after it is obligatory, as is value.	*/
	    If nomore(cx) then BLOCK bad(); return; UNBLOCK
	    otherwise BLOCK
		If omega GE HMSYMS then begin
		    stout("\nSymbol table full\n");
		    return;
		end
		deblank(&cx);
		uppr = *++cx;
		If uppr EQ ',' then begin bad(); return; end		
		++omega;
		for(seqno = 0; seqno LT 8; seqno++) begin
		    (galaxy+omega)->namae[seqno] = uppr;
		    If *++cx NE ',' and uppr then uppr = *cx;
		    else uppr = '\0';
		end
		cx--;
		If NOT (getsep(&cx) and gethex(&cx,&spot)) then begin
		    omega--;
		    bad();
		    return;
		end
		(galaxy+omega)->symval = spot;
		If getsep(&cx) and gethex(&cx,&spot) then
		    seqno = (int)spot;
		else seqno = 0xA700;	/* Default symbol type */
		If NOT nomore(cx) then begin
		    omega--;
		    bad();
		    return;
		end
		(galaxy+omega)->symtyp = seqno;
	    UNBLOCK
	    break;
	case 'H':	/* Hide symbols */
	/* KH		hide symbol most recently sought by name*/
	/* KHvalue	hide first symbol with given value	*/
	/* KH*value	hide symbol with sequence number equal	*/
	/*		to given value, if in range		*/
	    seqno = findsn(cx,omega,galaxy);
	    If seqno LT 0 then begin bad(); return; end
	    otherwise (galaxy+seqno)->symtyp |= GONE;
	    break;
	case 'R':	/* Recover hidden symbols */
	/* KR		recover all hidden symbols		*/
	/* KRvalue	recover first symbol with given value	*/
	/* KR*value	recover symbol with sequence number	*/
	/*		equal to given value, if in range	*/
	    If nomore(cx) then
		for(seqno = 0; seqno LE omega; seqno++)
		    (galaxy+seqno)->symtyp ANDWITH ~GONE;
	    otherwise BLOCK
		seqno = findsn(cx,omega,galaxy);
		If seqno LT 0 then begin bad(); return; end
		else (galaxy+seqno)->symtyp ANDWITH ~GONE;
	    UNBLOCK
	    break;
	default:
	    bad();
	    return;
	    break;
	END
	putchar('\n');
}

/************************************************/
/* Find serial number of symbol entry, parsing	*/
/*	rest of command line			*/
/************************************************/

findsn(spear,zedd,arcade)
char *spear;	/* Scanner for command line */
int zedd;	/* Highest symbol table subscript */
struct asymbl *arcade;		/* Addr of symbol table */
{
	extern int nomo;	/* Last entry sought by name */
	int ix;		/* To sweep symbol table */
	int script;	/* Int subscript to be returned */
	long werth;	/* Numerical value of symbol */

	script = -1;	/* Preset to illegal value */
	If nomore(spear) then script = nomo;
	otherwise BLOCK
	    deblank(&spear);
	    If *(spear+1) EQ '*' then begin
		++spear;
		If gethex(&spear,&werth) and nomore(spear) then
		    script = (int) werth;
	    end
	    else If gethex(&spear,&werth) and nomore(spear)
	    then for(ix = 0; ix LE zedd and script LT 0; ix++)
		If (arcade+ix)->symval EQ werth then script = ix;
	UNBLOCK
	If script GT zedd then script = -1;
	return(script);
}

passpt(pcx)
char *pcx;
{
	extern	U16	pkawnt[HMPPTS];
	extern	U16	*plocus[HMPPTS];
	extern	U16	ancien[HMPPTS];
	extern	int	minus;
	extern	int	omega;
	extern	int	scope;
	extern	struct	lmhedr	*caput;
	int	jp;
	int	reply;	/* Operator's response */
	int	plain;	/* plain iff no tail */
	char	*nupt;	/* Value of new pass point */
			/* N.b.:  "char" required so bitwise "&" */
			/*    will work properly.		 */
	long	cntdn;	/* New pass count (initially long) */

	cntdn = 1;	/* Set to default pass count */
	If NOT (plain = nomore(pcx)) then BEGIN
	    If NOT gethex(&pcx,&nupt) then goto chide;
		/* Warning:  The following bitwise "&" statement */
		/*   requires nupt to be declared "char" pointer.*/
	    If nupt & 1 then BLOCK
		stout("\nNo change--Address must be even!\n");
		return;
	    UNBLOCK
	    If getsep(&pcx) then If NOT gethex(&pcx,&cntdn)
			or minus then goto chide;
	    If NOT nomore(pcx) then goto chide;
	END
	If NOT cntdn then goto chide;
	If minus then BEGIN
	    If plain then zappas();
	    else BLOCK
		for (jp = 0; jp LT HMPPTS; jp++)
		  If pkawnt[jp] and plocus[jp] EQ nupt then begin
		    pkawnt[jp] = 0;
		    minus = 0;
		  end
		If minus then goto chide;
	    UNBLOCK
	END
	otherwise BEGIN
	    If plain then BLOCK
		for(jp=0,reply=1;jp LT HMPPTS and reply;jp++) begin
		    If pkawnt[jp] then {
			If ++minus GT 16 and jp LT HMPPTS then BEGIN
			    reply = pause();
			    minus = 0;
			END
			If reply then BEGIN
			    putchar('\n');
			    puthexw(pkawnt[jp]);
			    stout("  ");
			    puthexl(plocus[jp]);
			    stout("  ");
			    If omega GE 0 then
			      spell((U32) plocus[jp],caput->sump
				    ,scope,'m','H');
			END
		    }
		end
		putchar('\n');
	    UNBLOCK
	    else BLOCK
		for (jp = 0; jp LT HMPPTS; jp++)
		  If pkawnt[jp] and plocus[jp] EQ nupt then begin
		    If pkawnt[jp] EQ cntdn then stout("\nAlready set\n"); 
		    otherwise pkawnt[jp] = cntdn;
		    return;
		  end
		minus = 1;
		for (jp = 0; jp LT HMPPTS; jp++)
		  If NOT pkawnt[jp] then begin
		      pkawnt[jp] = (U16) cntdn;
		      plocus[jp] = nupt;
		      jp = HMPPTS;
		      minus = 0;	
		  end
		If minus then begin
		    stout("\nToo many pass points--limit is:  ");
		    SAYMAX
		end
	    UNBLOCK
	END
	return;
chide:
	bad();
}

qotbyt(nnnn)
long nnnn;
{
	If nnnn LT 0x20 or nnnn GT 0x7E then return(0);
	putchar('\'');
	trap(CONOUT,(int) nnnn);
	putchar('\'');
	return(1);
}

vecina(cxp,sought)
char **cxp;
char sought;
{
/* Check if next char in command is a specified char, advancing */
/*		pointer if it is.				*/
	++*cxp;
	If **cxp EQ sought then return(1);
	--*cxp;
	return(0);
}

zappas()
{
	extern	U16	pkawnt[HMPPTS];
	int	jz;

	for (jz = 0; jz LT HMPPTS; jz++) pkawnt[jz] = 0;	
}
