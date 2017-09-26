/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca. 92121
 */

char *SCCSID = "@(#)ar68.c	1.13	5/30/84";

/*********************  Machine Dependent Defines ********************/
#ifdef DRI
#	include <stdio.h>
#	ifdef CPM
#		include "cpm.h"
#	else
#		include <channels.h>
#	endif
#	include "ar68.h"
#	include "cout.h"
#	include "types.h"
#	include "order.h"
#	define FDopen fdopen
#	define creat	creatb
#	define open	openb
#	define fopen	fopenb
	FILE *fopen(), *FDopen();
#else
#	include <stdio.h>
#endif

#ifdef VAX11
#	include <c68/ar68.h>
#	include <sys/types.h>
#	include <stat.h>
#	include <c68/order.h>
#endif

#ifdef REGULUS
#	include <sys/types.h>
#	include <stat.h>
#	include <ar68.h>
#	include <order.h>
#endif

#ifdef PDP11
#	ifndef V6
#		include <c68/ar68.h>
#		include <sys/types.h>
#		include <stat.h>
#		include <c68/order.h>
#	else
#		include <c68/ar68.h>
#		include <stat11.h>
#		include <c68/order.h>
		long mklong();
#	endif
#endif

#ifdef vax11c
#	define	VAX11
#	define	CDEFMODE 0644
#	define	TMPNAME	"wk:ar?????"
#	define	DIRSEP	"]"
#	define  CHDR	8
#	define	unlink	delete
#	include "IAR68"
#	include "ISTAT"
#	include "ICOUT"
	char fname[50];
	struct hdr chdr1;
#else
#	define	CDEFMODE 	lp->lfimode
#	ifdef CPM
#		define	TMPNAME		"ar?????"
#		define	DIRSEP		":"
		char	fname[15];
#	else
#		ifdef DOS4
#			define	TMPNAME		"TMP:ar?????"
#			define	DIRSEP		"/\\:"
			char	fname[15];
#		else
#			define	TMPNAME		"/tmp/_~ar?????"
#			define	DIRSEP		"/"
			char	fname[15];
#		endif
#	endif
#endif

/*********************  Defines and global variables ********************/
#define	DEFMODE  	0666
#define SEEKTYPE long

#ifdef DRI
#	define USAGE	"usage: %s rdxtw[vabi] [pos] archive file [file ...]\n"
#else
#	define USAGE	"usage: %s [rdxtpvabi] [pos] archive file [file ...]\n"
#endif

char buff[BUFSIZ];

#ifndef DRI
struct stat astat, tstat;	/* 11 apr 83, struct stat */
#endif

#define READ	0
#define WRITE	1

/* flags for cp1file */

#define IEVEN	1
#define OEVEN	2
#define WHDR	4

#define	ROWN	0400	/* file protection flags */
#define	WOWN	0200
#define	XOWN	0100
#define	RGRP	040
#define	WGRP	020
#define	XGRP	010
#define	ROTH	04
#define	WOTH	02
#define	XOTH	01

struct libhdr libhd;
struct libhdr *lp = { &libhd };

short libmagic = LIBMAGIC;

short rflg, dflg, xflg, tflg, vflg;
short uflg;
short pflg;
short areof;
FILE *arfp;
FILE *tempfd;
short aflg, bflg;
short psflg;
short matchflg;
char *psname;
char *myname;

char *arname,*tempname;

FILE *openar();
char *mktemp();
char *ctime();
char *fnonly();
short (*docom)();
short endit();
short replace();
short ddelete();
short extract();
short tellar68();
short print();
short prshort();

main(argc,argv)
char **argv;
short argc;
{
	register char *p1, *p2;
	register char **ap;
	register short i;
	short j,docopy;

#ifdef DRI
	if (fileargs(&argc, &argv)) {
		printf("Out of memory reading arguments\n");
		endit();
	}
#endif
#ifdef CPM
	myname = "ar68";
#else
	myname = *argv;
#endif
	if( argc < 3 ) {
usage:
		printf(USAGE,myname);
		endit();
	}
	signal(1,endit);
	signal(2,endit);
	ap = &argv[1];
	p1 = *ap++;
	i = argc-3;
	while(*p1) {
		switch(*p1++) {
			case 'r':
				rflg++;
				docom = replace;
				break;
			case 'a':
				aflg++;
				psname = *ap++;
				i--;
				break;
			case 'b':
			case 'i':
				bflg++;
				i--;
				psname = *ap++;
				break;
			case 'd':
				dflg++;
				docom = ddelete;
				break;
			case 'x':
				xflg++;
				docom = extract;
				break;
			case 't':
				tflg++;
				docom = tellar68;
				break;
#ifdef DRI
			case 'w':
#else
			case 'p':
#endif
				pflg++;
				docom = prshort;
				break;
			case 'v':
				vflg++;
				break;
			case '-':
				break;
			default:
				printf("%s: invalid option flag: %c\n",myname,*--p1);
				endit();
		}
	}
	uflg = rflg+dflg;
	if( (uflg+xflg+tflg+pflg) != 1 ) {
		printf("%s: one and only one of 'rdxt' flags required\n",myname);
		endit();
	}
	psflg = aflg+bflg;
	if( psflg > 1 ) {
		printf("%s: only one of 'abi' flags allowed\n",myname);
		endit();
	}
	if( psflg && (rflg != 1) ) {
		printf("%s: 'abi' flags can only be used with 'r' flag\n",myname);
		endit();
	}
	arname = *ap++;
	if( (arfp = openar(arname,rflg)) == NULL && (tflg+xflg+bflg+aflg+dflg) ) {
		printf("%s: no such file '%s'\n",myname,arname);
		endit();
	}
	if( i == 0 && tflg ) {
		listall();
		endit();
	}
	if( i == 0 && xflg ) {
		exall();
		endit();
	}
	if( i <= 0 )
		goto usage;
	if( libmagic == LIBRMAGIC && uflg )
		printf("%s: warning, changing a random access library\n",myname);
	if (!pflg && !tflg) {	/* 20 sep 83 */
		tempname = mktemp(TMPNAME);
		if( (tempfd = fopen(tempname,"w")) == NULL ) {
			printf("%s: can't create %s\n",myname,tempname);
			endit();
		}

		if( lputw(&libmagic,tempfd) != 0 ) {
			char buf[128];
			sprintf(buf,"%s: write error on magic number",myname);
			perror(buf);
		}
	}

/* read archive, executing appropriate commands */
	while( matchflg == 0 && nextar() ) {
		docopy = 1;
		if( !psflg ) {
			for (j = 0; j < i; j++) {
				if( _strcmp( fnonly(ap[j]), &lp->lfname[0]) == 0 ) {
					docopy = 0;
					(*docom)(ap[j]);
					i--;
					while( j < i ) {
						ap[j] = ap[j+1];
					j++;
					}
				}
			}
		}
		else if( _strcmp(psname,&lp->lfname[0]) == 0) {
			docopy = 0;
			for (j = 0; j < i; j++)
				(*docom)(ap[j]);
			i = 0;
			psflg = 0;
		}
		if( docopy )
			skcopy(uflg);
	}

/* deal with the leftovers */
	if( i > 0 ) {
		for (j = 0; j < i; j++) {
			if( rflg )
				(*docom)(ap[j]);
			else
				printf("%s not found\n",ap[j]);
		}
	}
	(*docom)(0L);

	if(tflg || pflg)	/* 20 sep 83, don't need to do this stuff... */
		endit();

/* make temp file the archive file */
#ifndef vax11c
#ifndef DRI
	if( stat(tempname,&tstat) < 0 )  {
		printf("%s: can't find %s\n",myname,tempname);
		endit();
	}
	if( arfp != NULL ) {
		if( stat(arname,&astat) < 0 ) {
			printf("%s: can't find %s\n",myname,arname);
			endit();
		}
		if( (astat.st_nlink != 1) || (astat.st_dev != tstat.st_dev) ) {
			fclose(arfp);
			tmp2ar();
		}
		else if( (unlink(arname) == -1) ) {
			printf("%s: can't unlink old archive\nnew archive left in %s\n",
				myname,tempname);
			tempname = 0;	/* keeps endit from removing the archive */
		}
		else if( link(tempname,arname) < 0 ) {
			if( copy(tempname,arname) < 0 ) {
				printf("%s: can't link to %s\nnew archive left in %s\n",
					myname,arname,tempname);
				tempname = 0;
			}
		}
	}
	else {
		if( (arfp = fopen(arname,"w")) == NULL ) {
			printf("%s: can't create %s\narchive left in %s\n",myname,arname,tempname);
			tempname = 0;	/* keeps endit from removing the archive */
			endit();
		}
		if( stat(arname,&astat) < 0 ) {
			printf("%s: can't find %s\n",myname,arname);
			endit();
		}
		fclose(arfp);
		if( astat.st_dev != tstat.st_dev )
			tmp2ar();
		else if( (unlink(arname) < 0) || (link(tempname,arname) < 0) ) {
			printf("%s: can't link to %s\nnew archive left in %s\n",
				myname,arname,tempname);
			tempname = 0;	/* keeps endit from removing the archive */
		}
	}
#else
	tmp2ar();
#endif
#else
	tmp2ar();
#endif
	endit();
}

FILE *
openar(arp,crfl)
char *arp;
short crfl;
{
	register FILE *i;
	unsigned short ib;

	if( (i = fopen(arp,"r")) == NULL ) {	/* does not exist */
		areof = 1;
		return(NULL);
	}
	if( lgetw(&ib,i) != 0 || (ib != LIBMAGIC && ib != LIBRMAGIC) ) {
notar:
		printf("%s: not archive format: %s %o\n",myname,arp,ib);
		endit();
	}
	libmagic = ib;	/* use the same magic number */
	return(i);
}

/* execute one command -- call with filename or 0 */

short
tellar68(ap)
char *ap;
{
	register char *p;
	register short i;
	register char *p1;

	if( ap != -1 && ckafile(ap) )
		return;
#ifndef vax11c
	if( vflg ) {		/* long list */
		pmode(lp->lfimode);
		printf(" %d/%d ",lp->luserid,lp->lgid);
#  ifdef V6
		plong("%6ld",lp->lfsize);
#  else
		printf("%6ld",lp->lfsize);
#  endif
#ifndef DRI
		p1 = ctime(&lp->lmodti);
		p1[24] = '\0';
		p1 += 4;
		printf(" %s  ",p1);
#else
		printf("  ");
#endif
	}
#endif
	pfname();
	skcopy(0);
}

pfname()
{
	register char *p;
	register i;

	p = &lp->lfname[0];
	i = LIBNSIZE;
	while( *p && i ) {
		putchar(*p++);
		i--;
	}
	putchar('\n');
}

short
replace(name)
char *name;
{
	register short i;
	register FILE *ifd;
#ifndef DRI
	register struct stat *stp;	/* 11 apr 83, struct stat */
	struct stat stbuf;
#else
	long filesize();
#endif
#ifdef V6
	long l;
#endif

#ifndef DRI
	stp = &stbuf;
#endif
	if( name == 0 ) {
		if( bflg && areof == 0 ) {
			if( fseek(arfp,-(SEEKTYPE)LIBHDSIZE,1) == -1 )
				printf("%s: fseek error\n",myname);
		}
		cprest();
		return;
	}
#ifndef DRI
#ifndef vax11c
	if( stat(name,stp) < 0 ) {
		printf("%s: can't find %s\n",myname,name);
		endit();
	}
#endif
#endif
	if( (ifd = fopen(name,"r")) == NULL ) {
		printf("%s: can't open %s\n",myname,name);
		endit();
	}
#ifdef vax11c
	if(getchd(ifd,&chdr1) < 0) {
		printf("%s: can't read %s\n",myname,name);
		endit();
	}
#endif
	if( areof && psflg ) {
		printf("%s: %s not in library\n",myname,psname);
		endit();
	}
	if( (bflg|aflg) && matchflg == 0 ) { /* copy archive before appending */
		if( aflg )
			skcopy(1);
		matchflg++;
	}
	copystr(name,&lp->lfname[0],LIBNSIZE);
	if( areof|aflg )
		inform('a');
	else if( bflg )
		inform('i');
	else {
		inform('r');
		skcopy(0);		/* skip old copy */
	}
#ifndef vax11c
#ifndef DRI
	lp->luserid = stp->st_uid;
	lp->lgid = stp->st_gid;
	lp->lfimode = stp->st_mode;
#  ifdef V6
	l = mklong(stp->st_mtime[0],stp->st_mtime[1]);
	lp->lmodti = l;
	l = mklong(stp->st_size0,stp->st_size1);
	lp->lfsize = l;
#  else
	lp->lmodti = stp->st_mtime;
	lp->lfsize = stp->st_size;
	cp1file(ifd,tempfd,WHDR+OEVEN,name,tempname);
#  endif
#else
	lp->luserid = 0;
	lp->lgid = 0;
	lp->lfimode = 0666;
	lp->lmodti = 0;
	lp->lfsize = filesize(ifd,name);
	cp1file(ifd,tempfd,WHDR+OEVEN,name,tempname);
#endif
#else
	lp->lfsize = chdr1.ch_tsize + chdr1.ch_dsize + chdr1.ch_ssize +
		sizeof(struct hdr);
	if(chdr1.ch_rlbflg == 0)
		lp->lfsize += chdr1.ch_tsize + chdr1.ch_dsize;
	cp1file(ifd,tempfd,CHDR+WHDR+OEVEN,name,tempname);
#endif
	fclose(ifd);
}

#ifdef DRI
long filesize(fdp,fname)
FILE *fdp;
char *fname;
{
	struct hdr tcout;
	long curoffs, fseek();
	register long size;
	register short *p;
	register int i;

	if ((curoffs = fseek( fdp, 0l, 1 )) < 0)
		perror("File Seek error");
	if (fseek( fdp, 0l, 0 ) != 0)
		perror("File Seek error");
	if (fread( &tcout, sizeof( tcout ), 1, fdp ) != 1)
		perror("Read error");
	if (fseek( fdp, curoffs, 0 ) != curoffs)
		perror("File seek error");
	if( tcout.ch_magic != MAGIC )
		fprintf(stderr,"not object file: %s\n",fname);
	size = tcout.ch_tsize + tcout.ch_dsize;
	if( tcout.ch_rlbflg == 0 )
		size += size;
	size += tcout.ch_ssize;
	size += sizeof tcout;
	return(size);
}
#endif

short
ddelete(ap)
char *ap;
{
	if( ap == 0 ) {
		cprest();
		return;
	}
	inform('d');
	skcopy(0);
}

short
extract(ap)
char *ap;
{
	register FILE *ofd;
	register i;

	if( ckafile(ap) )
		return;
	if( (i = creat(ap,CDEFMODE)) < 0 ) {
		printf("%s: can't create %s\n",myname,ap);
		endit();
	}
	ofd = FDopen(i,"w");
	inform('x');
	cp1file(arfp,ofd,IEVEN,arname,ap);
	fclose(ofd);
}

short
prshort(ap)
char *ap;
{

	if( ckafile(ap) )
		return;
#ifdef DRI
		/* Change output to be a binary file */
	stdout->_flag &= ~_IOASCI;
	_fds[STDOUT].flags &= ~ISASCII;
#endif
	cp1file(arfp,stdout,IEVEN,arname,"std output");
}

short
endit()
{

	if( tempname )
		unlink(tempname);
	exit(0);
}

/* list all file in the library */

listall()
{

	while( nextar() )
		tellar68((char *)-1);
}

/* read next ar file header shorto libhd */

nextar()
{
	if( areof || getarhd(arfp,&libhd) == EOF || feof(arfp) ||
	    ((libhd.lfsize == 0) && (*libhd.lfname == '\0')) ) {
		areof++;
		return(0);
	}
	return(1);
}

/* call with cpflag = 0 for skip, cpflag = 1 for copy */
skcopy(cpflag)
short cpflag;
{
	register SEEKTYPE l;
	register short i;

	if( areof )
		return;
	l = lp->lfsize;
	if( l&1 )
		l++;
	if( cpflag ) {
		inform('c');
		cp1file(arfp,tempfd,WHDR+OEVEN+IEVEN,arname,tempname);
	}
	else {
		if( fseek(arfp,l,1) == -1 ) {
			printf("%s: seek error on library\n",myname);
			endit();
		}
	}
}

char *mktemp(ap)
char *ap;
{
	register char *p;
	register short i,j;

	i = getpid();		/* process id */
	p = ap;
	while( *p )
		p++;
	for( j = 0; j < 5; j++ ) {
		*--p = ((i&7) + '0');
		i >>= 3;
	}
	return(ap);
}

short m1[] = { 1, ROWN, 'r', '-' };
short m2[] = { 1, WOWN, 'w', '-' };
short m3[] = { 1, XOWN, 'x', '-' };
short m4[] = { 1, RGRP, 'r', '-' };
short m5[] = { 1, WGRP, 'w', '-' };
short m6[] = { 1, XGRP, 'x', '-' };
short m7[] = { 1, ROTH, 'r', '-' };
short m8[] = { 1, WOTH, 'w', '-' };
short m9[] = { 1, XOTH, 'x', '-' };

short *m[] = { m1, m2, m3, m4, m5, m6, m7, m8, m9};

pmode(aflg1)
short aflg1;
{
	register short **mp;

	for( mp = &m[0]; mp < &m[9]; )
		select(*mp++,aflg1);
}

select(pairp,flg)
short *pairp;
short flg;
{
	register short n, *ap, f;

	ap = pairp;
	f = flg;
	n = *ap++;
	while( --n >= 0 && (f&*ap++) == 0 )
		ap++;
	putchar(*ap);
}

inform(cc)
char cc;
{
	if( vflg ) {
		putchar(cc);
		putchar(' ');
		pfname();
	}
}

copystr(ap1,ap2,alen)
char *ap1, *ap2;
{
	register char *p1, *p2;
	register short len;
	extern char *strpbrk();

	p1 = ap1;
	while ((p2 = strpbrk( p1, DIRSEP )) != (char *)0)
		p1 = p2 + 1;

	p2 = ap2;
	len = alen;
	while( len ) {
		if( ! (*p2++ = *p1++) )
			break;
		len--;
	}
	while( --len > 0 )
		*p2++ = '\0';
}

#ifdef V6
long
mklong(ai1,ai2)
{
	long l;

	l.hiword = ai1;
	l.loword = ai2;
	return(l);
}

plong(num)
long num;
{
}
#endif

cprest()
{

	while( nextar() )
		skcopy(1);		/* copy rest of library */
}

cp1file(ifd,ofd,aflags,iname,oname)
FILE *ifd, *ofd;
short aflags;
char *iname, *oname;
{
	register short i;
	register long l;
	register short flags, sz;
	char str[50];

	flags = aflags;
	if( flags&WHDR ) {
		if( putarhd(ofd,&libhd) != 0 ) {
iwrerr:
			sprintf(str,"%s: write error on %s",myname,oname);
			perror(str);
			endit();
		}
	}
#ifdef vax11c
	/** - bms - write cout header to archive file for VMS */
	if( flags & CHDR ) {
		if (putchd(ofd,&chdr1) != 0 ) {
			sprintf(str,"%s: write error on CHDR %s",myname,oname);
			perror(str);
			endit();
		}
		l = lp->lfsize - sizeof(struct hdr);
	}
	else
#endif
	l = lp->lfsize;
	while( l ) {
		if( l < BUFSIZ )
			sz = l;
		else
			sz = BUFSIZ;
		if( (i = fread(buff,sizeof (char),sz,ifd)) == NULL ) {
			sprintf(buff,"%s: read error",myname);
			perror(buff);
			endit();
		}
		if( fwrite(buff,sizeof (char),i,ofd) == NULL )
			goto iwrerr;
		l -= i;
	}
	if( flags&OEVEN ) {
		if( lp->lfsize&1 )
			fwrite("",sizeof (char),1,ofd);
	}
	if( flags&IEVEN )
		if( lp->lfsize&1 )
			fread(buff,sizeof (char),1,ifd);
}

ckafile(ap)
char *ap;
{
	if( ap == 0 || *ap == 0 )
		endit();
	if( areof ) {
		printf("%s: %s not in archive file\n",myname,ap);
		return(1);
	}
	return(0);
}

exall()
{
	while( nextar() )
		extract(lp->lfname);
}

tmp2ar()
{
	register short n,ifd,ofd;

	if( (ofd = creat(arname,DEFMODE)) < 0 ) {
		printf("%s: can't create %s\narchive left in %s\n",myname,arname,tempname);
		tempname = 0;	/* keeps endit from removing the archive */
		return;
	}
	fclose(tempfd);
	if( (ifd = open(tempname,0)) < 0 ) {
		printf("%s: failed to open %s\n",myname,tempname);
		return;
	}
	while( (n = read(ifd,buff,BUFSIZ)) > 0 )
		write(ofd,buff,n);
	tempfd = FDopen(ifd,"r");
}

char *
fnonly(s)
char *s;
{
	register char *p, *r;
	extern char *strpbrk();

	r = s;
	while ((p = strpbrk( r, DIRSEP )) != (char *)0)
		r = p + 1;
	return(r);
}

/* this is a copy routine for the cross device archive creation */
copy(from,to)
char *from, *to;
{
	register short ifd, ofd, len;

	if( (ofd = open(to,WRITE)) == -1 ) {
		if( (ofd = creat(to,DEFMODE)) == -1 )
			return(-1);
	}
	if( (ifd = open(from,READ)) == -1 ) {
		close(ofd);
		unlink(to);
		return(-1);
	}
	
	while( (len = read(ifd,buff,sizeof buff)) > 0 )
		write(ofd,buff,len);

	close(ifd);
	close(ofd);
}

/*
**	ptr = pointer to the first occurrence in s1 of any character
**	      from s2.  ptr is NULL if no character from s2 exists in s1.
**
*/

static char *strpbrk(s1, s2)
char	*s1, *s2;
{
	register	char	*ts1;	/* temp s1 */
	register	char	*ts2;	/* temp s2 */

	/* compare each character in s1 to all characters in s2 */
	/* if match is found return pointer to position in s1 */
	for(ts1 = s1; *ts1; ts1++)
		for(ts2 = s2; *ts2; ts2++)
			if(*ts2 == *ts1)
				return(ts1);

	return((char *)0);
}

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
