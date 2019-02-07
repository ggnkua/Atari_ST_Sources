/*
 *		Megamax C inline ASM version of Twister.
 *		Converted from AS68 format  dlm  12/14/86.
 *		AS68 version by David Small before that date.
 *		Used for the MegAMin HD backup program.
 */

/* routine that are callable from C are: */
extern twister();

/* global variables */
int thedisk, dblsided, sectoroffset;   /* input parameters */
long buffer;

int badflag;					    /* bad sector error flag */

/* local variables */
static int theside, thetrack, twistsectorno, sectorno, retrycnt,
		 cdev, ctrack, csect, cside, ccount, A7t, interlv,
		 virgin, def_error, curr_err;
static long cdma, edma, tmpdma, saveA2;

/* now the defines (AS68 equ's) */

/*	tunable values */
#define retries   2 		/* default # of retries -1 */
#define midretry  1 		/* "middle" retry, when to reseek  */
#define timeout   0x40000	/* short timeout, motor already on */
#define ltimeout  0x60000	/* long timeout, to startup motor	*/

/*	Floppy state variables in DSB: RAM usage */
#define recal	   0xff00 	/* recalibrate flag 			*/
#define dcurtrack 0 		/* current track number			*/
#define dseekrt   dcurtrack+2 /* seek rate					*/
#define dsbsiz    dseekrt+2	/* size of a DSB				*/

/* hardware equates */
/* DMA chip		*/
#define diskctl	0xffff8604	/* disk controller data access */
#define fifo		0xffff8606	/* DMA mode control / status	 */
#define dmahigh	0xffff8609	/* DMA base high			 */
#define dmamid 	0xffff860b	/* DMA base mid			 */
#define dmalow 	0xffff860d	/* DMA base low			 */

/* 1170 select values	*/
#define cmdreg 	0x80 		/* select command register	*/
#define trkreg 	0x82 		/* select track register 	*/
#define secreg 	0x84 		/* select sector register	*/
#define datareg	0x86 		/* select data register		*/

/* GI sound chip (drive a/b select lines and side select) */
#define giselect	0xffff8800	/* (W) sound chip register select */
#define giread 	0xffff8800	/* (R) sound chip read data	*/
#define giwrite	0xffff8802	/* (W) sound chip write data	*/
#define giporta	0x0e 		/* GI register # for i/o port A */

/* 68901 mfp chip */
#define mfp		0xfffffa00	/* mfp base				*/
#define gpip		mfp+1		/* general purpose i/o		*/

/* misc defines */
#define seekrate 3
#define dsb0	  0xa06
#define dsb1	  0xa0a
#define flock	  0x43e

asm {		/* start of inline ASM */

/*
 *	All the following is munged code from AS68 (that's why the
 *	weird format).  The AS68 code was munged from the BIOS
 *	source.  And most of this is from the FDC article in Start
 *	issue number 3.
 *
 *	Anyway, we apologize for the mess, but heh it works.
 *
 *	Oh yes.  The labels are usually on nops, not empty lines.  Thats
 *	because AS68 occasionally pukes on labels on empty lines.  And
 *	I didn't take the time to remove them.  (Megamax doesn't care.)
 *
 */

;****************************************************************
; Twister: Faster formatter (zipformat) hack.  MM version	    *
; Copyright (c) 1986, 1987 START Magazine (as usual)		    *
; Written by David Y. Small & Dan Moore 				    *
;****************************************************************
;												    *
;			 Dedication:							    *
;												    *
;	 For Bill The Cat: because he's twisted, too.              *
;												    *
;****************************************************************
;
; code begins.
;
;  PASS ME THIS STUFF DAN! Then SHAVE! For God's sakes! What
; are you trying to do, look like Fidel Castro?
;
; And get SOME BEER in here okay? Sheesh!
;
; input integers (if coming from C):
;
; dblsided: 0000 or ffff
; thedisk: 0 = a, 1 = b
;*************************************************************


;********************************************************
; Frammatter									 *
;********************************************************
twister:	move.l	A2, saveA2(A4) 	; everything else saved by the Supexec

	   clr.w		badflag(A4)		; assume no errors
;
;*** Init vars for formatting loop
;
	   move.w  #0,thetrack(A4)	 ; start at track 0

	   move.w  #1,twistsectorno(A4) ; twister value
						 
trackloop: nop 			  ; comes here for subseq tracks


;***** FRONT SIDE ***********
;**** Setup stack: .. based on read sec command, tweaked for frammat

	   move.w  #0xe5e5,-(A7)    ; virgin data -- e5's work okay
	   move.l  #0x87654321,-(A7) ; magic # to make format work / fmt only
	   move.w  #1,-(A7) 	  ; sector interleave factor / fmt only
	   move.w  #0,-(A7) 	  ; ** side.w (relevant) / side: FRONT
	   move.w  thetrack(A4),-(A7)  ; ** track.w (relevant) / same
	   move.w  #10,-(A7)	  ; sector.w (irrelevant) / sectors per track
	   move.w  thedisk(A4),-(A7)	 ; ** device.w  (relevant) / same
	   move.l  #0,-(A7) 	  ; dummy.l (irreleveant) / same
	   move.l  buffer(A4),-(A7)	; ** buffer address.l (relevant) / same
	   jsr	 _flopfmt
	   adda.l  #24,A7		  ; Fix stack.
;****
; Jazz twistsectorno(A4). Look at what it ended up as; set it to
; the next track twist depending on that.
;
; It will end up as "+1" from the last sector formatted, because
; the formatter bumps it up.
;
	   cmpi.w  #1,twistsectorno(A4)	    ; 0-1 transition
	   beq	 fgoto1
	   cmpi.w  #9,twistsectorno(A4)	    ; 1-2 transition
	   beq	 fgoto2
	   cmpi.w  #7,twistsectorno(A4)	    ; 2-3 transition
	   beq	 fgoto3
	   cmpi.w  #5,twistsectorno(A4)	    ; 3-4 transition
	   beq	 fgoto4
	   cmpi.w  #3,twistsectorno(A4)	    ; 4-0 transition
	   beq	 fgoto0
	   
	   dc.b	0x4a
	   dc.b	0xfc 			 ; oops, die (illegal instruction)
;*****
; Really class coding, eh? Oh,well, it's easy and it works, which
; twelve other fancy ways of doing this *don't*.
;
fgoto1: move.w  #0x9,twistsectorno(A4)		; 9,a,1,2,3,4,5,6,7,8
	   bra	 fkeepformatting
fgoto2: move.w  #0x7,twistsectorno(A4)		; 7,8,9,a,1,2,3,4,5,6
	   bra	 fkeepformatting
fgoto3: move.w  #0x5,twistsectorno(A4)		; 5,6,7,8,9,a,1,2,3,4
	   bra	 fkeepformatting
fgoto4: move.w  #0x3,twistsectorno(A4)		; 3,4,5,6,7,8,9,a,1,2
	   bra	 fkeepformatting
fgoto0: move.w  #0x1,twistsectorno(A4)		; 1,2,3,4,5,6,7,8,9,a
	   bra	 fkeepformatting
	   nop
;*****
fkeepformatting: nop
;*****
; now, do a verify on those sectors.
;**** Setup stack: .. based on read sec command, tweaked for frammat

	   tst.w	 sectoroffset(A4)	; no verify if 11 to 20 sector numbering
	   bne	 nover1

	   move.w  #0xa,-(A7)	   ; count.w 2
	   move.w  #0,-(A7) 	  ; ** side.w (relevant) / side: FRONT 4
	   move.w  thetrack(A4),-(A7)  ; ** track.w (relevant) / same 6
	   move.w  #0x1,-(A7)	   ; sector.w (relevant) / starting sector 8
	   move.w  thedisk(A4),-(A7)	 ; ** device.w  (relevant) / same 0xa
	   move.l  #0,-(A7) 	  ; dummy.l (irreleveant) / same 0xe
	   move.l  buffer(A4),-(A7)	; ** buffer address.l (relevant) / same 0x12

	   move.w  #19,-(A7)	  ; do BIOS _flopver 0x14
	   trap	 #14
	   adda.l  #20, A7		 ; fix stack.

	   tst.l	 D0
	   bne	 badsecs

;****

;***** BACK SIDE ******		(How kinky Dave.  What _are_ you talking about?)

nover1:	tst.w   dblsided(A4)
		beq	   nobackside

;**** Setup stack: .. based on read sec command, tweaked for frammat

	   move.w  #0xe5e5,-(A7)    ; virgin data -- e5's work okay
; and with a virgin.  My, you really are weird Dave.
	   move.l  #0x87654321,-(A7) ; magic # to make format work / fmt only
	   move.w  #1,-(A7) 	  ; sector interleave factor / fmt only
	   move.w  #1,-(A7) 	  ; ** side.w (relevant) / side: BACK
	   move.w  thetrack(A4),-(A7)  ; ** track.w (relevant) / same
	   move.w  #10,-(A7)	  ; sector.w (irrelevant) / sectors per track
	   move.w  thedisk(A4),-(A7)	 ; ** device.w  (relevant) / same
	   move.l  #0,-(A7) 	  ; dummy.l (irreleveant) / same
	   move.l  buffer(A4),-(A7)	; ** buffer address.l (relevant) / same
	   jsr	 _flopfmt
	   adda.l  #24,A7		  ; Fix stack.
;*****
;
; Jazz twistsectorno(A4). Look at what it ended up as; set it to
; the next track twist depending on that.
;
; It will end up as "+1" from the last sector formatted, because
; the formatter bumps it up.
;
	   cmpi.w  #1,twistsectorno(A4)	    ; 0-1 transition
	   beq	 goto1
	   cmpi.w  #9,twistsectorno(A4)	    ; 1-2 transition
	   beq	 goto2
	   cmpi.w  #7,twistsectorno(A4)	    ; 2-3 transition
	   beq	 goto3
	   cmpi.w  #5,twistsectorno(A4)	    ; 3-4 transition
	   beq	 goto4
	   cmpi.w  #3,twistsectorno(A4)	    ; 4-0 transition
	   beq	 goto0

	   dc.b	 0x4a
	   dc.b	 0xfc			  ; oops, die

;
goto1:  move.w  #0x9,twistsectorno(A4)		; 9,a,1,2,3,4,5,6,7,8
	   bra	 keepformatting
goto2:  move.w  #0x7,twistsectorno(A4)		; 7,8,9,a,1,2,3,4,5,6
	   bra	 keepformatting
goto3:  move.w  #0x5,twistsectorno(A4)		; 5,6,7,8,9,a,1,2,3,4
	   bra	 keepformatting
goto4:  move.w  #0x3,twistsectorno(A4)		; 3,4,5,6,7,8,9,a,1,2
	   bra	 keepformatting
goto0:  move.w  #0x1,twistsectorno(A4)		; 1,2,3,4,5,6,7,8,9,a
	   bra	 keepformatting
	   nop
;
keepformatting: nop 		  ; entry after twisting.
;

;**** Setup stack: .. based on read sec command, tweaked for frammat
	   
	   tst.w	 sectoroffset(A4)	; no verify for strange sector numbers
	   bne	 nobackside

	   move.w  #0xa,-(A7)	   ; count.w 2
	   move.w  #1,-(A7) 	  ; ** side.w (relevant) / side: BACK 4
	   move.w  thetrack(A4),-(A7)  ; ** track.w (relevant) / same 6
	   move.w  #0x1,-(A7)	   ; sector.w (relevant) / starting sector # 8
	   move.w  thedisk(A4),-(A7)	 ; ** device.w  (relevant) / same 0xa
	   move.l  #0,-(A7) 	  ; dummy.l (irreleveant) / same 0xe
	   move.l  buffer(A4),-(A7)	; ** buffer address.l (relevant) / same 0x12

	   move.w  #19,-(A7)	  ; do BIOS _flopver 0x14 (why not)
	   trap	 #14
	   adda.l  #20, A7		  ; fix stack

	   tst.l	 D0
	   bne	 badsecs		  ; wham

;****
nobackside: nop			  ; entry if not DS  (well at least this isn't kinky Dave)

; add 1 to thetrack. If 80, quit.
	   addi.w   #1, thetrack(A4)
	   cmpi.w  #80, thetrack(A4)
	   bne	 trackloop	  ; "do another"

	   bra	 gemexit		  ; Continue, etc, and so forth

;*********
badsecs:	move.w #0xffff, badflag(A4)  ; bad sectors found

;**************
;
; End. Exit to calling routine.
;
gemexit:	movea.l saveA2(A4), A2  ; only reg not saved by Supexec
		rts

;******************************************************
;
;------------------------------------------------------------------------
;	   130-ST / 520-ST										  :
;	   Floppy Disk Driver									  :
;	   (C)1985 Atari Corp.									  :
;	   From the FDC article (Start issue 3); shortened to just		  :
;	   the formatter routine and the low level I/O.				  :
;														  :
;------------------------------------------------------------------------
;
;************************************************************
;
; _flopfmt - format a track
; Passed (on the stack):
;	   0x1a(A7) initial sector data
;	   0x16(A7) magic number
;	   0x14(A7) interleave
;	   0x12(A7) side
;	   0x10(A7) track
;	    0xe(A7) A7t(A4)
;	    0xc(A7) drive
;	    0x8(A7) pointer to state block
;	    0x4(A7) dma address
;	    0x0(A7) [return]
;
; Returns:	 EQ: track successfully written.  Zero.W-terminated list of
;			 bad sectors left in buffer (they might /all/ be bad.)
;
;			 NE: could not write track (write-protected, drive failure,
;			 or something catastrophic happened).
;-
_flopfmt:
	   cmpi.l   #0x87654321, 0x16(A7)	    ; check for magic# on stack
	   bne	 flopfail 			; no magic, so we just saved the world
;	   bsr	 change				; check for disk flip
;	   moveq	 #e_error,D0			; set default error number
	   bsr	 floplock 			; lock floppies, setup parms
	   bsr	 select				; select drive and side
	   move.w  0xe(A7),A7t(A4)			; save sectors-per-track
	   move.w  0x14(A7),interlv(A4)		; save interleave factor
	   move.w  0x1a(A7),virgin(A4)		; save initial sector data

;--- put drive into "changed" mode
;	   moveq	 #m_changed,D0 		; D0 = "CHANGED"
;	   bsr	 setdmode 			; set media change mode

;--- seek to track (hard seek):
;debug* move.l  #0xff00ff00,0xf8030
	   bsr	 hseek				; hard seek to 'ctrack'
;debug* move.l  #0x00000000,0xf8030
	   bne	 flopfail 			; (return error on seek failure)
	   move.w  ctrack(A4),dcurtrack(A1)    ; record current track#

;--- format track, then verify it:
;*	   move.w  #e_error,curr_err(A4)(A5)   ; vanilla error mode
;debug* move.l  #0xff00ff00,0xfA030
	   bsr	 fmtrack				; format track
;debug* move.l  #0x0,0xfA030

	   bne	 flopfail 			; (return error on seek failure)
	   bra	 flopok


;****************************
;+
; fmtrack - format a track. Tweaked for skewed interleave.
;
; Passed: 	 variables setup by _flopfmt
; Returns:	 NE on failure, EQ on success
; Uses:		 almost everything
; Called-by:	 _flopfmt
;
;-
fmtrack:
;*	   move.w  #e_write,def_error(A4)	; set default error number
	   move.w  #1,D3				; start with sector 1, first pass
;**
	   movea.l  cdma(A4),A2			; A2 =  prototyping area
; Lay down beginning of track

	   move.w  #60-1,D1 			; 60 x 0x4e (track leadin)
	   move.b  #0x4e,D0
	   bsr	 wmult
; Repeat 10 times: sector data.
	   move.w  #1,sectorno(A4)		    ; how many secs written
; Note that twistsectorno is initialized out of this routine.
;--- address mark
secloop: nop
;
ot1:    move.w  #12-1,D1 			; 12 x 0x00
	   clr.b	 D0
	   bsr	 wmult
	   move.w  #3-1,D1				; 3 x 0xf5
	   move.b  #0xf5,D0
	   bsr	 wmult
	   move.b  #0xfe,(A2)+			 ; 0xfe -- address mark intro
	   move.b  ctrack+1(A4),(A2)+ 	    ; track# - low half of word
	   move.b  cside+1(A4),(A2)+		    ; side# - low half of word

;* #1: just use a plain sector number
;*	   move.b  D4,(A2)+ 			; sector#

;* #2: use a twisted sector number
;*	   move.b  twistsectorno+1(A4),(A2)+   ; new: sector #.

	   move.w  twistsectorno(A4),D0	    ; fetch	 1-10 sector #
;
; Note that meg-a-minute backup uses sectors # 11-20 to force GEM
; not to use MM disks.
;
	   add.w	 sectoroffset(A4),D0	; add possible shift to 11-20 sector #
	   move.b  D0,(A2)+ 			; plug it into sector table

; Add 1 to sector #. If it is b, wrap it to 1.
	   addi.w  #1,twistsectorno(A4)	    ; real sector # being plopped
	   cmpi.w  #0xb,twistsectorno(A4)
	   bne	 notb
	   move.w  #1,twistsectorno(A4)
;
notb:   nop
	   move.b  #0x02,(A2)+			 ; sector size (512)
	   move.b  #0xf7,(A2)+			 ; write checksum

;--- gap between AM and data:
	   move.w  #22-1,D1 			; 22 x 0x4e
	   move.b  #0x4e,D0
	   bsr	 wmult
	   move.w  #12-1,D1 			; 12 x 0x00
	   clr.b	 D0
	   bsr	 wmult
	   move.w  #3-1,D1				; 3 x 0xf5
	   move.b  #0xf5,D0
	   bsr	 wmult

;--- data block:
	   move.b  #0xfb,(A2)+			 ; 0xfb -- data intro
	   move.w  #256-1,D1			; 256 x virgin.w (initial sector data)
ot2:    move.b  virgin(A4),(A2)+		    ; copy high byte
	   move.b  virgin+1(A4),(A2)+ 	    ; copy low byte
	   dbf	 D1,ot2				; fill 512 bytes
	   move.b  #0xf7,(A2)+			 ; 0xf7 -- write checksum
	   move.w  #40-1,D1 			; 40 x 0x4e
	   move.b  #0x4e,D0
	   bsr	 wmult
;
; Next sector, or, end-of-track. If we hit sector 11, time to quit.
;
	   addi.w   #1,sectorno(A4)
	   cmpi.w  #11,sectorno(A4)
	   bne	 secloop		  ; loop again
;
; Okay, 10 sectors laid down. 
;
;--- end-of-track
	   move.w  #1400,D1 			; 1401 x 0x4e -- end of track trailer
	   move.b  #0x4e,D0
	   bsr	 wmult

;--- setup to write the track:
	   move.b  cdma+3(A4),dmalow	 ; load dma pointer
	   move.b  cdma+2(A4),dmamid
	   move.b  cdma+1(A4),dmahigh
	   move.w  #0x190,(A6)			 ; toggle R/W flag and
	   move.w  #0x090,(A6)			 ; select sector-count register
	   move.w  #0x190,(A6)
	   move.w  #0x1f,D7 			 ; (absurd sector count)
	   bsr	 wdiskctl
	   move.w  #0x180,(A6)			 ; select 1770 cmd register
	   move.w  #0xf0,D7 			 ; write format_track command
;debug* move.l  #0xff00ff00,0xfc030
	   bsr	 wdiskctl
	   move.l  #timeout,D7			; D7 = timeout value

;--- wait for 1770 to complete:
otw1:   btst.b  #5,gpip				; is 1770 done?
	   beq	 otw2				; (yes)
	   subq.l  #1,D7				; if(--D7) continue;
	   bne	 otw1
;debug* move.l  #0xffffffff,0xfc030

	   bsr	 reset1770			; timed out -- reset 1770
oterr:  moveq	 #1,D7				; return NE (error status)
	   rts

;--- see if the write-track won:
otw2:   nop
;debug* move.l  #0x0,0xfc030

	   move.w  #0x190,(A6)			 ; check DMA status bit
	   move.w  (A6),D0
	   btst	 #0,D0				; if its zero, there was a DMA error
	   beq	 oterr				; (so return NE)
	   move.w  #0x180,(A6)			 ; get 1770 status
	   bsr	 rdiskctl
;**	   bsr	 err_bits 			; set 1770 error bits
	   and.b	 #0x44,D0 			 ; check for writeProtect & lostData
	   rts						; return NE on 1770 error

;------ write 'D1+1' copies of D0.B into A2, A2+1, ...
wmult:  move.b  D0,(A2)+ 			; record byte in proto buffer
	   dbf	 D1,wmult 			; (do it again)
	   rts
;
;************************************************************
;
; floplock - lock floppies and setup floppy parameters
;
; Passed (on the stack):
;	   0x18(A7) - count.W (sector count)
;	   0x16(A7) - side.W (side#)
;	   0x14(A7) - track.W (track#)
;	   0x12(A7) - sect.W (sector#)
;	   0x10(A7) - dev.W (device#)
;	    0xc(A7) - obsolete.L
;		8(A7) - dma.L (dma pointer)
;		4(A7) - ret1.L (caller's return address)
;		0(A7) - ret.L (floplock's return address)
;
; It is not coincidence that this matches the read and write input list;
; they call us to get stuff off stack and plug into parameters. Then,
; routine "select" actually pops this stuff into hardware.
;
; Passed: 	 D0.W = default error number
;
; Also, we helpfully point A6 at the DMA chip, and A1 at the DSB.
;-
floplock:
	   lea	regsave, A0
	   movem.l D3-D7/A3-A6, (A0)		; save C registers
	   lea	 fifo,A6				; A6 -> fifo
; Start setting up param block..
	   move.w  D0,def_error(A4)		    ; set default error number
	   move.w  D0,curr_err(A4)		    ; set current error number
; Kick VBL off floppies..
	   move.w  #1,flock 			; tell vbl not to touch floppies
; Stuff off stack:
	   move.l  8(A7),cdma(A4)		    ; cdma -> /even/ DMA address
	   move.w  0x10(A7),cdev(A4)	  ; save device# (0 .. 1)
	   move.w  0x12(A7),csect(A4)   ; save sector# (1 .. 9, usually)
	   move.w  0x14(A7),ctrack(A4)  ; save track# (0 .. 39 .. 79 ..)
	   move.w  0x16(A7),cside(A4)   ; save side# (0 .. 1)
	   move.w  0x18(A7),ccount(A4)  ; save sector count (1..A)
;--- pick a DSB: Point A1 at it.
	   lea	 dsb0,A1		  ; pick dsb 0 (drive A)
	   tst.w	 cdev(A4)
	   beq	 flock2
	   lea	 dsb1,A1		  ; pick dsb 1 (drive B)
;--- compute ending DMA address from count parameter: Plug into edma.
; This is used in multisector transfers in read-multiple-sector,
; but we don't use it here.
flock2: moveq	 #0,D7
	   move.w  ccount(A4),D7 		    ; edma = cdma + (ccount * 512)
	   lsl.w	 #8,D7
	   lsl.w	 #1,D7				; do a 9 shift..
	   movea.l  cdma(A4),A0
	   adda.l   D7,A0
	   move.l  A0,edma(A4)			    ; save in edma
;--- recalibrate drive, if it needs it. This only happens when the DSB
; says that this drive has never awoken before, and needs an initial
; recal to match its current track # with the DSB track #. 
	   tst.w	 dcurtrack(A1) 		; if (curtrack < 0) recalibrate()
	   bpl	 flockr
; RECAL needed. Show flag about it..
	   move.l  #0xf0f0f0f0,0xfe000
	   move.l  #0xf0f0f0f0,0xfe004

	   bsr	 select				; select drive & side
	   clr.w	 dcurtrack(A1) 		; we're optimistic -- assume winnage
; Restore.
	   bsr	 restore				; attempt restore
	   beq	 flockr				; (it won)
	   moveq	 #10,D7				; attempt seek to track 10
	   bsr	 hseek1
	   bne	 flock1				; (failed)
	   bsr	 restore				; attempt restore again
	   beq	 flockr				; (it won)
;
flock1:  move.w  #recal, dcurtrack(A1)	  ; complete failure (what can we do?)

	   movem.l regsave(PC), D3-D7/A3-A6
flockr: rts
;
;********************************************************************
;+
; flopfail - unlock floppies and return error.
; Common way for read and write to return.
;
; Note: Returns via unlok1.
;-
flopfail:
	   move.l  #0xffffffff,D0		 ; aargh, error
	   bra.s	 unlok1				; clobber floppy lock & return
;***************************************************
;+
; flopok - unlock floppies and return success status. Also a common
; way for r/w to return.
;
;-
flopok: clr.l	 D0					; return 0 (success)
; Entry point from flopfail..
unlok1: move.l  D0,-(A7) 			; (save return value)
; I believe this code returns the FDC's status to a type-1 status, where
; the write protect switch is available for VBL to look at.
	   move.w  #datareg,(A6) 		; force WP to real-time mode
; Sets FDC's current track register to track we are on right now.
	   move.w  dcurtrack(A1),D7		; dest-track = current track
	   bsr	 wdiskctl
; Does it with a "noop seek" (source=dest). Only forces FDC to type 1 status.
	   move.w  #0x10,D6 			 ; cmd = seek w/o verify
	   bsr	 flopcmds 			; do it
;
unlok2: move.l  (A7)+,D0 			; restore return value
	   movem.l  regsave(PC), D3-D7/A3-A6
; clear floppy lock of vblank..
	   clr.w	 flock				; allow vblank .. unlock floppies
; wave byebye at the pretty camera, jenny...
	   rts
;************************ Seek routines ********************
;+
; hseek  - seek to 'ctrack(A4)' without verify
; hseek1 - seek to 'D7' without verify
; hseek2 - seek to 'D7' without verify, keep current error number
;
; Returns:	 NE on seek failure ("cannot happen"?)
;			 EQ if seek wins
;
; Uses:		 D7, D6, ...
; Exits to:	 flopcmds
; Called-by:	 _flopfmt, _flopini
;
;-
hseek:  move.w  ctrack(A4),D7 		    ; dest track = 'ctrack'
hseek1: nop
hseek2: move.w  #datareg,(A6) 		; write destination track# to data reg
	   bsr	 wdiskctl 			; write D7 to FDC data register
; seek command:
	   move.w  #0x10,D6 			 ; execute "seek" command
;								* Note: no spinup time.
	   bra	 flopcmds 			; (without verify...)
;
;***********************************************
;+
; reseek - home head, then reseek track
; Returns:	 EQ/NE on success/failure
; Falls-into:	 go2track
;
;-
reseek:
	   bsr	 restore				; restore head
	   bne	 go2trr				; (punt if home fails)

	   clr.w	 dcurtrack(A1) 		; current track = 0
	   move.w  #trkreg,(A6)			; set "current track" reg on 1770
	   clr.w	 D7
	   bsr	 wdiskctl 			; write a 00 to trk register.

	   move.w  #datareg,(A6) 		; seek out to track five
	   move.w  #5,D7
	   bsr	 wdiskctl 			; dest track = 5
	   move.w  #0x10,D6
	   bsr	 flopcmds 			; seek
;								* Note: no spinup time.
	   bne	 go2trr				; return error on seek failure
	   move.w  #5,dcurtrack(A1)		; set current track#

;***********************************************+
; go2track - seek proper track
; Passed: 	 Current floppy parameters (ctrack, et al.).
; Returns:	 EQ/NE on success/failure
; Calls:		 flopcmds
; Called by: read sector, for instance. Lots of places.
;-
go2track:
	   move.w  #datareg,(A6) 		; set destination track# in
	   move.w  ctrack(A4),D7 		    ;  1770's data register
	   bsr	 wdiskctl 			; (write track#)
	   moveq	 #0x14,D6 			 ; execute 1770 "seek_with_verify"
	   bsr	 flopcmds 			; (include seek-rate bits)
	   bne	 go2trr				; return error on seek failure
	   move.w  ctrack(A4),dcurtrack(A1)    ; update current track number
	   and.b	 #0x18,D7 			 ; check for RNF, CRC_error, lost_data
go2trr: rts						; return EQ/NE on succes/failure

;*************************************************
;+
; restore - home head
; Passed: 	 nothing
; Returns:	 EQ/NE on success/failure
;-
restore:
	   clr.w	 D6					; 0x00 = 1770 "restore" command
	   bsr	 flopcmds 			; do restore
	   bne	 res_r				; punt on timeout
	   btst	 #2,D7				; test TRK00 bit
	   eori.w  #0x04, CCR			; flip Z bit (return NE if bit is zero)
	   bne	 res_r				; punt if didn't win
	   clr.w	 dcurtrack(A1) 		; set current track#
res_r:  rts

;****************************************************
; Special floppy cmd just for seeking:
;+
; flopcmds - floppy command (or-in seek speed bits from database)
; Passed: 	 D6.w = 1770 command
; Sets-up:	 seek bits (bits 0 and 1) in D6.w
; Falls-into:	 flopcmd
; Returns:	 EQ/NE on success/failure
;
; I get the impression this is only used for seeking. I am right.
;-
flopcmds:
	   move.w  dseekrt(A1),D0		; get floppy's seek rate bits
	   andi.b  #3,D0				; OR into command
	   or.b	 D0,D6
; Fall in...
;******************************************************+
; flopcmd - execute any ol' 1770 command (with timeout)
; Passed: 	 D6.w = 1770 command
;
; Returns:	 EQ/NE on success/failure
;			 D7 = 1770 status bits
;
; Note: does motor spinup, if cmd in D6 specs it (I would *hope*!)
;-
flopcmd:
	   move.l  #timeout,D7			; setup timeout count (assume short)
	   move.w  #cmdreg,(A6)			; select 1770 command register
	   bsr	 rdiskctl 			; read it to clobber READY status
	   btst	 #7,D0				; is motor on?
	   bne	 flopcm				; (yes, keep short timeout)
	   move.l  #ltimeout,D7			; extra timeout for motor startup
flopcm: bsr	 wdiskct6 			; write command (in D6)

flopc1: subq.l  #1,D7				; timeout?
	   beq	 flopcto				; (yes, reset and return failure)
	   btst.b  #5,gpip				; 1770 completion?
	   bne	 flopc1				; (not yet, so wait some more)
	   bsr	 rdiskct7 			; return EQ + 1770 status in D7
	   clr.w	 D6
	   rts
;****
flopcto:
; We timed out.. a gruesome death indeed.
; Whap controller back to life.	(Hit him harder Dave, he likes it that way)
	   bsr	 reset1770			; bash controller
	   moveq	 #1,D6				; and return NE
	   rts

;*******************************************************
;+
; reset1770 - reset disk controller after a catastrophe
; Passed: 	 nothing
; Returns:	 nothing
; Uses:		 D7
;-
reset1770:
	   move.w  #cmdreg,(A6)			; execute 1770 "reset" command
	   move.w  #0xD0,D7 			 ; force interrupt
	   bsr	 wdiskctl
	   move.w  #15,D7				; wait for 1770 to stop convulsing
r1770:  dbf	 D7,r1770 			; (short delay loop)
	   bsr	 rdiskct7 			; return 1770 status in D7
	   rts

;******************************************************
;+
; select - setup drive select, 1770 and DMA registers
; Passed: 	 cside(A4), cdev(A4)
; Returns:	 appropriate drive and side selected
;
; Called: All over the place.
;
;-
select: move.w  #0,0x9c0 			 ; floppies NOT deselected
;								* lets VBL shut them off...
	   move.w  cdev(A4),D0			    ; get device number
	   addq.b  #1,D0				; add and shift to get select bits
	   lsl.b	 #1,D0				; into bits 1 and 2
	   or.w	 cside(A4),D0			    ; or-in side number (bit 0)
	   eori.b   #7,D0				 ; negate bits for funky hardware select
	   andi.b   #7,D0				 ; strip anything else out there
	   bsr	 setporta 			; do drive select
; Have to restore 1770's track register from table..in dsb.
	   move.w  #trkreg,(A6)			; setup 1770 track register
	   move.w  dcurtrack(A1),D7		; from current track number
	   bsr	 wdiskctl
	   clr.b	 tmpdma(A4)			    ; zero bits 24..32 of target DMA addr

; Setup R/W parameters on 1770. Used by
; r/w sector, among others. This is where the sector register gets set.
; 
select1:
	   move.w  #secreg,(A6)			; setup requested sector_number from
	   move.w  csect(A4),D7			    ;	  caller's parameters
	   bsr	 wdiskctl
	   move.b  cdma+3(A4),dmalow		    ; setup DMA chip's DMA pointer
	   move.b  cdma+2(A4),dmamid
	   move.b  cdma+1(A4),dmahigh
	   rts

;************************************************
;+
; setporta - set floppy select bits in PORT A on the sound chip
; Passed: 	 D0.b (low three bits)
; Returns:	 D1 = value written to port A
;			 D2 = old value read from port A
; Uses:		 D1
;-
setporta:
	   move	 SR,-(A7) 			; save our IPL
	   ori	 #0x0700,SR			 ; start critical section
	   move.b  #giporta,giselect		; select port on GI chip
	   move.b  giread,D1			; get current bits
	   move.b  D1,D2				; save old bits for caller
	   andi.b   #0xff-7,D1			  ; strip low three bits there
	   or.b	 D0,D1				; or-in our new bits
	   move.b  D1,giwrite			; and write 'em back out there
	   move	 (A7)+,SR 			; restore IPL to terminate CS, return
	   rts

;**************************************************
;+
; Primitives to read/write 1770 controller chip (DISKCTL register).
;
; The 1770 can't keep up with full-tilt CPU accesses, so
; we have to surround reads and writes with delay loops.
; This is not really as slow as it sounds.
;
wdiskct6: 						; write D6 to diskctl
	   bsr	 rwdelay				;	   delay
	   move.w  D6,diskctl			;	   write it
	   bra	 rwdelay				;	   delay and return

wdiskctl: 						; write D7 to diskctl
	   bsr	 rwdelay				;	   delay
	   move.w  D7,diskctl			;	   write it
	   bra	 rwdelay				;	   delay and return

rdiskct7: 						; read diskctl into D7
	   bsr	 rwdelay				;	   delay
	   move.w  diskctl,D7			;	   read it
	   bra	 rwdelay				;	   delay and return

rdiskctl: 						; read diskctl into D0
	   bsr	 rwdelay				;	   delay
	   move.w  diskctl,D0			;	   read it
; And here's the delay loop:
rwdelay:
	   move	 SR,-(A7) 			; save flags
	   move.w  D7,-(A7) 			; save counter register
	   move.w  #0x20,D7 			; 0x20 seems about right...
rwdly1: dbf	 D7,rwdly1			; busy-loop: give 1770 time to settle
	   move.w  (A7)+,D7 			; restore register, flags, and return
	   move	 (A7)+,SR
	   rts

;-------------------------------------
regsave:	dc.l 	1	  ; PC relative data area
		dc.l 	2
		dc.l 	3
		dc.l 	4
		dc.l 	5
		dc.l 	6
		dc.l 	7
		dc.l 	8
		dc.l 	9


}		/* MY GOD!  It's DONE!  */
