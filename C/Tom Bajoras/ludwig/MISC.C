/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module: MISC -- miscellaneous math, data management, etc.

	set_longs, set_words, set_bytes
	copy_longs, copy_words, copy_bytes, comp_bytes
	miditoa, tempotoa, pad_str, random, exact_val

******************************************************************************/

overlay "misc"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

	/* imported from GEM */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

	/* in init */
extern char *_base;

/* declare extern any asm entry points ......................................*/

extern int set_longs(),set_words(),set_bytes();
extern int copy_longs(),copy_words(),copy_bytes(),comp_bytes();

/* fill an array of longs ...................................................*/

asm {
set_longs:	/* 4(a7) --> array, 8(a7).w = # of longs, 10(a7).l = value */
	movea.l	4(a7),a0
	move.w	8(a7),d0
	move.l	10(a7),d1
	subq.w	#1,d0
	bge		loopsl
	rts
loopsl:
	move.l	d1,(a0)+
	dbf		d0,loopsl
	rts
}  /* end set_longs() */

/* fill an array of words ...................................................*/

asm {
set_words:	/* 4(a7) --> array, 8(a7).w = # of words, 10(a7).w = value */
	movea.l	4(a7),a0
	move.w	8(a7),d0
	move.w	10(a7),d1
	subq.w	#1,d0
	bge		loopsw
	rts
loopsw:
	move.w	d1,(a0)+
	dbf		d0,loopsw
	rts
}  /* end set_words() */

/* fill an array of bytes ...................................................*/

asm {
set_bytes:	/* 4(a7) --> array, 8(a7).w = # of bytes, 10(a7).w = value */
	movea.l	4(a7),a0
	move.w	8(a7),d0
	move.w	10(a7),d1
	subq.w	#1,d0
	bge		loopsb
	rts
loopsb:
	move.b	d1,(a0)+
	dbf		d0,loopsb
	rts
}  /* end set_bytes() */

/* copy an array of longs ...................................................*/

asm {
copy_longs:	/* 4(a7) --> from, 8(a7) --> to, 12(a7).w = # of longs */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.w	12(a7),d0
	subq.w	#1,d0
	bge		loopcl
	rts
loopcl:
	move.l	(a0)+,(a1)+
	dbf		d0,loopcl
	rts
}  /* end copy_longs() */

/* copy an array of words ...................................................*/

asm {
copy_words:	/* 4(a7) --> from, 8(a7) --> to, 12(a7).w = # of words */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.w	12(a7),d0
	subq.w	#1,d0
	bge		loopcw
	rts
loopcw:
	move.w	(a0)+,(a1)+
	dbf		d0,loopcw
	rts
}  /* end copy_words() */

/* copy an array of bytes ...................................................*/

asm {
copy_bytes:	/* 4(a7) --> from, 8(a7) --> to, 12(a7).w = # of bytes */
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.w	12(a7),d0
	subq.w	#1,d0
	bge		loopcb
	rts
loopcb:
	move.b	(a0)+,(a1)+
	dbf		d0,loopcb
	rts
}  /* end copy_bytes() */

/* compare an array of bytes ................................................*/
/* returns 0 if the two arrays are same, else returns non-0 */

asm {
comp_bytes:	/* 4(a7) --> array1, 8(a7) --> array2, 12(a7).w = # of bytes */
	moveq		#1,d0
	movea.l	4(a7),a0
	movea.l	8(a7),a1
	move.w	12(a7),d1
	subq.w	#1,d1
	bge		loopcmpb
	rts
loopcmpb:
	cmpm.b	(a0)+,(a1)+
	bne		comp_exit
	dbf		d1,loopcmpb
	clr.w		d0
comp_exit:
	rts
}  /* end comp_bytes() */

/* convert ascii string to integer ..........................................*/

atoi(strptr)   /* returns -1 if strptr is not an encoded integer */
register char *strptr;
{
	register int i,mult;
	register long result;

	asm {
		clr.l		result
		moveq		#1,mult

		clr.w		d1					; find out how many digits
lengloop:	
		tst.b		0(strptr,d1)
		beq		endleng
		addq.w	#1,d1
		mulu		#10,mult
		bra		lengloop
endleng:		
		subq.w	#1,d1				; get ready for dbf
		blt		bad				; error if null string
		divu		#10,mult
		andi.l	#0xFFFF,mult	; clear out high word of multiplier

loop:		
		clr.w		d0
		move.b	(strptr)+,d0
		beq		good				; string is null terminated
		sub.b		#'0',d0
		blt		bad				; error if character is < '0'
		cmp.b		#9,d0
		bgt		bad				; error if character is > '9'				
		mulu		mult,d0
		add.l		d0,result
		divu		#10,mult
		dbf		d1,loop			; error if string more than 6 digits
	good:
		move.l	result,d0
		bra		done
	bad:
		moveq		#-1,d0
	done:
	}	/* end asm */
}	/* end atoi() */

/* convert midi note number to ascii ........................................*/

miditoa(opt,i,str)
int opt;		/* 0 for sharps, 1 for flats */
register int i;
char *str;	/* --> 4 chars + null */
{
	char charbuf[3];

	if ( (i<0) || (i>127) )
		strcpy(str,"----");
	else
	{
		strcpy(str,opt ? chromaf[i%12] : chromas[i%12] ) ;
		i= i/12 - 2;
		if (i<0) { strcat(str,"-"); i*=(-1); }
		strcpy(charbuf,int1char[i]);
		strcat(str,charbuf);
	}
	pad_str(4,str);
}	/* end miditoa() */

/* convert tempo to ascii ...................................................*/

tempotoa(i,str)
register int i;
char *str;	/* 5 chars + null */
{
	i= 115200L / (i+24) ;	/* convert to 10*BPM */
	strcpy(str,int1char[(i/10)/100]);
	strcat(str,int2char[(i/10)%100]);
	strcat(str,".");
	strcat(str,int1char[i%10]);
}	/* end tempotoa() */

/* pad a string with spaces on right ........................................*/

pad_str(n,str)
int n;					/* byte offset to null at end of string */
register char *str;	/* pointer to a null-term'd string */
{
	register int i;
	
	for (i=0; str[i]!=0; i++) ;
	for ( ; i<n; i++) str[i]=' ';
	str[n]=0;
}	/* end pad_str() */

/* generate a random # ......................................................*/
/* returns a random # 0-top inclusive */

random(top)
int top;
{
	static long randseed;
	register long seed= randseed;

	/* first time random() has been called:  grab seed from system raw 200hz */
	if (!seed) {
		seed= *(long*)(0x4baL);
		seed |= (seed<<16);
	}
	/* this algorithm taken directly from BIOS */
	seed= 3141592621L*seed + 1L;
	randseed=seed;
	top= ((seed>>8)&127) % (top+1) ;
	return(top);
}	/* end random() */

/* round to simple rhythm ...................................................*/
/* returns a value 0-31 */

exact_val(j,dir)
register int j;		/* 0-31 */
int dir;					/* >0 increase, <0 decrease */
{
	register int i;

	j++;			/* convert to 1-32 */
	if ((j>=1)&&(j<=32))
	{
		for (i=0; i<10; i++) if (exactdur[i]>=j) break;
		j= (exactdur[i]==j)||(dir>0) ? exactdur[i] : exactdur[i-1] ;
	}
	return(j-1);
}	/* end exact_val() */

/* EOF misc.c */
