/*
    Copyright 1982, 1983
    Alcyon Corporation
    8716 Production Ave.
    San Diego, Ca.  92121
*/

char *version = "@(#)main.c	2.1	7/10/84";

#include "lo68.h"
#ifndef DECC
#	ifndef LIMITED
#		include <signal.h>
#		ifdef DOS4
			PFI signal();
#		endif
#	endif
#else
#	include "Isignal"
#endif
#ifdef REGULUS
#	include <sys/sysinfo.h>
#endif

#ifdef DRI
#	define OPEN		openb
#	define CREAT	creatb
#else
#	define OPEN		open
#	define CREAT	creat
#endif

#define REWIND(fd)  lseek(fd,0L,0)
/*
 * 68000 linking loader
 *   Bill Allen

 * This loader is basically a two pass operation.  The first pass
 *  reads all the relocatable object files including any libraries.

 *  It builds the full symbol table, resolves all external symbol
 *  references if possible, and calculates the total size of the
 *  text, data, and bss segements.  Pass 2 then does the binding,
 *  the relocation, and produces the final output file.
 */

#ifdef REGULUS
#	define LIBINDEX	8
	char libname[] = "/lib/lib7.a";   /*default library name*/
	char libxname[] = "/lib/lib       ";   /*library name*/
    char *ofilname = "a.out";
	char shortexit[] = "/lib/exit.o";
#else
#	ifdef CPM
#		define LIBINDEX	4
		char libname[] = "clib";   /*default library name*/
		char libxname[] = "clib      ";   /*library name*/
		char *ofilname = "c.out";     /*output file name*/
		char shortexit[] = "exit.o";
#	else
#	ifdef DOS4
#		define LIBINDEX	12
		char libname[] = "DRC:lib/libc.a";
		char libxname[] = "DRC:lib/libc      ";
		char *ofilname = "c.out";
		char shortexit[] = "DRC:lib/exit.o";
#	else
#	ifndef VMS
#			define LIBINDEX	18
			char libname[] ="/usr/local/lib/lib7.a";/*default library name*/
			char libxname[] = "/usr/local/lib/lib       ";/*library name*/
	    		char *ofilname = "c.out";     /*output file name*/
			char shortexit[] = "/usr/local/lib/shortexit.o";
#	else
#			define LIBINDEX	8
			char libname[] = "clib:lib7.a";
			char libxname[] = "clib:lib       ";
    			char *ofilname = "c.out";     /*output file name*/
			char shortexit[] = "clib:exit.o";
#		endif	/* VMS */
#	endif	/* DOS4 */
#	endif	/* CPM */
#endif

#ifndef VMS
#	ifdef CPM
#		define FILSEP	':'
#		define NAMELOC		2
		char tfilname[18] = "tmaXXXXX";
#	else
#	ifdef DOS4
#		define FILSEP	'/'
#		define NAMELOC		6
		char tfilname[18] = "TMP:tmaXXXXX";
#	else
#		define FILSEP	'/'
#		define NAMELOC		10	/* location in tfilname where letter is */
		char tfilname[18]  = "/tmp/_ldtmaXXXXX";  /*first temp file name*/
		int shortfildes;	/* file designator for short exit */
#	endif
#	endif
#else
#	define FILSEP	']'
#	define NAMELOC		5
	char tfilname[18]  = "wk:tmaXXXXX";

/**
 *	declarations for fix to sbrk problem.  On the vax when files are opened
 *	between calls to sbrk, the allocated memory is not contiguous.  Therefore
 *	all the input files are concatenated into one file which is opened prior
 *	to the calls to sbrk.  This process creates a large overhead in disk I/O,
 *	but the structure of the program requires that the memory for the symbol
 *	table be continuous.  It would be preferable to find a faster solution
 *	to the problem.
**/
	int openfilloc[NFILE];	/* pointers to beginning of the input files */
	int fdp = 0;			/* index to openfilloc */
	char *pt, *lpin;
#endif

long longseek();

char etexstr[]   = "_etext\0\0";
char edatstr[]   = "_edata\0\0";
char eendstr[]   = "_end\0\0\0\0";
int ignflg;
int needs_bits;
int debug;
int exstat;
int errno;		/* system call error number */

main(argc,argv)
int argc;
char **argv;
{
    register char **p, *pc, *p1;
    register i, j;
	int mmuflag;

#ifdef DRI
	if (fileargs(&argc, &argv) != 0) {
		printf(" : Out of memory reading arguments\n");
		exit( BAD_EXIT );
	}
#endif
#ifndef LIMITED
	if( signal(SIGINT,SIG_IGN) != SIG_IGN )
		signal(SIGINT,endit);
	if( signal(SIGQUIT,SIG_IGN) != SIG_IGN )
		signal(SIGQUIT,endit);
	if( signal(SIGHUP,SIG_IGN) != SIG_IGN )
		signal(SIGHUP,endit);
	signal(SIGTERM,endit);
#endif

#ifdef REGULUS
    sysinfo(0,&mmuflag);
	needs_bits = (!(mmuflag & M_MMU) || (mmuflag & M_STANFORD));
#else
	needs_bits = 0;
#endif
#ifndef VMS
	/* init the symbol table after all the files have been opened on the vax */
    intsytab();     /*initialize the symbol table*/
#endif
#ifdef DOS4
	stacksize = 0x01000L;
#endif
    firstsym = fsymp;
    libfctr = lbfictr;
    libptr = lbfioff;
    if(argc <= 1) {
usage:
		printf(": Invalid lo68 argument list\n");
		endit(-1);
    }

#ifdef VMS
	/* open all files */
	p = argv+1;
	for (i=1; i < argc; i++) {
		pc = *p++;
		if(*pc == '-') {
			switch(*++pc) {
				case 'l':
					pc--;
					break;
				case 'o':
					p++;
					i++;
				case 'i':
				case 'n':
				case 's':
				case 'X':
				case 'Z':
				case 'I':
				case 'U':
				case 'T':
				case 'D':
				case 'B':
				case 'r':
				case 'v':
				case 'm':
					continue;
			}
		}

		pt = pc;
		if (*pt == '-' && *++pt == 'l') {
			if(*++pt) {
				for(lpin = &libxname[LIBINDEX]; *pt; )
					*lpin++ = *pt++;
				*lpin++ = '.';
				*lpin++ = 'a';
				pt = libxname;
			}
			else	/* else default library name -- /lib/lib7.a */
				pt = libname;
		}
		else
			pt = pc;
		if ((openfilloc[fdp++]=open(pt,0)) < 0) {
			printf("unable to open %s\n",pt);
			printf("probably too many simultaneous opens for this system\n");
			endit(-1);
		}
	}
	fdp = 0;
	intsytab();			/* initialize the symbol table */
#endif
    p = argv+1;
    if (needs_bits) 
		saverbits++;  /* relocation bits forced on nommu sys */
    for(i=1; i<argc; i++) {     /*process each argument*/
		pc = *p++;

#ifdef DRI
	/* Compare for a file named ".o" and skip it for CP/M and VAX
	   command file operation. */

                if(_strcmp (pc,".o") == 0)
                        continue;               /* Just skip this one */
#endif

		if(*pc == '-') {
	    	switch(*++pc) {
	
				case 'l':       /*library*/
					pc--;
					break;

#ifdef DRI
				case 'f':		/* Temp file path, for compatibility */
				case 'F':
					*p++;
					i++;
					continue;
#endif
				case 'o':       /*output file name*/
					ofilname = *p++;/*next arg is file name*/
					i++;
					continue;

#ifdef DRI
				case 'm':
					stacksize = lgetnum(++pc,16);
					continue;
#endif

				case 'n':   /*shared text*/
					shtext = DEFSHTEXT;
					if(*++pc == '2') /* mod 2k on shared text */
						shtext = TWOKSHT;
					else if( *pc == '4' )
						shtext = FOURKSHT;
					continue;
		
#ifndef DRI
				case 'i':       /* i & d split*/
					isplit++;
					continue;
#endif

				case 's':   /*don't output symbol table*/
					sflag++;
					continue;
		
#ifdef DRI
				case 'x':
#endif
				case 'X':   /*keep local symbols except L**/
					Xflag++;
					continue;

#ifdef DRI
				case 'z':
				case 't':
#endif
				case 'Z':   /*offset the text base for standaone pgm*/
				case 'T':   /*another name for same flag*/
					Zflag++;
					textstart = lgetnum(++pc,16);   /*get a long hex number*/
					textbase = textstart;
					continue;

#ifdef DRI
#ifndef DEBUG
				case 'd':
#endif
#endif
				case 'D':   /*data segment base*/
					Dflag++;
					datastart = lgetnum(++pc,16);
					continue;

#ifdef DRI
				case 'b':
#endif
				case 'B':   /*bss segment base*/
					Bflag++;
					bssstart = lgetnum(++pc,16);
					continue;
#ifdef DRI
				case 'i':
#endif
				case 'I':   /*ignore 16-bit addr overflow*/
					ignflg++;
					continue;
		
#ifdef DEBUG
				case 'd':
					debug++;    /*[vlh] 4.2 debugging turned on... */
					continue;
#endif
				case 'r':
					saverbits++;    /*put relocation bits on c.out*/
					continue;

#ifdef DRI
				case 'u':
#endif
				case 'U':   /*initial undefined symbol*/
					p1 = lmte;
					pc++;
					for(j=SYNAMLEN; --j != -1; ) {	/* 2 may 83 */
						*p1++ = *pc;
						if(*pc)
							pc++;
					}
					((struct symtab *)lmte)->flags = SYXR; /*extern reference*/
					addsym(0);  /*put into symbol table*/
					continue;

			}
		}
		p1load(pc); /*read file or library*/
    }
    resolve();      /*resolve externals and assign addresses*/
    pass2++;        /*now in pass 2*/
    p = argv+1;
    firstsym = fsymp;
    libfctr = lbfictr;
    libptr = lbfioff;
    makeofile();        /*make the output file*/
    for(i=1; i<argc; i++) { /*process each argument*/
		pc = *p++;

#ifdef DRI
	/* Compare for a file named ".o" and skip it for CP/M and VAX
	   command file operation. */

                if(_strcmp (pc,".o") == 0)
                        continue;               /* Just skip this one */
#endif

		if(*pc == '-') {
	    	switch(*++pc) {

	    	case 'l':   /*library*/
				pc--;
				break;

			case 'f':		/* temp file directory */
			case 'F':
	    	case 'o':   /*output file name*/
				p++;    /*skip file name*/
				i++;
				continue;

#ifndef DRI
			case 'i':
#endif
			case 'n':
			case 's':   /*don't output symbol table*/
#ifdef DRI
			case 'x':
			case 'z':
			case 'i':
			case 'u':
			case 't':
			case 'd':
			case 'b':
#endif
			case 'X':
			case 'Z':
			case 'I':
			case 'U':
			case 'T':
			case 'D':
			case 'B':
			case 'r':
			case 'v':
#ifdef DRI
			case 'm':
#endif
			continue;

			}
		}
		p2load(pc); /*read file or library*/
    }
    finalwr();      /*finish output file*/
}

/*
 * pass 1 load routine:
 *  read the file or library and build the symbol table
 *  symbols are organized on the initial reference tables
 *  with externals on eirt and globals on girt
 */
p1load(ap)
char *ap;
{
#ifndef VMS
    openfile(ap);   /*get the file opened using ibuf*/
#else
	vsetfile(ap);	/* handles combined file */
#endif
#ifdef DEBUG
	printf("Processing [%s]\n",ap);
#endif
    if(couthd.ch_magic == LIBMAGIC) 	/*library*/
		searchlib();
    else {
		do1load(0);     /*load a *.o file*/
		firstsym++;
		addsizes();
    }
    close(ibuf.fd);
}

/**
 *	search a library for files to include.  include an entry only
 *	if it has a global symbol which matches an external.
**/
long lbctr;
long libfilsize;
searchlib()
{
/*	Don't worry about shortsearch on vax/vms */
#ifndef VMS
    if(shortlflg || shortsearch())  /*optimize no lib routines to load*/
		return;
#endif
    lbctr = 2;
    *libfctr = 0;       /*no files from this library yet*/
    while(rdlibhdr()) { /*read library file header*/
		savsymtab();    /*save current state of symbol table*/
		extmatch = 0;
		noload = 0;
		ifilname = libhd.lfname;
		readhdr();          /*read the file header*/
		do1load(1);         /*load this files symbol table & try match*/
		if(extmatch > noload) {     /*found a match*/
	    	if(noload)
				prdup(lastdup); /*print dup defn*/
	    	addsizes();     /*add this files sizes*/
	    	firstsym++;
	    	*libfctr += 1;  /*count files loaded from this library*/
	    	*libptr++ = lbctr;  /*remember offset in library*/
		}
		else   /*dont need this file*/
	    	restsymtab();       /*restore symbol table*/
	
		if(libfilsize&1) {      /*one byte of padding*/
	    	getc(&ibuf);
	    	lbctr++;
		}
		lbctr += libfilsize + LIBHDSIZE;
		longseek(lbctr,&ibuf);    /*goto begin of next lib entry*/
    }
    libfctr++;      /*point to next library file counter*/
}

/*read a library file header*/
rdlibhdr()
{
	if (getarhd(&ibuf,&libhd) == -1)	/* 4.1 new library routine */
		return(0);      		/*end of file*/
	libhd.lmodti = 0;			/* provide end of string delim for name */
	libfilsize = libhd.lfsize; 	/* copy out file size */
    return(1);
}

/* open the file pointed to by ap*/
/*  check for the -lx type library spec*/
openfile(ap)
char *ap;
{
    register char *p, *lp;
#ifdef VAX11
	unsigned short omagic;
#else
	 unsigned short omagic; /* changed from int. RHR */
#endif

    p = ap;
    if(*p=='-' && *++p=='l') {
		if(*++p) { 		/* 13 apr 83, multi-char libraries */
	    	for (lp = &libxname[LIBINDEX]; *p; )
				*lp++ = *p++;
			*lp++ = '.';
			*lp++ = 'a';
			*lp = 0;
			p = libxname;
		}
		else 	/* else default library name -- /lib/lib7.a */
			p = libname;
    }
    else
		p = ap;
    if((ibuf.fd=OPEN(p,0)) < 0) {
		printf(": unable to open %s\n",p);
		endit(-1);
    }
    ifilname = p;   /*point to current file name for error msgs*/
    /* if(read(ibuf.fd,&omagic.hibyte,1)!=1 ||
       read(ibuf.fd,&omagic.lobyte,1)!=1) {  RHR */
    /* byte order is ok on the 68K RHR */
    if ( read(ibuf.fd,&omagic,2) != 2) {
		printf(": read error on file: %s\n",ifilname);
		endit(-1);
                }
    couthd.ch_magic = omagic;  
	ibuf.cc = 0;
    if (omagic != LIBMAGIC) {
		REWIND(ibuf.fd);
		readhdr();  /*read file header*/
    }
    if(pass2) {     /*need file descrptr for reloc bits*/
		rbuf.fd = OPEN(p,0);
		rbuf.cc = 0;
    }
}

#ifdef VMS
/**
 *	vsetfile - make usable the file pointed to by openfilloc[fdp]
 *		called from p1load only.
**/
vsetfile(ap)
char *ap;
{
	unsigned short omagic;

	ibuf.fd = openfilloc[fdp++];
	ibuf.cc = 0;
	ifilname = ap;	/* point to current file name for error messages */
	if(read(ibuf.fd,&omagic.hibyte,1)!=1 || read(ibuf.fd,&omagic.lobyte,1)!=1) {
		printf(": read error on file: %s\n",ifilname);
		endit(-1);
	}
	couthd.ch_magic = omagic;
	ibuf.cc = 0;
	if (omagic != LIBMAGIC) {
		REWIND(ibuf.fd);
		readhdr();
	}
}
#endif

/* read the header of the input file*/
readhdr()
{
	if (getchd(&ibuf,&couthd) == -1) {	/* 4.1 new library routine */
		printf(": error reading header: %s\n",ifilname);
		endit(-1);
	}
    if(couthd.ch_magic == LIBRMAGIC) {
		printf(": ranlib libraries not allowed format error: %s\n",ifilname);
		endit(-1);
	}
    if(couthd.ch_magic != EX_MAGIC) {
		printf(": file format error: %s %o\n",ifilname,(int)couthd.ch_magic);
		endit(-1);
    }
    if(couthd.ch_rlbflg) {
		printf(": no relocation bits: %s\n",ifilname);
		endit(-1);
    }
}

/*
 * load one *.o format file using ibuf
 *  put the symbols into the symbol table relocating each one
 *  and finally add this files sizes into running totals
 *  libflg is set if we are in a library
 */
do1load(libflg)
int libflg;
{
    register long i, l, ret;

#ifndef NOSYFN
	addfnsym();				/* put file name into symbol table */
#endif
    *firstsym = lmte;       /*remember where this symbol table starts*/
    l = couthd.ch_tsize + couthd.ch_dsize + HDSIZE;
    if(libflg)
		l += lbctr + LIBHDSIZE;
	ret = longseek(l,&ibuf);
    i = couthd.ch_ssize;        /*size of symbol table*/
    while(i > 0) {
		getsym();       	/*read one symbol entry*/
		relocsym();     	/*fix its address*/
		addsym(libflg);    	/*add to symbol table*/
		i -= OSTSIZE;
    }
}

/* put file name into symbol table */
#ifndef NOSYFN
addfnsym()
{

	register char *p,*q;
	register int i;

	p = q = ifilname;
	while(*p) {
		if(*p == FILSEP)	/* directory delimiter */
			q = p+1;
		p++;
	}
	p = lmte;
	for(i=0; i<SYNAMLEN; i++) {
		if(*q) {
			*p++ = *q++;
		}
		else {
			*p++ = '\0';
		}
	}
	lmte->flags = SYFN|SYGL|SYTX;	/* file name bit */
	lmte->vl1 = textbase;
	addmte();
}
#endif

/* get a temp file for the intermediate text*/
gettempf()
{
    register int j;
#ifndef VMS
#ifndef DRI
	struct stat stbuf;
#endif
#endif

    while( mktemp(tfilname) ) {
#ifndef VMS
#ifdef DRI
		if (access(tfilname,0) == 0)
			continue;
#else
		if( stat(tfilname,&stbuf) >= 0 )
			continue;	/* this file exists */
#endif
#endif
		if( (j = CREAT(tfilname,0600)) >= 0 )
	    	return(j);
		else if (debug)
			printf("couldn't creat, return value %d\n",j);
    }
    printf(": Unable to open temporary file\n");
    endit(-1);
}

/* update the relocation counters with the sizes in the header*/
addsizes()
{
    textbase = textbase + couthd.ch_tsize;
    database = database + couthd.ch_dsize;
    bssbase  = bssbase + couthd.ch_bsize;
}

/* assign an address for a block of bss common*/
asgncomn(ap)
char *ap;
{
    register char *p, *p1;
    register long l;

    p = ap;
    pack(p,lmte);
    p1 = lemt(girt);
    if(p1 != lmte) {        /*matches a global entry*/
		if(((struct symtab *)p1)->flags&SYTX) {    /* linking to text symbol */
	    	printf("text/data symbol name conflict: %s\n",p1);
		}
		((struct symtab *)ap)->vl1 = ((struct symtab *)p1)->vl1;
		return;
    }
    l = 0;
    lemt(eirt);
    do {
		if(((struct symtab *)p)->vl1 > l)
	    	l = ((struct symtab *)p)->vl1;
		((struct symtab *)p)->vl1 = 0;
    } while((p = nextsy(((struct symtab *)p)->tlnk)) != lmte);
	/*now make a global entry for this common block*/
    ((struct symtab *)p)->flags = SYDF|SYGL|SYBS;
    ((struct symtab *)p)->vl1 = bssbase + bsssize;
		/*copy address to first external*/
    ((struct symtab *)ap)->vl1 = ((struct symtab *)p)->vl1;
    bsssize += l;
    lemt(girt);     /*set ptrs for global chain*/
    mmte();             /*add to global chain*/
}

/* assign an address to an external by matching it with a global*/
/*  print an error message if no match*/
asgnext(ap)
char *ap;
{
    register char *p, *pg;

    p = ap;
    pack(p,lmte);       /*copy current symbol name*/
    pg = lemt(girt);
    if(pg == lmte) {    /*no match in global symbols*/
		pg = lemt(eirt);    /*set ptrs for external chains*/
		if(pg == lmte) {
	    	printf(": asgnext botch\n");
	    	endit(-1);
		}
		while((p = nextsy(((struct symtab *)p)->tlnk)) != lmte) {
	    	if(((struct symtab *)p)->vl1) {        /*common*/
				asgncomn(ap);
				return;
	    	}
		}
		if(spendsym(ap))        /*end, etext or edata*/
	   		return;
		if(undflg==0) {
	   	 	printf(": Undefined:\n");
	   	 	undflg++;
	   	 	exstat++;
		}
		prtsym(p);
    }
    else   /*assign symbol value*/
		((struct symtab *)p)->vl1 = ((struct symtab *)pg)->vl1;
    
}

/* pass 2 load routine:*/
/*  read the file or library and do relocation */
p2load(ap)
char *ap;
{
    openfile(ap);   /*get the file opened using ibuf*/
    if(couthd.ch_magic == LIBMAGIC)
		loadlib();
    else {
		do2load(0);     /*load a *.o file*/
		addsizes();
    }
    close(ibuf.fd);
    close(rbuf.fd);
}

/*make the outut file and write the header*/
makeofile()		/* 4.1 restructured */
{
	register struct hdr2 *lb;
	struct hdr2 olibhd;

    if( (obuf.fd = CREAT(ofilname,0666)) < 0 ) { /* only make exec if all ok */
		printf(": Unable to create %s\n",ofilname);
		endit(-1);
    }
    obuf.cc = BSIZE;
    obuf.cp = &obuf.cbuf[0];
	lb = &olibhd;
    if(Zflag|Dflag|Bflag) {		/*expanded header: data & bss bases in header*/
		lb->ch_magic = (unsigned short)EX_ABMAGIC;
		lb->ch_dstart = datastart;
		lb->ch_bstart = bssstart;
    }
	else if (isplit)		/* i & d split */
		lb->ch_magic = (unsigned short)EX_IDMAGIC;
    else if(!shtext)		/* standard */
		lb->ch_magic = (unsigned short)EX_MAGIC;
	else if (shtext == -1)	/* 2k boundary */
		lb->ch_magic = (unsigned short)EX_2KSTXT;
	else					/* 4k boundary */
		lb->ch_magic = (unsigned short)EX_4KSTXT;
    lb->ch_tsize = textsize;
    lb->ch_dsize = datasize;
    lb->ch_bsize = bsssize;
    lb->ch_ssize = (long)(lmte - bmte);
    lb->ch_stksize = stacksize;
	lb->ch_entry = textstart;
	if (saverbits)			/* bits present ?? */
		lb->ch_rlbflg = 0;
	else
		lb->ch_rlbflg = -1;
/* printf("tsz %d dsz %d bsz %d ssz %d bits %d\n",lb->ch_tsize,lb->ch_dsize,lb->ch_bsize,lb->ch_ssize,lb->ch_rlbflg); */
	putchd(&obuf,lb);

    tmpbinit(&tbuf);    /*temp for data words*/
    dafnc = tfilname[NAMELOC];
    if(saverbits) {
		tmpbinit(&rtbuf);   /*temp for text relocation bits*/
		rtfnc = tfilname[NAMELOC];
		tmpbinit(&rdbuf);   /*temp for data relocation bits*/
		rdfnc = tfilname[NAMELOC];
    }
}

tmpbinit(abufp)
struct iob *abufp;
{
    register struct iob *bufp;

    bufp = abufp;
    bufp->fd = gettempf();
    bufp->cc = BSIZE;
    bufp->cp = &bufp->cbuf[0];
}

endit(xstat)
int xstat;
{
#ifdef DEBUG
	if (debug)
		exit( BAD_EXIT );
#endif
    if(dafnc) {
		tfilname[NAMELOC] = dafnc;
		unlink(tfilname);
    }
    if(saverbits) {
		tfilname[NAMELOC] = rtfnc;
		unlink(tfilname);
		tfilname[NAMELOC] = rdfnc;
		unlink(tfilname);
    }
	if( xstat == 0 )
		chmod(ofilname,0777);	/* if all ok, make it executable [jws] */
#ifdef VMS
	else
		printf("load failed - status = %x\n",xstat);
#endif
    exit(xstat ? BAD_EXIT : GOOD_EXIT);
}

/*
 * load files from a library.  the library is open in ibuf, the
 *  count of files to load is pointed to by libfctr, and the offset
 *  of each file is pointed to by libptr.
 */
loadlib()
{
    register int i,j;
    register long l;

#ifndef VMS
	/* don't short load on a vms vax */
    if(shortlflg) {
		if(shortlflg == 1)  /*need to load short exit*/
	    	shortload();
		shortlflg++;
		return;
    }
#endif
    i = *libfctr++; /*# files to load from this library*/
    if(i==0)
		return;     /*none to load*/
    while(i--) {    /*load the files*/
		l = *libptr++;          /*library offset for this file*/
		longseek(l,&ibuf);        /*seek to beginning of file*/
		longseek(l,&rbuf);
		if (!rdlibhdr())         /*read the library header*/
			printf("Bad Library Header....\n");
		readhdr();          /*read the file header*/
		lbctr = l;
		do2load(1);         /*load it*/
		addsizes();
    }
}

#ifndef PDP11
/* do a long seek on buffer bp  given a long file offset*/
long
longseek(al,bp)
long al;
struct iob *bp;
{
	long ret;

	ret = lseek(bp->fd,al,0);
    bp->cc = 0;     			/*input buffer empty*/
	bp->cp = &bp->cbuf;
	return(ret);
}
#endif

/*
 * look up the value of an external symbol given the external symbol
 *  number.  Since externals are duplicated on the external hash chains,
 *  all external entries don't have values assigned in the symbol table,
 *  so the external name must be looked on the global chains and
 *  the value of the matching symbol used.  symptr points to the
 *  first symbol for the current file's symbol table
 */
long 
extval(extno)
int extno;
{
    register struct symtab *p;
    register char *pg;

	p = symptr + extno;
    if((p->flags&SYXR)==0)
		return(p->vl1);
    pack(p,lmte);
    pg = lemt(girt);
    if(pg == lmte)
		pg = lemt(eirt);    /*may be common*/
    return(((struct symtab *)pg)->vl1);        /*return globals address*/
}

/* look up the relocation base for an external symbol.  must use same*/
/*  method as in extval for the same reasons (see comment above)*/
extbase(extno)
int extno;
{
    register struct symtab *p;
    register char *pg;
    register int i;

    p = symptr + extno;
    if((p->flags&SYXR)==0)
		pg = (char *)p;
    else {
		pack(p,lmte);
		pg = lemt(girt);
		if(pg == lmte)
	    	pg = lemt(eirt);    /*may be common*/
    }
    i = ((struct symtab *)pg)->flags;
    return((i&SYDA)? DRELOC : (i&SYTX)? TRELOC : (i&SYBS)? BRELOC : DABS);
}

/* load a file doing relocation and external resolution*/
/*  libflg is set if we are loading from a library*/
do2load(libflg)
int libflg;
{
    int longf;
	short i, j;
    register struct iob *p;
    register struct iob *pr;
    int saof, wasext;
	short word;
    register long tpc, l;
    long l1;

    tpc = 0;
    p = &obuf;
    pr = &rtbuf;
    saof = -1;
    symptr = (struct symtab *)*firstsym++;   /*beginning of this symbol table*/
    l = couthd.ch_tsize + couthd.ch_dsize + couthd.ch_ssize + HDSIZE;
    if(libflg)
		l += lbctr+LIBHDSIZE;
    longseek(l,&rbuf);    /*long seek */
    l = couthd.ch_tsize;
do2l1:
    while((l -= 2) >= 0) {   /*relocate the text*/
		longf = 0;
		lgetw(&i,&ibuf);    /*text or data word */
		lgetw(&j,&rbuf);    /*relocation word*/
		tpc += 2;       	/*keep pc in this file*/
		wasext = 0;
		switch(j&7) {       /*relocation bits*/
	
	    	case INSABS:    /*first word of instr*/
	    	case DABS:      /*data absolute*/
				lputw(&i,p);
				if(saverbits)
		    		lputw(&j,pr);     /*relocation bits*/
				break;

	    	case LUPPER:    /*high word of long*/
				l1.hiword = i;
				if(saverbits)
		    		lputw(&j,pr);     /*upper word relocation bits*/
				lgetw(&l1.loword,&ibuf);
				lgetw(&j,&rbuf);
				tpc += 2;
				longf++;    /*doing two words*/
				l -= 2;     /*count lower half*/
dorelc:
				switch(j&7) {

				case DABS:
					if(saverbits)
						lputw(&j,pr);
					break;

				case INSABS:
				case LUPPER:
				default:
					goto do2l99;

				case TRELOC:
					l1 += textbase;
					if(saverbits)
						lputw(&j,pr);
					break;

				case DRELOC:
					l1 += database;
					if(saverbits)
						lputw(&j,pr);
					break;
	
				case BRELOC:
					l1 += bssbase;
					if(saverbits)
						lputw(&j,pr);
					break;

				case EXTVAR:
					wasext++;
					l1 += extval((int)j>>3);
					if(saverbits) {
						word = extbase((int)j>>3);
						lputw(&word,pr);
					}
					break;
	
				case EXTREL:
					l1 = l1+extval((int)j>>3)-textbase-tpc+2;
					if(l1<0xffff8000 || l1>0x7fff) {
						printf(": relative address overflow at %lx in %s\n",
								tpc,ifilname);
						prextname((int)j>>3);    /*give name referenced*/
						exstat++;
					}
					l1.hiword = 0;
					if(saverbits) {
						word = DABS;
						lputw(&word,pr);
					}
					goto outlowd;
	
				}
				if(ignflg==0 && longf==0 && l1&0xffff8000 && saof) {
					printf(": short address overflow in %s\n",ifilname);
					if(wasext)
						prextname((int)j>>3);
					exstat++;
					if(libflg) {
						l1 = *(libptr-1);
						printf("library offset = %u\n",(int)l1.loword);
						l1 = 0;
					}
					saof = 0;
				}
				if(longf)
					lputw(&l1.hiword,p);
outlowd:
				lputw(&l1.loword,p);
				break;
		
			case TRELOC:
			case DRELOC:
			case BRELOC:
	    	case EXTVAR:
	    	case EXTREL:
				l1 = *(libptr-1);
				if (needs_bits) {
		    		printf("library offset = %u\n",(int)l1.loword);
		    		printf("16-bit reloc in %s\n",ifilname);
				}
				l1 = i;     /*sign extend to long like 68000*/
				goto dorelc;
	
	    	default:
			do2l99:
				printf(": lo68: invalid relocation flag in %s\n",ifilname);
				endit(-1);
		
		}
    }
    if(p == &obuf) {
		p = &tbuf;      /*place to put data*/
		pr = &rdbuf;    /*file for data relocation bits*/
		l = couthd.ch_dsize;
		goto do2l1;     /*now do the data*/
    }
}

/* do the final writting to the output file*/
/*  copy the initialized data from the temp file to the output file*/
/*  write the symbol table to the output file*/
finalwr()
{
    if((textsize+textstart) != textbase) {
		printf(": finalwr: text size error\n");
		exstat++;
    } 
    cpdata(&tbuf,dafnc,datasize);
    osymt();        /*write the symbol table*/
    if(saverbits) {
		cpdata(&rtbuf,rtfnc,textsize);
		cpdata(&rdbuf,rdfnc,datasize);
    }
    v6fflush(&obuf);
/* longseek was: lseek(obuf.fd,14L,0); */
    if( longseek(14L,&obuf) < 0 || lwritel(obuf.fd,&stlen) == -1 ) {
		printf(": output file write error\n");
		exstat++;
    }
    endit(exstat);
}

/* copy the initialized data words from temp file to output file*/
cpdata(pb,fnc,size)
struct iob *pb;
char fnc;
long size;
{
    register int i,cfn, j;

    v6fflush(&obuf);
    v6fflush(pb);
    close(pb->fd);
    tfilname[NAMELOC] = fnc;
    if((cfn=OPEN(tfilname,0)) < 0) {
   		printf(": unable to reopen %s\n",tfilname);
		printf(": errno=%o\n",errno);
		endit(-1);
    }
	while (size) {
		i = (size > BSIZE)? BSIZE : size;
	    if (read(cfn,&pb->cbuf[0],i) != i) {
			printf(": merge file read error");
			endit(-1);
		}
		if(write(obuf.fd,&pb->cbuf[0],i) != i) {
	    	printf(": output file write error");
	    	endit(-1);
		}
		size -= i;
	}
}

/*get constant given radix*/
/*  this routine only works for radixes of 2, 8, 16*/
/*  so as to avoid lmul because of floating point*/
long lgetnum(apc,ardx)
char *apc;
int ardx;
{
    register trdx,j;
    register char *pc;
    register long i;

    pc = apc;
    if(ardx==16)
		trdx = 4;       /*radix as power of 2*/
    else if(ardx==8)
		trdx = 3;
    else if(ardx==2)
		trdx = 1;
    else
		return(0);
    i=0;
    while(1) {
		j = *pc++;
		if(j>='0' && j<='9')
	    	j -= '0';
		else
	    	if(j>='a' && j<='f')
				j = j-'a'+10;
	    	else 
				if(j>='A' && j<='F')
					j = j-'A'+10;
				else
					break;          /*not valid numeric char*/
		if(j>=0 && j<ardx)
	    	i = (i<<trdx)+j;
		else
	    	break;
    }
    return(i);
}

/* look for and define if found etext, edata, and end*/
spendsym(ap)
struct symtab *ap;
{
    register struct symtab *p;

    p = ap;
    if(eqstr(etexstr,&p->name[0])) {
		etextptr = p;
		return(1);
    }
    if(eqstr(edatstr,&p->name[0])) {
		edataptr = p;
		return(1);
    }
    if(eqstr(eendstr,&p->name[0])) {
		endptr = p;
		return(1);
    }
    return(0);
}

/* test two symbol names for equality*/
eqstr(ap1,ap2)
char *ap1, *ap2;
{
    register char *p1, *p2;
    register int i;

    p1 = ap1;
    p2 = ap2;
    for(i = SYNAMLEN; --i != -1; )	/* 2 may 83 */
		if(*p1++ != *p2++)
		    return(0);
    return(1);
}

/* print an error message giving an external name*/
prextname(extno)
int extno;
{
    register struct symtab *p;
    register char *pc;

    p = symptr + extno;
    printf(": external name: ");
    for(pc = &p->name[0]; pc < &p->name[SYNAMLEN]; pc++) {
		if(*pc == 0)
	    	break;
		putchar(*pc);
    }
    putchar('\n');
}

#ifndef VMS
/**
 * check to see if we only need to load exit -- no other
 * library routines needed.  if so, load exit only and
 * return 1 else return 0.
**/
shortsearch()
{
    register char *p;
    register char **sx1, **sx2;
    register int i;

    for(sx1=eirt; sx1<&eirt[63]; sx1 += 2) {    /*go thru externals*/
		if(*(sx2 = sx1+1)==0)   /*this chain empty*/
	    	continue;

/* go thru symbols on chain*/
		sx2 = (char **)*sx2;     /*first entry on this chain*/
		while(1) {
	    	if(((struct symtab *)sx2)->vl1 == 0)
				if(eqstr("_exit\0\0\0",sx2)==0&&eqstr("_main\0\0\0",sx2)==0)
		    		return(0);
	    	p = (char *)sx2;
	    	if(p == *sx1)       /*end of chain*/
				break;
	    	sx2 = (char **)((struct symtab *)sx2)->tlnk; /*next entry in chain*/
		}
    }
/* found only exit undefined*/
    if((i=OPEN(shortexit,0)) < 0)
	return(0);      /*cant open short exit file*/
    close(i);
    close(ibuf.fd); /*close library -- dont need to scan it*/
    openfile(shortexit);
    do1load(0);         /*load short exit*/
    firstsym++;
    addsizes();
    shortlflg++;
    return(1);
}

/* load the short exit routine*/
shortload()
{
    close(ibuf.fd);     /*dont need library*/
    close(rbuf.fd);
    openfile(shortexit);
    do2load(0);
    addsizes();
}
#endif

#ifndef REGULUS
static char _uniqlet = 'a';

char *
mktemp(ap)
char *ap;
{
	register char *p;
	register int i,j;

	p = ap;
	i = getpid();		/* process id */

	while( *p )
		p++;

	for(j = 5; --j != -1; ) {
		*--p = ((i&7) + '0');
		i >>= 3;
	}
	*--p = _uniqlet;

	_uniqlet++;
	if( _uniqlet > 'z' )
		_uniqlet = 'A';
	if( _uniqlet == 'Z' )
		return(0);
	return(ap);
}
#endif

#ifdef PDP11
/**
 *	longseek - do a long seek on buffer bp, given a long
 *		file offset.
**/
long
longseek(al,bp)
long al;
struct buf *bp;
{
	long l, ret;
	register short b,o;

	l = al>>9;
	b = l.loword;		/* block # */
	o = al.loword&0777;	/* offset in block */
	if((ret=seek(bp->fd,b,3)) < 0) {	/* seek to block */
		printf(": seek error on file %s\n",ifilname);
		endit(-1);
	}
	if((l=seek(bp->fd,o,1)) < 0) {		/* do offset */
		printf(": seek error on file %s\n",ifilname);
		endit(-1);
	}
 	bp->cc = 0;			/* input buff empty */
	bp->cp = &bp->cbuf;
	ret = (b*512) + o;
	return(ret);
}
#endif

/* memcpy - copy n characters of s2 to s1
**
** calling sequence:
**	ptr = memcpy(s1, s2, n)
**
** return:
**	ptr = s1
**
*/

char	*
memcpy(s1, s2, n)
char	*s1, *s2;
int	n;
{
	register	char	*ts1 = s1;
	register	char	*ts2 = s2;

	while(n--)
		*ts1++ = *ts2++;
	return(s1);
}
