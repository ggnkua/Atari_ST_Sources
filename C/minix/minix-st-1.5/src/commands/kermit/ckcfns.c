char *fnsv = "C-Kermit functions, 4E(053) 14 Sep 87";

/*  C K C F N S  --  System-independent Kermit protocol support functions.  */

/*  ...Part 1 (others moved to ckcfn2 to make this module small enough) */

/*
 4E includes support for Data General systems from Phil Julian of SAS 
 Institute, and Megamax native Macintosh C compiler support from
 Jim Noble of Planning Research Corporation.
*/ 
/*
 Author: Frank da Cruz (SY.FDC@CU20B),
 Columbia University Center for Computing Activities, January 1985.
 Copyright (C) 1985, Trustees of Columbia University in the City of New York.
 Permission is granted to any individual or institution to use, copy, or
 redistribute this software so long as it is not sold for profit, provided this
 copyright notice is retained. 
*/
/*
 System-dependent primitives defined in:

   ck?tio.c -- terminal i/o
   cx?fio.c -- file i/o, directory structure
*/
#include "ckcsym.h"			/* Need this for Mac */
#include "ckcker.h"			/* Symbol definitions for Kermit */
#include "ckcdeb.h"			/* Debug formats, typedefs, etc. */

#ifndef NULL
#define NULL 0
#endif

/* Externals from ckcmai.c */
extern int spsiz, rpsiz, timint, rtimo, npad, ebq, ebqflg, rpt, rptq,
 rptflg, capas, keep;
extern int pktnum, prvpkt, sndtyp, bctr, bctu, fmask,
 size, osize, maxsize, spktl, nfils, stdouf, warn, timef, spsizf;
extern int parity, speed, turn, turnch, 
 delay, displa, pktlog, tralog, seslog, xflg, mypadn;
extern long filcnt, ffc, flci, flco, tlci, tlco, tfc, fsize;
extern int tsecs;
extern int deblog, hcflg, binary, savmod, fncnv, local, server, cxseen, czseen;
extern int rq, rqf, sq, wsize, urpsiz, rln;
extern int atcapr, atcapb, atcapu;
extern int lpcapr, lpcapb, lpcapu;
extern int swcapr, swcapb, swcapu;
extern CHAR padch, mypadc, eol, seol, ctlq, myctlq, sstate;
extern CHAR filnam[], sndpkt[], recpkt[], data[], srvcmd[], stchr, mystch;
extern char *cmarg, *cmarg2, *hlptxt, **cmlist;
extern CHAR *srvptr;
extern char *rdatap;
long zchki();
char *strcpy();
CHAR *rpar();

/* Variables local to this module */

static char *memptr;			/* Pointer for memory strings */

static char cmdstr[100];		/* Unix system command string */

static int  sndsrc;			/* Flag for where to send from: */
					/* -1: name in cmdata */
					/*  0: stdin          */
					/* >0: list in cmlist */

static int  memstr,			/* Flag for input from memory string */
    first;				/* Flag for first char from input */
static CHAR t,				/* Current character */
    next;				/* Next character */
#ifdef datageneral
extern int quiet;
#endif

/*  E N C S T R  --  Encode a string from memory. */

/*  Call this instead of getpkt() if source is a string, rather than a file. */

encstr(s) char* s; {
    int m; char *p;

    m = memstr; p = memptr;		/* Save these. */

    memptr = s;				/* Point to the string. */
    memstr = 1;				/* Flag memory string as source. */
    first = 1;				/* Initialize character lookahead. */
    getpkt(spsiz-bctu-3);		/* Fill a packet from the string. */
    memstr = m;				/* Restore memory string flag */
    memptr = p;				/* and pointer */
    first = 1;				/* Put this back as we found it. */
}

/* E N C O D E - Kermit packet encoding procedure */

encode(a) CHAR a; {			/* The current character */
    int a7;				/* Low order 7 bits of character */
    int b8;				/* 8th bit of character */

    if (rptflg)	{   	    		/* Repeat processing? */
        if (a == next && (first == 0)) { /* Got a run... */
	    if (++rpt < 94)		/* Below max, just count */
                return;
	    else if (rpt == 94) {	/* Reached max, must dump */
                data[size++] = rptq;
                data[size++] = tochar(rpt);
                rpt = 0;
	    }
        } else if (rpt == 1) {		/* Run broken, only 2? */
            rpt = 0;			/* Yes, reset repeat flag & count. */
	    encode(a);			/* Do the character twice. */
	    if (size <= maxsize) osize = size;
	    rpt = 0;
	    encode(a);
	    return;
	} else if (rpt > 1) {		/* More than two */
            data[size++] = rptq;	/* Insert the repeat prefix */
            data[size++] = tochar(++rpt); /* and count. */
            rpt = 0;			/* Reset repeat counter. */
        }
    }
    a7 = a & 0177;			/* Isolate ASCII part */
    b8 = a & 0200;			/* and 8th (parity) bit. */

    if (ebqflg && b8) {			/* Do 8th bit prefix if necessary. */
        data[size++] = ebq;
        a = a7;
    }
    if ((a7 < SP) || (a7==DEL))	{	/* Do control prefix if necessary */
        data[size++] = myctlq;
	a = ctl(a);
    }
    if (a7 == myctlq)			/* Prefix the control prefix */
        data[size++] = myctlq;

    if ((rptflg) && (a7 == rptq))	/* If it's the repeat prefix, */
        data[size++] = myctlq;		/* quote it if doing repeat counts. */

    if ((ebqflg) && (a7 == ebq))	/* Prefix the 8th bit prefix */
        data[size++] = myctlq;		/* if doing 8th-bit prefixes */

    data[size++] = a;			/* Finally, insert the character */
    data[size] = '\0';			/* itself, and mark the end. */
}

/* D E C O D E  --  Kermit packet decoding procedure */

/* Call with string to be decoded and an output function. */
/* Returns 0 on success, -1 on failure (e.g. disk full).  */

decode(buf,fn) CHAR *buf; int (*fn)(); {
    unsigned int a, a7, b8;		/* Low order 7 bits, and the 8th bit */

    rpt = 0;				/* Initialize repeat count. */

    while ((a = *buf++) != '\0') {
	if (rptflg) {			/* Repeat processing? */
	    if (a == rptq) {		/* Yes, got a repeat prefix? */
		rpt = xunchar(*buf++);	/* Yes, get the repeat count, */
		a = *buf++;		/* and get the prefixed character. */
	    }
	}
	b8 = 0;				/* Check high order "8th" bit */
	if (ebqflg) {			/* 8th-bit prefixing? */
	    if (a == ebq) {		/* Yes, got an 8th-bit prefix? */
		b8 = 0200;		/* Yes, remember this, */
		a = *buf++;		/* and get the prefixed character. */
	    }
	}
	if (a == ctlq) {		/* If control prefix, */
	    a  = *buf++;		/* get its operand. */
	    a7 = a & 0177;		/* Only look at low 7 bits. */
	    if ((a7 >= 0100 && a7 <= 0137) || a7 == '?') /* Uncontrollify */
	    a = ctl(a);			/* if in control range. */
	}
	a |= b8;			/* OR in the 8th bit */
	if (rpt == 0) rpt = 1;		/* If no repeats, then one */
#ifdef NLCHAR
	if (!binary) {			/* If in text mode, */
	    if (a == CR) continue;	/* discard carriage returns, */
    	    if (a == LF) a = NLCHAR; 	/* convert LF to system's newline. */
    	}
#endif
	for (; rpt > 0; rpt--) {	/* Output the char RPT times */
	    if ((*fn)(a) < 0) return(-1); /* Send it to the output function. */
	    ffc++, tfc++;		/* Count the character */
	}
    }
    return(0);
}


/*  Output functions passed to 'decode':  */

putsrv(c) char c; { 	/*  Put character in server command buffer  */
    *srvptr++ = c;
    *srvptr = '\0';	/* Make sure buffer is null-terminated */
    return(0);
}

puttrm(c) char c; {     /*  Output character to console.  */
    conoc(c);
    return(0);
}

putfil(c) char c; {			/*  Output char to file. */
    if (zchout(ZOFILE, c & fmask) < 0) {
	czseen = 1;   			/* If write error... */
	debug(F101,"putfil zchout write error, setting czseen","",1);
	return(-1);
    }
    return(0);
}

/*  G E T P K T -- Fill a packet data field  */

/*
 Gets characters from the current source -- file or memory string.
 Encodes the data into the packet, filling the packet optimally.
 Set first = 1 when calling for the first time on a given input stream
 (string or file).

 Uses global variables:
 t     -- current character.
 first -- flag: 1 to start up, 0 for input in progress, -1 for EOF.
 next  -- next character.
 data  -- the packet data buffer.
 size  -- number of characters in the data buffer.

Returns the size as value of the function, and also sets global size,
and fills (and null-terminates) the global data array.  Returns 0 upon eof.
*/

getpkt(bufmax) int bufmax; {		/* Fill one packet buffer */
    int i, x;				/* Loop index. */
	
    static char leftover[6] = { '\0', '\0', '\0', '\0', '\0', '\0' };

    if (first == 1) {		/* If first time thru...  */
	first = 0;		/* remember, */
	*leftover = '\0';   	/* discard any interrupted leftovers, */
	x = getchx(&t);		/* get first character of file into t, */
	if (x == 0) {	    	/* watching out for null file, */
	    first = -1;
	    return(size = 0);	
	}
    } else if ((first == -1) && (*leftover == '\0')) /* EOF from last time? */
        return(size = 0);

    /* Do any leftovers */

    for (size = 0; (data[size] = leftover[size]) != '\0'; size++)
    	;
    *leftover = '\0';
    if (first == -1) return(size);	/* Handle final leftovers leftovers */

    /* Now fill up the rest of the packet. */

    rpt = 0;				/* Clear out any old repeat count. */
    while (first > -1) {		/* Until EOF... */
	x = getchx(&next);		/* Get next character for lookahead. */
	if (x == 0) first = -1;		/* Flag eof for next time. */
	osize = size;			/* Remember current position. */
        encode(t);			/* Encode the current character. */
	t = next;			/* Next is now current. */

	if (size == bufmax) { 		/* If the packet is exactly full, */
/**	    debug(F101,"getpkt exact fit","",size); **/
            return(size);		/* ... return. */
	}
	if (size > bufmax) {		/* If too big, save some for next. */
	    for (i = 0; (leftover[i] = data[osize+i]) != '\0'; i++)
	    	;
/**	    debug(F111,"getpkt leftover",leftover,size); **/
/**	    debug(F101," osize","",osize);               **/
	    size = osize;		/* Return truncated packet. */
	    data[size] = '\0';
	    return(size);
	}
    }					/* Otherwise, keep filling. */
    debug(F111,"getpkt eof/eot",data,size); /* Fell thru before packet full, */
    return(size);		   /* return partially filled last packet. */
}

/*  G E T C H X  --  Get the next character from file (or pipe). */
 
/*
 On systems like Unix, the Macintosh, etc, that use a single character
 (NLCHAR, defined in ckcdeb.h) to separate lines in text files, and
 when in text/ascii mode (binary == 0), this function maps the newline
 character to CRLF.  If NLCHAR is not defined, then this mapping is
 not done, even in text mode.

 Returns 1 on success with ch set to the character, or 0 on failure (EOF)
*/
getchx(ch) char *ch; {			/* Get next character */
    int x; CHAR a;			/* The character to return. */
    static int b = 0;			/* A character to remember. */
    
    if (b > 0) {			/* Do we have a LF saved? */
	b = 0;				/* Yes, return that. */
	*ch = LF;
	return(1);
    }

    if (memstr)				/* Try to get the next character */
    	x = ((a = *memptr++) == '\0');	/* from the appropriate source, */
    else				/* memory or the current file. */
    	x = (zchin(ZIFILE,&a) == -1);

    if (x)
    	return(0);			/* No more, return 0 for EOF. */
    else {				/* Otherwise, read the next char. */
	ffc++, tfc++;			/* Count it. */
	a &= fmask;			/* Bytesize mask. */
#ifdef NLCHAR
	if (!binary && (a == NLCHAR)) {	/* If nl and we must do nl-CRLF */
	    b = 1;			/* mapping, remember a linefeed, */
	    *ch = CR;			/* and return a carriage return. */
	    return(1);
	} else {
	    *ch = a;			/*  General case, return the char. */
	    return(1);	
        }
#else
        *ch = a;
        return(1);	
#endif
    }
}


/*  C A N N E D  --  Check if current file transfer cancelled */

canned(buf) char *buf; {
    if (*buf == 'X') cxseen = 1;
    if (*buf == 'Z') czseen = 1;
    debug(F101,"canned: cxseen","",cxseen);
    debug(F101," czseen","",czseen);
    return((czseen || cxseen) ? 1 : 0);
}

/*  R E S E T C  --  Reset per-transaction character counters */
resetc() {
    tfc = tlci = tlco = 0;	/* Total file chars, line chars in & out */
}


/*  T I N I T  --  Initialize a transaction  */

tinit() {
    xflg = 0;				/* Reset x-packet flag */
    memstr = 0;				/* Reset memory-string flag */
    memptr = NULL;			/*  and pointer */
    bctu = 1;				/* Reset block check type to 1 */
    ebq = ebqflg = 0;			/* Reset 8th-bit quoting stuff */
    if (savmod) {			/* If binary file mode was saved, */
    	binary = 1;			/*  restore it, */
	savmod = 0;			/*  unsave it. */
    }
    prvpkt = -1;			/* Reset packet number */
    pktnum = 0;
    cxseen = czseen = 0;		/* Reset interrupt flags */
    *filnam = '\0';			/* Clear file name */
    *sndpkt = '\0';			/* Clear retransmission buffer */
    if (server) 			/* If acting as server, */
	timint = 30;			/* Use 30 second timeout, */
}


/*  R I N I T  --  Respond to S packet  */

rinit(d) char *d; {
    char *tp;
    ztime(&tp);
    tlog(F110,"Transaction begins",tp,0l); /* Make transaction log entry */
    filcnt = 0;				/* Init file counter */
    spar(d);
    ack1(rpar());
#ifdef datageneral
    if ((local) && (!quiet))            /* Only do this if local & not quiet */
        consta_mt();                    /* Start the asynch read task */
#endif
}

/*  S I N I T  --  Make sure file exists, then send Send-Init packet */

sinit() {
    int x; char *tp;

    filcnt = 0;
    sndsrc = nfils;			/* Where to look for files to send */
    ztime(&tp);
    tlog(F110,"Transaction begins",tp,0l); /* Make transaction log entry */
    debug(F101,"sinit: sndsrc","",sndsrc);
    if (sndsrc < 0) {			/* Must expand from 'send' command */
	nfils = zxpand(cmarg);		/* Look up literal name. */
	if (nfils < 0) {
	    screen(SCR_EM,0,0l,"Too many files");
	    return(0);
        } else if (nfils == 0) {	/* If none found, */
	    char xname[100];		/* convert the name. */
	    zrtol(cmarg,xname);
	    nfils = zxpand(xname); 	/* Look it up again. */
	}
	if (nfils < 1) {		/* If no match, report error. */
	    if (server) 
	    	errpkt("File not found");
	    else
		screen(SCR_EM,0,0l,"File not found");
	    return(0);
	}
	x = gnfile();			/* Position to first file. */
	if (x < 1) {
	    if (!server) 
	    	screen(SCR_EM,0,0l,"No readable file to send");
            else
	    	errpkt("No readable file to send");
	    return(0);
    	} 
    } else if (sndsrc > 0) {		/* Command line arglist -- */
	x = gnfile();			/* Get the first file from it. */
	if (x < 1) return(0);		/* (if any) */
    } else if (sndsrc == 0) {		/* stdin or memory always exist... */
	if ((cmarg2 != NULL) && (*cmarg2)) {
	    strcpy(filnam,cmarg2);	/* If F packet, "as" name is used */
	    cmarg2 = "";		/* if provided, */
        } else				/* otherwise */
	    strcpy(filnam,"stdin");	/* just use this. */
    }
    debug(F101,"sinit: nfils","",nfils);
    debug(F110," filnam",filnam,0);
    debug(F110," cmdstr",cmdstr,0);
    ttflui();				/* Flush input buffer. */
    if (!local && !server) sleep(delay);
#ifdef datageneral
    if ((local) && (!quiet))            /* Only do this if local & not quiet */
        consta_mt();                    /* Start the asynch read task */
#endif
    sipkt('S');				/* Send the Send-Init packet. */
    return(1);
}

sipkt(c) char c; {			/* Send S or I packet. */
    CHAR *rp;
    ttflui();				/* Flush pending input. */
    rp = rpar();			/* Get parameters. */
    spack(c,pktnum,strlen(rp),rp);
}

/*  R C V F I L -- Receive a file  */

rcvfil() {
    int x;
    ffc = flci = flco = 0;		/* Init per-file counters */
    srvptr = srvcmd;			/* Decode file name from packet. */
    decode(rdatap,putsrv);
    if (*srvcmd == '\0')		/* Watch out for null F packet. */
    	strcpy(srvcmd,"NONAME");
    screen(SCR_FN,0,0l,srvcmd);		/* Put it on screen */
    tlog(F110,"Receiving",srvcmd,0l);	/* Transaction log entry */
    if (cmarg2 != NULL) {               /* Check for alternate name */
        if (*cmarg2 != '\0') {
            strcpy(srvcmd,cmarg2);	/* Got one, use it. */
	    *cmarg2 = '\0';
        }
    }
    x = openo(srvcmd,filnam);		/* Try to open it */
    if (x) {
	tlog(F110," as",filnam,0l);
	screen(SCR_AN,0,0l,filnam);
	intmsg(++filcnt);
#ifdef datageneral
/* Need to turn on multi-tasking console interrupt task here, since multiple */
/* files may be received. */
        if ((local) && (!quiet))        /* Only do this if local & not quiet */
            consta_mt();                /* Start the asynch read task */
#endif
    } else {
        tlog(F110,"Failure to open",filnam,0l);
	screen(SCR_EM,0,0l,"Can't open file");
    }
    return(x);				/* Pass on return code from openo */
}

/*  R E O F  --  Receive End Of File  */

reof() {
    int x;
    if (cxseen == 0) cxseen = (*rdatap == 'D');	/* Got discard directive? */
    x = clsof(cxseen | czseen);
    if (cxseen || czseen) {
	tlog(F100," *** Discarding","",0l);
	cxseen = 0;
    } else
	fstats();
    return(x);
}


/*  R E O T  --  Receive End Of Transaction  */

reot() {
    cxseen = czseen = 0;		/* Reset interruption flags */
    tstats();
}

/*  S F I L E -- Send File header or teXt header packet  */

/*  Call with x nonzero for X packet, zero for F packet  */
/*  Returns 1 on success, 0 on failure                   */

sfile(x) int x; {
    char pktnam[100];			/* Local copy of name */
    char *s;

    if (x == 0) {			/* F-Packet setup */

    	if (*cmarg2 != '\0') {		/* If we have a send-as name, */
	    strcpy(pktnam,cmarg2);	/* copy it literally, */
	    cmarg2 = "";		/* and blank it out for next time. */
    	} else {			/* Otherwise use actual file name: */
	    if (fncnv) {		/* If converting names, */
	    	zltor(filnam,pktnam);	/* convert it to common form, */
	    } else {			/* otherwise, */
	    	strcpy(pktnam,filnam);	/* copy it literally. */
            }
    	}
    	debug(F110,"sfile",filnam,0);	/* Log debugging info */
    	debug(F110," pktnam",pktnam,0);
    	if (openi(filnam) == 0) 	/* Try to open the file */
	    return(0); 		
    	s = pktnam;			/* Name for packet data field */

    } else {				/* X-packet setup */

    	debug(F110,"sxpack",cmdstr,0);	/* Log debugging info */
    	s = cmdstr;			/* Name for data field */
    }

    flci = flco = ffc = 0;		/* Init counters, etc. */
    encstr(s);				/* Encode the name into data[]. */
    nxtpkt(&pktnum);			/* Increment the packet number */
    spack(x ? 'X' : 'F', pktnum, size, data); /* Send the F or X packet */

    if (x == 0) {			/* Display for F packet */
    	if (displa) {			/* Screen */
	    screen(SCR_FN,'F',(long)pktnum,filnam);
	    screen(SCR_AN,0,0l,pktnam);
	    screen(SCR_FS,0,(long)fsize,"");
    	}
    	tlog(F110,"Sending",filnam,0l);	/* Transaction log entry */
    	tlog(F110," as",pktnam,0l);

    } else {				/* Display for X-packet */

    	screen(SCR_XD,'X',(long)pktnum,cmdstr);	/* Screen */
    	tlog(F110,"Sending from:",cmdstr,0l);	/* Transaction log */
    }
    intmsg(++filcnt);			/* Count file, give interrupt msg */
    first = 1;				/* Init file character lookahead. */
    return(1);
}

/*  S D A T A -- Send a data packet */

/*  Return -1 if no data to send, else send packet and return length  */

sdata() {
    int len;
    if (cxseen || czseen) return(-1);	/* If interrupted, done. */
    if ((len = getpkt(spsiz-bctu-3)) == 0) /* Done if no data. */
    	return(-1);
    nxtpkt(&pktnum);			/* Increment the packet number */
    spack('D',pktnum,len,data);		/* Send the packet */
    return(len);
}


/*  S E O F -- Send an End-Of-File packet */

/*  Call with a string pointer to character to put in the data field, */
/*  or else a null pointer or "" for no data.  */

seof(s) char *s; {
    nxtpkt(&pktnum);			/* Increment the packet number */
    if ((s != NULL) && (*s != '\0')) {
	spack('Z',pktnum,1,s);
	tlog(F100," *** interrupted, sending discard request","",0l);
    } else {
	spack('Z',pktnum,0,"");
	fstats();
    }
}


/*  S E O T -- Send an End-Of-Transaction packet */

seot() {
    nxtpkt(&pktnum);			/* Increment the packet number */
    spack('B',pktnum,0,"");		/* Send the EOT packet */
    cxseen = czseen = 0;		/* Reset interruption flags */
    tstats();				/* Log timing info */
}

/*   R P A R -- Fill the data array with my send-init parameters  */

CHAR *
rpar() {
    if (rpsiz > 94)
      data[1] = tochar(94);
    else
      data[1] = tochar(rpsiz);		/* Biggest packet I can receive */
    data[2] = tochar(rtimo);		/* When I want to be timed out */
    data[3] = tochar(mypadn);		/* How much padding I need (none) */
    data[4] = ctl(mypadc);		/* Padding character I want */
    data[5] = tochar(eol);		/* End-Of-Line character I want */
    data[6] = '#';			/* Control-Quote character I send */
    switch (rqf) {			/* 8th-bit prefix */
	case -1:
	case  1: if (parity) ebq = sq = '&'; break;
	case  0:
	case  2: break;
    }
    data[7] = sq;
    data[8] = bctr + '0';		/* Block check type */
    if (rptflg)				/* Run length encoding */
    	data[9] = rptq;			/* If receiving, agree. */
    else
    	data[9] = '~'; 		

    data[10] = tochar((atcapr?atcapb:0) | (lpcapr?lpcapb:0) | (swcapr?swcapb:0));
    data[capas+1] = tochar(swcapr ? wsize : 0);	/* Window size */

    rpsiz = urpsiz;			/* Long packets ... */
    data[capas+2] = tochar(rpsiz / 95);	/* Long packet size, big part */
    data[capas+3] = tochar(rpsiz % 95);	/* Long packet size, little part */
    data[capas+4] = '\0';		/* Terminate the init string */
    if (deblog) {
	debug(F110,"rpar",data+1,0);
	rdebu(capas+2);    
    }
    return(data+1);			/* Return pointer to string. */
}

spar(s) char *s; {			/* Set parameters */
    int x, lpsiz;

    s--;				/* Line up with field numbers. */

debug(F101,"spar rln","",rln);

/* Limit on size of outbound packets */
    x = (rln >= 1) ? xunchar(s[1]) : 80;
    lpsiz = spsiz;			/* Remember what they SET. */
    if (spsizf) {			/* SET-command override? */
	if (x < spsiz) spsiz = x;	/* Ignore LEN unless smaller */
    } else {				/* otherwise */
	spsiz = (x < 10) ? 80 : x;	/* believe them if reasonable */
    }

/* Timeout on inbound packets */
    if (!timef) {			/* Only if not SET-cmd override */
	x = (rln >= 2) ? xunchar(s[2]) : 5;
	timint = (x < 0) ? 5 : x;
    }

/* Outbound Padding */
    npad = 0; padch = '\0';
    if (rln >= 3) {
	npad = xunchar(s[3]);
	if (rln >= 4) padch = ctl(s[4]); else padch = 0;
    }

/* Outbound Packet Terminator */
    seol = (rln >= 5) ? xunchar(s[5]) : '\r';
    if ((seol < 2) || (seol > 31)) seol = '\r';

/* Control prefix */
    x = (rln >= 6) ? s[6] : '#';
    myctlq = ((x > 32 && x < 63) || (x > 95 && x < 127)) ? x : '#';

/* 8th-bit prefix */
    rq = (rln >= 7) ? s[7] : 0;
    if (rq == 'Y') rqf = 1;
      else if ((rq > 32 && rq < 63) || (rq > 95 && rq < 127)) rqf = 2;
        else rqf = 0;
    switch (rqf) {
	case 0: ebqflg = 0; break;
	case 1: if (parity) { ebqflg = 1; ebq = '&'; } break;
	case 2: if (ebqflg = (ebq == sq || sq == 'Y')) ebq = rq;
    }

/* Block check */
    x = 1;
    if (rln >= 8) {
	x = s[8] - '0';
	if ((x < 1) || (x > 3)) x = 1;
    }
    bctr = x;

/* Repeat prefix */
    if (rln >= 9) {
	rptq = s[9]; 
	rptflg = ((rptq > 32 && rptq < 63) || (rptq > 95 && rptq < 127));
    } else rptflg = 0;

/* Capabilities */
    atcapu = lpcapu = swcapu = 0;
    if (rln >= 10) {
        x = xunchar(s[10]);
        atcapu = (x & atcapb) && atcapr;
	lpcapu = (x & lpcapb) && lpcapr;
	swcapu = (x & swcapb) && swcapb;
	for (capas = 10; (xunchar(s[capas]) & 1) && (rln >= capas); capas++) ;
    }

/* Long Packets */
    if (lpcapu) {
        if (rln > capas+2) {
	    x = xunchar(s[capas+2]) * 95 + xunchar(s[capas+3]);
	    if (spsizf) {		/* If overriding negotiations */
		spsiz = (x < lpsiz) ? x : lpsiz; /* do this, */
	    } else {			         /* otherwise */
		spsiz = (x > MAXSP) ? MAXSP : x; /* do this. */
	    }
	    if (spsiz < 10) spsiz = 80;	/* Be defensive... */
	}
    }

/* Sliding Windows */
    if (swcapu) {
        if (rln > capas+1) {
	    x = xunchar(s[capas+1]);
	    wsize = x > MAXWS ? MAXWS : x;
	}
	else wsize = 1;
    }
    if (deblog) sdebu(rln);		/* Record parameters in debug log */
}

/*  G N F I L E  --  Get the next file name from a file group.  */

/*  Returns 1 if there's a next file, 0 otherwise  */

gnfile() {
    int x; long y;
#ifdef datageneral
    int dgfiles = 0;     		/* Number of files expanded */
    static int dgnfils = -1;		/* Saved nfils value */
#endif

/* If file group interruption (C-Z) occured, fail.  */

    debug(F101,"gnfile: czseen","",czseen);

    if (czseen) {
	tlog(F100,"Transaction cancelled","",0l);
	return(0);
    }

/* If input was stdin or memory string, there is no next file.  */

    if (sndsrc == 0) return(0);

/* If file list comes from command line args, get the next list element. */

    y = -1;
    while (y < 0) {			/* Keep trying till we get one... */

	if (sndsrc > 0) {
	    if (nfils-- > 0) {

#ifdef datageneral
/* The DG does not internally expand the file names when a string of */
/* filenames is given. So we must in this case. */
                if (dgnfils == -1) {   /* This is executed first time only! */
                    strcpy(filnam,*cmlist++);
	            dgfiles = zxpand(filnam); /* Expand the string */
                    debug(F111,"gnfile:cmlist filnam (x-init)",filnam,dgfiles);
                    dgnfils = nfils + 1;
                    debug(F111,"gnfile:cmlist filnam (x-init)",filnam,dgnfils);
	         } 
	         x = znext(filnam);
	         if (x > 0) {      /* Get the next file in the expanded list */
	            debug(F111,"gnfile znext: filnam (exp-x=)",filnam,x);
                    nfils = dgnfils;     /* The virtual number of files left */
                 }
	         if (x == 0) {     /* Expand the next command argument */
	            if (dgnfils == 1) {
	                 dgnfils = -1;   /* The last argument resets things */
	                 *filnam = '\0';
	                 debug(F101,"gnfile cmlist: nfils","",nfils);
	                 return(0);
	            }
	          
                    strcpy(filnam,*cmlist++);  /* Finish expanding last arg */
	            dgfiles = zxpand(filnam); /* Expand the string */
                    debug(F111,"gnfile: cmlist filnam (exp)",filnam,dgnfils);
	            x = znext(filnam);
	            debug(F111,"gnfile znext: filnam (exp)",filnam,x);
	            nfils = dgnfils--;
		} 
#else
		strcpy(filnam,*cmlist++);
		debug(F111,"gnfile: cmlist filnam",filnam,nfils);
#endif
	    } else {
		*filnam = '\0';
		debug(F101,"gnfile cmlist: nfils","",nfils);
		return(0);
	    }
	}

/* Otherwise, step to next element of internal wildcard expansion list. */

	if (sndsrc < 0) {
	    x = znext(filnam);
	    debug(F111,"gnfile znext: filnam",filnam,x);
	    if (x == 0) return(0);
	}

/* Get here with a filename. */

	y = zchki(filnam);		/* Check if file readable */
	if (y < 0) {
	    debug(F110,"gnfile skipping:",filnam,0);
	    tlog(F111,filnam,"not sent, reason",(long)y);
	    screen(SCR_ST,ST_SKIP,0l,filnam);
	} else fsize = y;
    }    	
    return(1);
}

/*  O P E N I  --  Open an existing file for input  */

openi(name) char *name; {
    int x, filno;
    if (memstr) return(1);		/* Just return if file is memory. */

    debug(F110,"openi",name,0);
    debug(F101," sndsrc","",sndsrc);

    filno = (sndsrc == 0) ? ZSTDIO : ZIFILE;    /* ... */

    debug(F101," file number","",filno);

    if (zopeni(filno,name)) {		/* Otherwise, try to open it. */
	debug(F110," ok",name,0);
    	return(1);
    } else {				/* If not found, */
	char xname[100];		/* convert the name */
	zrtol(name,xname);		/* to local form and then */
	x = zopeni(filno,xname);	/* try opening it again. */
	debug(F101," zopeni","",x);
	if (x) {
	    debug(F110," ok",xname,0);
	    return(1);			/* It worked. */
        } else {
	    screen(SCR_EM,0,0l,"Can't open file");  /* It didn't work. */
	    tlog(F110,xname,"could not be opened",0l);
	    debug(F110," openi failed",xname,0);
	    return(0);
        }
    }
}

/*  O P E N O  --  Open a new file for output.  */

/*  Returns actual name under which the file was opened in string 'name2'. */

openo(name,name2) char *name, *name2; {
    char xname[100], *xp;

    if (stdouf)				/* Receiving to stdout? */
	return(zopeno(ZSTDIO,""));

    debug(F110,"openo: name",name,0);

    if (cxseen || czseen) {		/* If interrupted, get out before */
	debug(F100," open cancelled","",0); /* destroying existing file. */
	return(1);			/* Pretend to succeed. */
    }
    xp = xname;				/* OK to proceed. */
    if (fncnv)				/* If desired, */
    	zrtol(name,xp);			/* convert name to local form */
    else				/* otherwise, */
    	strcpy(xname,name);		/* use it literally */

    debug(F110,"openo: xname",xname,0);

    if (warn) {				/* File collision avoidance? */
	if (zchki(xname) != -1) {	/* Yes, file exists? */
	    znewn(xname,&xp);		/* Yes, make new name. */
	    strcpy(xname,xp);
	    debug(F110," exists, new name ",xname,0);
        }
    }
    if (zopeno(ZOFILE,xname) == 0) {	/* Try to open the file */
	debug(F110,"openo failed",xname,0);
	tlog(F110,"Failure to open",xname,0l);
	return(0);
    } else {
	strcpy(name2,xname);
	debug(F110,"openo ok, name2",name2,0);
	return(1);
    }
}

/*  O P E N T  --  Open the terminal for output, in place of a file  */

opent() {
    ffc = tfc = 0;
    return(zopeno(ZCTERM,""));
}

/*  C L S I F  --  Close the current input file. */

clsif() {
#ifdef datageneral
    if ((local) && (!quiet))    /* Only do this if local & not quiet */
        if (nfils < 1)          /* More files to send ... leave it on! */
            connoi_mt();
#endif
    if (memstr) {			/* If input was memory string, */
	memstr = 0;			/* indicate no more. */
    } else zclose(ZIFILE);		/* else close input file. */

    if (czseen || cxseen) 
    	screen(SCR_ST,ST_DISC,0l,"");
    else
    	screen(SCR_ST,ST_OK,0l,"");
    cxseen = hcflg = 0;			/* Reset flags, */
    *filnam = '\0';			/* and current file name */
}


/*  C L S O F  --  Close an output file.  */

/*  Call with disp != 0 if file is to be discarded.  */
/*  Returns -1 upon failure to close, 0 or greater on success. */

clsof(disp) int disp; {
    int x;
#ifdef datageneral
    if ((local) && (!quiet))    /* Only do this if local & not quiet */
        connoi_mt();
#endif
    if ((x = zclose(ZOFILE)) < 0) {	/* Try to close the file */
	tlog(F100,"Failure to close",filnam,0l);
	screen(SCR_ST,ST_ERR,0l,"");
    } else if (disp && (keep == 0)) {	/* Delete it if interrupted, */
	if (*filnam) zdelet(filnam);	/* and not keeping incomplete files */
	debug(F100,"Discarded","",0);
	tlog(F100,"Discarded","",0l);
	screen(SCR_ST,ST_DISC,0l,"");
    } else {				/* Nothing wrong, just keep it */
	debug(F100,"Closed","",0);	/* and give comforting messages. */
	screen(SCR_ST,ST_OK,0l,"");
    }
    *filnam = '\0';			/* Zero the current file name. */
    return(x);				/* Send back zclose() return code. */
}

/*  S N D H L P  --  Routine to send builtin help  */

sndhlp() {
    nfils = 0;				/* No files, no lists. */
    xflg = 1;				/* Flag we must send X packet. */
    strcpy(cmdstr,"help text");		/* Data for X packet. */
    first = 1;				/* Init getchx lookahead */
    memstr = 1;				/* Just set the flag. */
    memptr = hlptxt;			/* And the pointer. */
    if (binary) {			/* If file mode is binary, */
	binary = 0;			/*  turn it back to text for this, */
	savmod = 1;			/*  remember to restore it later. */
    }
    return(sinit());
}


/*  C W D  --  Change current working directory  */

/*
 String passed has first byte as length of directory name, rest of string
 is name.  Fails if can't connect, else ACKs (with name) and succeeds. 
*/

cwd(vdir) char *vdir; {
    char *cdd, *zgtdir();
    vdir[xunchar(*vdir) + 1] = '\0';	/* End with a null */
    if (zchdir(vdir+1)) {
	cdd = zgtdir();			/* Get new working directory. */
	encstr(cdd);
	ack1(data);
	tlog(F110,"Changed directory to",cdd,0l);
	return(1); 
    } else {
	tlog(F110,"Failed to change directory to",vdir+1,0l);
	return(0);
    }
}


/*  S Y S C M D  --  Do a system command  */

/*  Command string is formed by concatenating the two arguments.  */

syscmd(prefix,suffix) char *prefix, *suffix; {
    char *cp;

    if (prefix == NULL || *prefix == '\0') return(0);

#ifdef datageneral
/* A kludge for now -- the real change needs to be done elsewhere... */
    {
	extern char *WHOCMD;
	if ((strcmp(prefix,WHOCMD) == 0) && (*suffix == 0))
	  strcpy(suffix,"[!pids]");
    }
#endif
    for (cp = cmdstr; *prefix != '\0'; *cp++ = *prefix++) ;
    while (*cp++ = *suffix++) ;

    debug(F110,"syscmd",cmdstr,0);
    if (zopeni(ZSYSFN,cmdstr) > 0) {
	debug(F100,"syscmd zopeni ok",cmdstr,0);
	nfils = sndsrc = 0;		/* Flag that input from stdin */
	xflg = hcflg = 1;		/* And special flags for pipe */
	if (binary) {			/* If file mode is binary, */
	    binary = 0;			/*  turn it back to text for this, */
	    savmod = 1;			/*  remember to restore it later. */
	}
	return (sinit());		/* Send S packet */
    } else {
	debug(F100,"syscmd zopeni failed",cmdstr,0);
	return(0);
    }
}
