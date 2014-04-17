/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module PROTECT :  copy-protection (must be in main overlay)

   WARNING:  Don't optimize protect.o!

	entry points :	trash_vecs, kill_exec
						sync_check, sync_protect, disk_protect
						set_rs232, start_prot, end_prot

******************************************************************************/

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "externs.h"		/* global variables */

	/* local constants */
#define flock   0x43E
#define diskctl 0xFFFF8604L
#define fifo    0xFFFF8606L
#define gpip    0xFFFFFA01L
#define dmahigh 0xFFFF8609L
#define dmamid  0xFFFF860BL
#define dmalow  0xFFFF860DL
#define cmdreg  0x80
#define trkreg  0x82
#define secreg  0x84
#define datareg 0x86

/*
	The disk protection looks for two "signatures."
	Signature 1:
	3F3C		move.w #?,-(a7)		?<
	4E5E		unlk A6					N^				sig1
	4E41		trap #1					NA
	Signature 2:
	4E75		rts						Nu
	4267		clr.w -(a7)				Bg
	4E56		link ?,?					NV				sig2
*/
	
/* local globals ............................................................*/

int errcnt,chrcnt,crc;					/* plover */
int time0,time1,time2,time3;			/* xyzzy */
int drive=0;								/* read5times */
int sig1,sig2;

start_prot()
{
#if PROTFLAG
	/* tuning for checksum of this module -- see main.c for correct value */
	asm { dc.w	0xC291 }
	/* this function must be first in this module */
#endif
}	/* end start_prot() */

/* kill/restore the exec() function .........................................*/

kill_exec(kill)
int kill;		/* 1= kill it, 0= restore it */
{
#if PROTFLAG
	int exec(),end_exec();				/* -->start and -->end of exec() */
	static long killfactor;

	/* "kill" means add a word to every instruction in exec(),
		"restore" means subtract the word */
	if (kill)
	{
		killfactor= *(long*)(HZ200);
		killfactor += *(long*)(0x10);
		killfactor += *(long*)(0x24);
		killfactor &= 0xffffL;			/* use low word only */
	}
	else
		killfactor= -killfactor;

	asm {
		lea		exec,a0
		lea		end_exec,a1
		move.l	a1,d0
		sub.l		a0,d0
		lsr.l		#1,d0						; d0.l = # words to be killed/restored
		move.l	killfactor(a4),d1		; d1.w = kill word
	kill_loop:
		add.w		d1,(a0)+
		subq.w	#1,d0
		bgt		kill_loop
	}
#endif
}	/* end kill_exec() */

/* trash the illegal and trace vectors ......................................*/

trash_vecs()
{
#if PROTFLAG
	static long old10,old24;
	long new10,new24;
	register long diff10,diff24;
	int trash_vecs();

	/* What's there now?  What was there before?  Has it changed? */
	new10= *(long*)(0x10);
	new24= *(long*)(0x24);
	if (old10)
	{
		diff10= new10-old10;
		asm {
			lea	trash_vecs,a0
			add.l	diff10,(a0)
		}
	}
	if (old24)
	{
		diff24= new24-old24;
		asm {
			lea	trash_vecs,a0
			add.l	diff24,(a0)
		}
	}
	asm {
		move.l	HZ200,0x10
		move.l	0x10,old10(a4)
		move.l	HZ200,0x24
		move.l	0x24,old24(a4)
	}
#endif
}	/* end trash_vecs() */

end_trash() { }	/* has to come right after trash_vecs() */

/* simple check for sync box ................................................*/
/* returns 0= SYNCBOX file but no sync box, else returns 1 */

sync_check()
{
	int fhand,retry;
	int result=1;
	int plover();

#if PROTFLAG
	fhand= Fopen("\\SYNCBOX",0);
	if (fhand>0)
	{
		Fclose(fhand);
		do
		{
			result= !plover();
			retry= result ? 2 : form_alert(1,CHEKSYNC);
			if (retry==2) result=1;
		}
		while (retry==1);
	}
#endif
	return result;
}	/* end sync_check() */

extern plover();
asm {
plover:
	bsr		clrcrc		
	move.w	#0,errcnt(a4)
	move.w	#36,chrcnt(a4)

	move.w	#0x1b,d0	
	bsr		xmit
 
	move.w	#10000,d0
dumb:			nop
	dbf		d0,dumb	

rubbish:
	bsr		rcvstat	
	tst.w		d0
	beq		empty	

	bsr		recv	
	bra		rubbish	

empty:
	move.w	#63,d0	
	bsr		xmit

copywait:
	bsr		crwait	
	cmpi.b	#':',d0	
	bne		copywait

docrc:
	bsr		crwait	
	bsr		addcrc	
	subq.w	#1,chrcnt(a4)
	bne		docrc	

	bsr		fincrc
	move.w	crc(a4),d0
	ori.l		#0xffff0000L,d0
	subi.l	#0xffff008fL,d0
	rts

xmit:
	move.w	d0,-(a7)
	move.w	#1,-(a7)
	move.w	#3,-(a7)
	trap		#13
	addq.w	#6,a7
	rts

recv:
	move.w	#1,-(a7)
	move.w	#2,-(a7)
	trap		#13
	addq.w	#4,a7
	rts

rcvstat:
	move.w	#1,-(a7)
	move.w	#1,-(a7)
	trap		#13
	addq.w	#4,a7
	rts

crwait:
	bsr		rcvstat
	tst.w		d0
	beq		nogo	
	move.w	#0,errcnt(a4)
	bra		recv	

nogo:
	move.w	errcnt(a4),d0
	addq.w	#1,d0	
	cmpi.w	#5000,d0
	bne		stillgo	
	addq.w	#4,a7	
	moveq		#1,d0	
	rts		
stillgo:
	move.w	d0,errcnt(a4)
	bra		crwait	

clrcrc:
	move.w	#0,crc(a4)
	rts

addcrc:
	moveq		#7,d1
	move.w	crc(a4),d2
crcloop:
	lsl.b		#1,d0
	roxl.w	#1,d2
	bcc		skipit
	eori.w	#0x8005,d2
skipit:
	dbf		d1,crcloop
	move.w	d2,crc(a4)
	rts
	
fincrc:
	moveq		#0,d0
	bsr		addcrc
	moveq		#0,d0
	bsr		addcrc
	rts

}	/* end plover() */

/* set/restore rs232 ........................................................*/

set_rs232(set)
int set;		/* 1= set, 0= restore */
{
#if PROTFLAG
	static char savectl_d,savedat_d,xonmode,mfpctrl;
	register int i,j,k;

	if (set)
	{
		/* save rs232 baud rate */
		/* warning!  can't use max() here, because byte at FFFA25 can
			change in the middle of the line! */
		for (i=j=0; i<100; i++)
		{
			k= *(char*)(0xFFFFFA25L) ;
			j= max(j,k);
		}
		for (i=1; j>i; i<<=1) ;
		savectl_d= *(char*)(0xFFFFFA1DL);
		savedat_d= i;

		/* save XON/XOFF and MFP stuff */
		xonmode= *(char*)( Iorec(0)+32L );
		mfpctrl= *(char*)( 0xFFFFFA29L );

		/* configure rs232 */
		asm {
			move.w	#-1,-(a7)
			move.w	#1,-(a7)
			move.w	#1,-(a7)
			move.w	#0x88,-(a7)
			move.w	#0,-(a7)
			move.w	#1,-(a7)
			move.w	#15,-(a7)
			trap		#14
			adda.l	#14,a7

			move.w	#24,-(a7)
			move.w	#30,-(a7)
			trap		#14
			addq.w	#4,a7
		}
	}
	else
	{
		*(char*)( Iorec(0)+32L ) = xonmode;
		*(char*)(0xFFFFFA29L) = mfpctrl;
		Offgibit(0xef);
		*(int*)(Iorec(0)+6L)= *(int*)(Iorec(0)+8L);
		*(char*)(0xFFFFFA1DL) = savectl_d;
		*(char*)(0xFFFFFA25L) = savedat_d;
	}
#endif
}	/* end set_rs232() */

/* check for authenticity of sync box .......................................*/

#if PROTFLAG

extern sync_protect();
int xyzzy(),end_xyzzy(),disk_protect(),mouse_enable();
asm {
sync_protect:
	clr.w		-(a7)			; disable mouse
	jsr		mouse_enable
	addq.w	#2,a7

	move.l	HZ200,d0		; wait 5 ms (1/200)
sync_loop:
	move.l	HZ200,d1
	sub.l		d0,d1
	cmpi.l	#1,d1
	blt		sync_loop

	jsr		xyzzy			; should return $604
	andi.w	#0x7F,d0		; table has 128 entries
	lsl.w		#1,d0			; table indexed by words
	lea		synctable,a0
	lea		disk_protect,a1
	move.w	0(a0,d0),(a1)
	move.w	#1,-(a7)		; enable mouse
	jsr		mouse_enable
	addq.w	#2,a7

	lea		xyzzy,a0		; self-destruct
	lea		end_xyzzy,a1
	move.l	a1,d0
	sub.l		a0,d0
killxyzzy:
	clr.w		(a0)+
	subq.l	#2,d0
	bgt		killxyzzy
	rts

synctable:
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,   0x4e75,   0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
	dc.w 0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56,0x4e56
}

#else

sync_protect() { }

#endif

extern xyzzy();	/* returns 0 for box is ok, not 0 for box is bad */
asm {
xyzzy:
	movem.l	d1-a6,-(a7)
	bsr		_xyzzy
	movem.l	(a7)+,d1-a6
	rts

_xyzzy:
	move.w	#1,time0(a4)
	move.w	#1,time1(a4)
	move.w	#1,time2(a4)
	move.w	#1,time3(a4)

/* shout at STync box */
	move		#63,-(a7)
	move		#1,-(a7)
	move		#3,-(a7)
	trap		#13
	addq.w	#6,a7

	move		SR,-(a7)
	ori.w		#0x700,SR

/* set up mfp parallel port for polling */
	move.b	0xfffffa05L,d0		; mfp direction reg
	andi.b	#0xBF,d0				; bit 6= input
	move.b	d0,0xfffffa05L

/* wait for 1st pulse */
wait1:
	btst		#6,0xfffffa01L
	beq		wait2
	addq.w	#1,time0(a4)
	bcs		gogo
	bra		wait1

/* wait for end of pulse */
wait2:
	btst		#6,0xfffffa01L
	bne		wait3
	addq.w	#1,time1(a4)
	bcs		gogo
	bra		wait2

/* wait for start of second pulse */
wait3:
	btst		#6,0xfffffa01L
	beq		wait4
	addq.w	#1,time2(a4)
	bcs		gogo
	bra		wait3

/* wait for end of second pulse */
wait4:	
	btst		#6,0xfffffa01L
	bne		gogo
	addq.w	#1,time3(a4)
	bcs		gogo
	bra		wait4

/* test for acceptable range */
gogo:
	move.w	time1(a4),d0
	cmpi		#36,d0				; compare lower limit
	bgt		goodlow				; we assume no future STs will run slower!
	move.w	time2(a4),d0
	lsl.w		#8,d0					; muck things up abit
	move.w	d0,time2(a4)
	move.w	time3(a4),d0
	lsr.w		#3,d0
	move.w	d0,time3(a4)
	bra		ratio

goodlow:
	cmpi		#160,time1(a4)		; compare upper limit
	blt		ratio					; assume 32 Mhz equiv high end
	lsl.w		#7,d0					; rain on Mr. Nosey's parade
	move.w	d0,time3(a4)
	eori.w	#0xAA,time2(a4)

/* test for proper ratio */
ratio:
	move.w	#64,d0
	mulu		time1(a4),d0		; t1 * 64
	divu		time2(a4),d0		; / t2
	andi.l	#0x0000ffffL,d0	; clear out remainder
	subq.w	#8,d0					;  - 8
	divu		#20,d0				; / 20 = 4
	andi.l	#0x0000ffffL,d0	; clear out remainder

	move.w	#64,d1
	mulu		time3(a4),d1		; t2 * 64
	divu		time2(a4),d1		; / t2
	andi.l	#0x0000ffffL,d1	; clear out remainder
	addq.w	#2,d1					; + 2
	divu		#20,d1				; / 20 = 6
	andi.l	#0x0000ffffL,d1	; clear out remainder

	lsl.l		#8,d1					; make magic #
	or.l		d1,d0

	move		(a7)+,SR
	rts
end_xyzzy:
}	/* end xyzzy() */

/* H-Lock protection ........................................................*/

#if PROTFLAG

disk_protect()
{
	int bad;
	char *ptr;

	ptr= (char*)cnxscrsave;

	/* force drive A access so that system will prompt for a disk,
		if there isn't already one in the drive */
	Fopen("A:\\ERTYKITY",0);	/* presumably this fails! */

	/* simple copy protection -- give user chance to insert key disk */
	do
	{
		bad=0;
		if (!Floprd(ptr,0L,0,1,0,0,1))
			if ((ptr[8]!='E')||(ptr[9]!='R')||(ptr[10]!='T'))
				bad=1;
		if (bad==1)
			if (form_alert(1,CHEKKEYDISK)==1)
				bad= -1;
	}
	while (bad<0);

	if (bad)
		return ('K'+'I'+'T'+'Y');
	else
		return _disk_protect();
}

extern _disk_protect();
int read5times(),evnt_multi(),end_trash();
asm {
_disk_protect:
	jsr		read5times
	move.w	d0,d1			; should be $4ef9
	moveq		#12,d2
	lsr.w		d2,d1			; should be 4
	moveq		#127,d2		; assume at least 128 entries in jump table
	move.l	a5,a0
jmp_loop:						; a0 --> jmp X.L
	move.w	d0,(a0)+			; a0 --> X.L
	adda.w	d1,a0				; a0 --> next jump table entry
	dbf		d2,jmp_loop
	lea		evnt_multi,a0
	move.w	sig2(a4),(a0)
	lea		end_trash,a0
	subq.w	#4,a0
	move.w	sig1(a4),(a0)
	rts
}

#else

disk_protect() { }

#endif

read5times()	/* returns $4EF9 (jmp) if disk is good */
{
#if PROTFLAG
	long weak1[5],weak2[5];
	long ndiffer;
	register int i,j,k;		/* save everything! */
	register int *aa,*bb;
	int secrd();

	floplock();
	restore();
	for (i=0; i<5; i++)
	{
		asm {
			move.l	cnxscrsave(a4),d0
			moveq		#0,d2
	      bsr		secrd
		}
		weak1[i]= *(long*)(cnxscrsave+6);
		sig1= *(int*)(cnxscrsave+2);
		asm {
			move.l	cnxscrsave(a4),d0
			add.l		#4000,d0
			moveq		#10,d2
			bsr		secrd
		}
		weak2[i]= *(long*)(cnxscrsave+4006);
		sig2= *(int*)(cnxscrsave+4004);
	}
	flopunlock();

	ndiffer=0;
	for (i=0; i<4; i++)
		for (j=i+1; j<5; j++)
			ndiffer += (weak1[i]!=weak1[j]);
	for (i=0; i<4; i++)
		for (j=i+1; j<5; j++)
			ndiffer += (weak2[i]!=weak2[j]);
	ndiffer += 15;			/* should be 20-35 */
	ndiffer /= 20;			/* should be 1 */
	ndiffer *= 0x4EF9;	/* high word of jmp instruction */
	return ndiffer;
#endif
}	/* end read5times() */

#if PROTFLAG

/* select/deselect a drive ..................................................*/

desel_drive()
{
	Ongibit(2*drive+2);		/* select drive */
	Ongibit(1);					/* select side A */
}	/* end desel_drive() */

sel_drive()
{
	drive ^= 1;
	desel_drive();
	drive ^= 1;
   Offgibit(drive ? 0x00FB : 0x00FD );
}	/* end sel_drive() */

/* delay loop ...............................................................*/

extern rwdelay();
asm {
rwdelay:
	move.l  d0,-(a7)
	moveq   #36,d0
rwdlylp:
	dbf     d0,rwdlylp
	move.l  (a7)+,d0
   rts
}	/* end rwdelay() */

/* read/write d4 <--> diskctl ...............................................*/

extern rdiskctl(),wdiskctl();
asm {
rdiskctl:
	bsr     rwdelay
	move.w  diskctl,d0
   bsr     rwdelay
	rts
wdiskctl:
   bsr     rwdelay
   move.w  d4,diskctl
   bsr     rwdelay
	rts
}

/* reset 1772 ...............................................................*/

extern reset1772();
asm {
reset1772:
	move.w  #cmdreg,(a3)
	move.w  #0xD0,d4
	bsr     wdiskctl
	moveq   #15,d0
r1772lp:
   dbf     d0,r1772lp
   bsr     rdiskctl
	rts
}	/* end reset1772() */

/* set DMA address ..........................................................*/

extern set_dma_addr();
asm {
set_dma_addr:						; d0.l = addr
	move.b  d0,dmalow				; must be done in low-mid-high order
   lsr.l   #8,d0
   move.b  d0,dmamid
   lsr.l   #8,d0
   move.b  d0,dmahigh
   rts
}	/* end set_dma_addr() */

/* write command to floppy ..................................................*/

extern flopcmd();
asm {
flopcmd:                        ; expects 1772 command in d4.w
	move.l  #0x00080000L,d5
   move.w  #cmdreg,(a3)
   bsr     rdiskctl
   btst    #7,d0
   bne     flopcmd1
   move.l  #0x00060000L,d5
flopcmd1:
   bsr     wdiskctl
flpcmdlp:
   subq.w  #1,d5
   bne     flopcmd2
   bsr     reset1772
   moveq   #1,d4
   rts
flopcmd2:
   btst    #5,gpip
   bne     flpcmdlp
   bsr     rdiskctl
   move.w  d0,d5
   moveq   #0,d4
   rts
}	/* end flopcmd() */

/* restore floppy ...........................................................*/

extern restore();
asm {
restore:
   moveq   #3,d4
   bsr     flopcmd
   bne     endrestore
   not.b   d5
   btst    #2,d5
endrestore:
   rts
}	/* end restore() */

/* seek .....................................................................*/

extern hseek();
asm {
hseek:                          ; d2.w = trk#
   lea     fifo,a3
   move.w  #datareg,(a3)
   move.w  d2,d4
   bsr     wdiskctl
   moveq   #0x13,d4
   bsr     flopcmd
   rts
}	/* end hseek() */

/* lock floppy ..............................................................*/

extern floplock();
asm {
floplock:
   move.w  #1,flock
   lea     fifo,a3
	bsr     sel_drive
   bsr     restore
   beq     endlock
   moveq   #10,d2
   bsr     hseek
   bsr     restore
endlock:
   rts
}	/* end floplock() */

/* unlock floppy ............................................................*/

extern flopunlock();
asm {
flopunlock:
   bsr     reset1772
   clr.w   flock

	move.l  HZ200,d0
unlocklp:
	move.l  HZ200,d1
	sub.l   d0,d1
	cmpi.l  #600,d1				; empirically
	blt	  unlocklp

   bsr     desel_drive
	rts
}	/* end flopunlock() */

/* read sector ..............................................................*/

extern secrd();
asm {
secrd:                          ; d2.w = sec#, d0.l = addr of 512-byte bufr
	lea     fifo,a3
	bsr     set_dma_addr
	move.w  #secreg,(a3)
	move.w  d2,d4
	bsr     wdiskctl
	move.w  #0x090,(a3)
   move.w  #0x190,(a3)
   move.w  #0x090,(a3)
   move.w  #1,d4
   bsr     wdiskctl
   move.w  #0x080,(a3)
   move.w  #0x80,d4
   bsr     wdiskctl

   move.l  #0x00080000L,d5
secrdlp:
   btst    #5,gpip         ; if FDC is done...
   bne     secrd1
   move.w  #0x090,(a3)
   move.w  (a3),d0
   btst    #0,d0
   bne     secrd2
   moveq   #2,d0
   rts
secrd2:
   move.w  #0x080,(a3)
   bsr     rdiskctl
   andi.l  #0x18,d0
   rts
secrd1:
   subq.w  #1,d5
   bne     secrdlp

   bsr     reset1772
   moveq   #1,d0
   rts                     ; returns error (if non-zero) in d0
}	/* end secrd() */

#endif

end_prot() { }	/* this function must be last in this module */

/* EOF */
