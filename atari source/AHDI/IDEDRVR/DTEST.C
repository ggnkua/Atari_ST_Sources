/*** dtest.c
 *
 *  DTEST.TTP  -- Disk/DMA test program
 *	gcc {-DVERBOSE} -o dtest.ttp dtest.c -liio
 *
 *  910315 JWTittsler	originally a wrapper for TT DMA test program
 *  910325 jwt	make the GetBPB() call only if given the -B switch
 *		show only first 10 errors/cycle, unless given -E switch
 *  910326 jwt	make clearing the buffers optional, setable fill value
 *		-L sets limit from base record; if set then -I specifies
 *		  increment from one cycle to next, if I==0 then random
 *		  blocks
 *  910404 jwt	ring bell on errors unless given the -q (quiet) switch
 *  910627 jwt	-T nn  enter standby mode before writes, pause nn ticks
 *		-U nn  enter standby mode before reads, pause nn ticks
 *		keywait at end of Usage() help screen
 */

#define VERSION "  Version of Jun 27 17:50:00 JST 1991"

#define OPTIONS "bBc:C:d:D:eEfFi:I:l:L:o:O:p:P:qQr:R:s:S:t:T:u:U:Zz"
#define	RECORDSIZE	(512L)
#define SLOP		(8L)	/* space between buffers (in bytes) */
#define	SHOWABLEERRORS	(10L)	/* default number of errors to show per pass */

/* hardware and OS address definitions */
#define	HZ200		((volatile long *)0x000004BAL)
#define	IDECOMMAND	((volatile short *)0xFFF0001CL)
#define	IDESTATUS	((volatile short *)0xFFF0001CL)

#define	IDEBUSY		(0x80)

/* IDE commands */
#define	IDESTANDBY	(0xE0)
#define IDEIDLE		(0xE1)

/* BIOS Definitions */
/* Bconxx() handles */
#define	CONSOLE		2

/* Rwabs() flags */
#define	READ		(0)
#define WRITE		(1)
#define	PHYSICAL	(8)
#define	PHYSREAD	(READ+PHYSICAL)
#define	PHYSWRITE	(WRITE+PHYSICAL)

#include <stdlib.h>
#include <stdio.h>
#include <osbind.h>
#include <ctype.h>
#include <unixlib.h>
#include <string.h>

extern int opterr,optind;
extern char *optarg;

long lErrors=0L;
int bAllErrors=0;
int bQuiet=0;
int nWritePause=-1;
int nReadPause=-1;

void Usage(void){
	puts("DTEST -B -E -F -Z -C nnnn -D nn -I nnnn \
-L nnnn -O n -P nnn -R nnnn -T nn -U nn");
	puts("  where:");
	puts("   -B       do getbpb() call");
	puts("   -E       show all errors {first 10/cycle}");
	puts("   -F       put buffer in Fast RAM");
	puts("   -Q       be quiet on errors");
	puts("   -Z       don't preset read buffers");
	puts("   -C nnnn  record count {40}");
	puts("   -D nn    TOS physical device number {0}");
	puts("   -I nnnn  increment {0, random if limit specified}");
	puts("   -L nnnn  limit to be added to base record number {0}");
	puts("   -O n     offset from long alignment {0}");
	puts("   -P nnn   read buffer preset value {0}");
	puts("   -R nnnn  base starting record number {100}");
	puts("   -T nnn   enter standby, pause nn sec before writes");
	puts("   -U nnn   enter standby, pause nn sec before reads");
	printf("\nStrike a key to continue...");  fflush(stdout);
	(void)Cconin();		/* swallow up character */
}

void StandbyPause(int nTickDelay){
long lOldSSP;
long lTimeOut;

	lOldSSP = Super(0L);	/* enter supervisor mode */

	/* make sure the drive is not busy, and clear any pending IRQ */
	while(*IDESTATUS & IDEBUSY) ;

	/* issue command to immediately enter STANDBY mode */
	*IDECOMMAND = IDESTANDBY;

	/* wait for BUSY to go away, and clear IRQ */
	while(*IDESTATUS & IDEBUSY) ;

	if(nTickDelay > 0) {
	    lTimeOut = *HZ200 + nTickDelay;
	    while(*HZ200 < lTimeOut) ;
	}

	(void)Super(lOldSSP);	/* return to user mode */
}

int GetNumArg(char *string){
	return(atoi(string));	/* someday this will handle hex and decimal */
}				/*  yeah, sure */

char *Myalloc(long size, short type){
int nTOSVersion, nTemp;
	nTemp = Sversion();
	nTOSVersion = (nTemp>>8) | ((nTemp&0xFF)<<8);	/* byte swap */
	if (nTOSVersion >= 0x0019) return (char *)Mxalloc(size, type);
	else if (type) return NULL;	/* old TOS only has one kind of RAM */
	else return (char *)Malloc(size);
}

void SetBuffer(unsigned char *pB, long lBufferSize, int nPass) {
register int i;
register unsigned char bVal;
	bVal = (unsigned char) nPass;
	for(i=0; i<lBufferSize; ++i){
	    *pB++ = bVal++;
	}
	memcpy(pB, "\0x11\0x22\0x33\0x44\0x55\0x66\0x77\0x88", 8);
}

int CompareBuffers(register unsigned char *p1, register unsigned char *p2,
	register unsigned char *p3, register long lBSize){
register long i;
register unsigned char c1,c2,c3;
unsigned char *wbuf;
long lErrorsThisCycle=0L;

	wbuf = p1;
	for(i=0; i<lBSize; ++i) {
	    c1 = *p1++;  c2 = *p2++;  c3 = *p3++;
	    if((c1 != c2) || (c1 != c3)) {
		++lErrors;
		++lErrorsThisCycle;
		--p1;
		if((lErrorsThisCycle <= SHOWABLEERRORS)||(bAllErrors))
		    printf("\nError @ wbuf 0x%08X (offset 0x%06X) \
Wr: %s0x%02X\033q Rd: %s0x%02X\033q 2nd Rd: %s0x%02X\033q",
			(long)(p1), (long)(p1-wbuf),
			((c1==c2)||(c1==c3)) ? "\033p" : "", c1,
			((c2==c1)||(c2==c3)) ? "\033p" : "", c2,
 			((c3==c1)||(c3==c2)) ? "\033p" : "", c3);
		++p1;
		if(Cconis() != 0) break;
	    }
	}
	if(lErrorsThisCycle) printf("\nErrors this cycle: %ld",
	    lErrorsThisCycle);
	return (int)(lErrorsThisCycle != 0);
}

void main(int argc, const char *argv[]){
int option;
int nOffset=0, nDevice=0, nBaseRecord=100, nRecord=100, nCount=40;
int nLimit=0, nIncrement=0;
int bFastRAM=0, bDoGetBPB=0, bDoBufferFill=1;
unsigned char *pBuffer,*pBuf1,*pBuf2,*pBuf3,cSeed;
long lBufferSize;
long lErrx;
int bHadError;
int nPass;
int nResult;

	puts("Disk R/W Through Rwabs()");
	puts(VERSION);

	while((option=getopt(argc, argv, OPTIONS)) != EOF)
	    switch (toupper(option)) {
	    case 'B':  bDoGetBPB=1; break;
	    case 'E':  bAllErrors=1; break;
	    case 'F':  bFastRAM=1; break;
	    case 'Q':  bQuiet=1; break;
	    case 'Z':  bDoBufferFill=0; break;
	    case 'C':  nCount = GetNumArg(optarg); break;
	    case 'D':  nDevice = GetNumArg(optarg); break;
	    case 'I':  nIncrement = GetNumArg(optarg); break;
	    case 'L':  nLimit = GetNumArg(optarg); break;
	    case 'O':  nOffset = GetNumArg(optarg); break;
	    case 'P':  cSeed = (unsigned char)GetNumArg(optarg); break;
	    case 'R':  nRecord = nBaseRecord = GetNumArg(optarg); break;
	    case 'T':  nWritePause = GetNumArg(optarg); break;
	    case 'U':  nReadPause = GetNumArg(optarg); break;
	    default:   Usage(); exit(1);
	    }

	lBufferSize = (long)nCount*RECORDSIZE;

	if((pBuffer=(unsigned char *)Myalloc(3L*(lBufferSize+SLOP)+10L,
		bFastRAM))==NULL){
	    printf("Unable to allocate transfer buffers\n");
	    exit(2);
	}

	pBuf1 = pBuffer;
	pBuf2 = pBuf1+lBufferSize+SLOP;
	pBuf3 = pBuf2+lBufferSize+SLOP;

#ifdef VERBOSE
	printf("Buffer size:  %08X\n", (long)lBufferSize);
	printf("    Buffer1:  %08X\n", (long)pBuf1);
	printf("    Buffer2:  %08X\n", (long)pBuf2);
	printf("    Buffer3:  %08X\n", (long)pBuf3);
	printf("     Offset:  %d\n", nOffset);
	printf("     Device:  %d\n", nDevice);
	printf("     Record:  %d\n", nRecord);
	if (nLimit) {
	    printf("      Limit:  %d\n", nLimit);
	    if(nIncrement) printf("  Increment:  %d\n", nIncrement);
	    else printf("  Increment:  Random\n");
	}
	printf("      Count:  %d\n", nCount);
#endif /* VERBOSE */

	printf("Are you SURE you want to trash media in TOS unit %d? ",
	    nDevice);
	fflush(stdout);
	gets((char *)pBuf1);

	if(toupper(*pBuf1) != 'Y') exit(1);

	if(bDoGetBPB) Getbpb(nDevice);		/* clear media change errors */

	nPass = 0;

	while(Cconis()==0){
	    ++nPass;
	    bHadError = 0;

	    printf("\rCycle: %6d  Record: %6d Errors: %6ld  ",
		nPass, nRecord, lErrors);
	    fflush(stdout);

	    /* if any WritePause is specified, issue standby command */
	    if(nWritePause >= 0){
		putchar('T');  fflush(stdout);
		StandbyPause(nWritePause);
	    }

	    /* write a known pattern to the disk */
	    SetBuffer(pBuf1, lBufferSize, nPass);
	    putchar('W');  fflush(stdout);
	    if(nResult=Rwabs(PHYSWRITE, pBuf1, nCount, nRecord, nDevice)){
		printf("%02X", nResult);
		++lErrors;
		bHadError = 1;
	    }

	    /* now preset the destination buffers */
	    if(bDoBufferFill){
		memset(pBuf2, cSeed, lBufferSize);
		memset(pBuf3, cSeed, lBufferSize);
	    }

	    /* read it in once */
	    if(nReadPause >= 0) {
		putchar('U');  fflush(stdout);
		StandbyPause(nReadPause);
	    }

	    putchar('R');  fflush(stdout);
	    if(nResult=Rwabs(PHYSREAD, pBuf2, nCount, nRecord, nDevice)){
		printf("%02X", nResult);
		++lErrors;
		bHadError = 1;
	    }

	    /* read it in a second time */
	    if(nReadPause >= 0) {
		putchar('U');  fflush(stdout);
		StandbyPause(nReadPause);
	    }

	    putchar('S');  fflush(stdout);
	    if(nResult=Rwabs(PHYSREAD, pBuf3, nCount, nRecord, nDevice)){
		printf("%02X", nResult);
		++lErrors;
		bHadError = 1;
	    }

	    /* now compare the two reads to the original */
	    putchar('C');  fflush(stdout);
	    bHadError += CompareBuffers(pBuf1, pBuf2, pBuf3, lBufferSize);

	    if(bHadError) {
		putchar('\n');
		if(bQuiet==0) putchar('\007');
	    } else putchar('.');
	    fflush(stdout);

	    /* set up a new starting record for the next cycle */
	    if(nLimit){		/* is the starting record allowed to change? */
		if(nIncrement){	/* a linear increment */
		    if((nRecord += nIncrement) > (nBaseRecord+nLimit))
			nRecord = nBaseRecord;
		} else 		/* a random distance up to limit away */
		    nRecord = nBaseRecord + (int)(Random()%(long)nLimit);
	    }
	}

	(void)Cconin();		/* swallow up character */
}
