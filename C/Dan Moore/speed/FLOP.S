/
/ MWC asm routine to talk to the 1772
/
/ dlm 03/15/88 trimmed to just code needed for speed tester
/
/ this is all run from a Supexec call.  fortunately that call will save all
/ the registers that need to be saved.  That keeps us from stomping on
/ registers in this code.  at least I hope it does.
/
/ callable routines:
/	drive_sel()	--- select the drive in sel_bits
/
/	drive_step()	--- step the drive (float the step direction)
/
/	motoroff()	--- let the STs FDC turn the motor off
/			    needed since drive_step() forces the FDC to
/			    do a motor on (boo, hisssss)
/
/	driveclr()	--- deselect all drives
/
/	drive_pro()	--- determine the drive write protect status
/			    assumes sel_bits are correct and then 
/			    returns the status in pro_stat (extern int)
/
/	drive_stat()	--- return the drive status byte
/			    it presumes that the drive is already selected
/			    and spinning.
/


/ globals for the drive select code
        .globl drive_sel_, sel_bits_, drive_step_, motoroff_, driveclr_
	.globl drive_pro_, pro_stat_, drive_status_

giporta		= 0x000e		/ offset to register a
giselect	= 0x00ff8800		/ register control
giread		= 0x00ff8800		/ read register
giwrite		= 0x00ff8802		/ write register
d0_a6pre	= 0xfffe		/ for movem to -(a7) (stupid!)
a6_d0		= 0x7fff		/ for movem from (a7)+

motor_bit	= 0x07			/ motor on bit
protect_bit	= 0x06			/ write protect bit

/--------------------
drive_pro_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		bsr	drive_sel_	/ select the drive
		lea	fifo,a6		/ we need this ptr for flopcmd to work.
		move.l	$timeout,d7	/ setup timeout count (assume short)
		move.w	$cmdreg,(a6)	/ select 1770 command register
		bsr	rdiskctl	/ read it to clobber READY status
		btst	$protect_bit,d0	/ check protect bit
		bne.s	protected	/ yep, it is write protected

		clr.w	pro_stat_	/ flag for outside world
		bra.s	dp_exit

protected:	move.w	$0xffff, pro_stat_

dp_exit:	move.w	$7,d0		/ deselect all drives, head 0
		bsr	setporta	/ do it

		movem.l (a7)+, $a6_d0	/ and restore the regs

		rts

/--------------------
drive_status_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		lea	fifo,a6		/ we need this ptr for flopcmd to work.
		move.l	$timeout,d7	/ setup timeout count (assume short)
		move.w	$cmdreg,(a6)	/ select 1770 command register
		bsr	rdiskctl	/ read it to clobber READY status
		move.w	d0, pro_stat_	/ use the protection flag word

		movem.l (a7)+, $a6_d0	/ and restore the regs

		rts

/--------------------
drive_step_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		bsr	driveclr_
		bsr	stepout		/ take care of the step with no drives
		movem.l (a7)+, $a6_d0	/ and restore the regs
		rts

/--------------------
drive_sel_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		move.w	sel_bits_, d0	/ which one to select
		ori.b	$1, d0		/ force bit 0 (head select) high
		bsr	setporta	/ do the select
		movem.l (a7)+, $a6_d0	/ and restore the regs
		rts		

/--------------------
driveclr_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		move.w	$7, d0		/ deslect all drives, side 0
		bsr	setporta
		movem.l (a7)+, $a6_d0	/ and restore the regs
		rts

/--------------------
motoroff_:
		movem.l	$d0_a6pre, -(a7)	/ save all the regs
		bsr	drive_sel_	/ select the drive
		lea	fifo,a6		/ we need this ptr for flopcmd to work.
		move.l	$timeout,d7	/ setup timeout count (assume short)
		move.w	$cmdreg,(a6)	/ select 1770 command register
waitoff:	bsr	rdiskctl	/ read it to clobber READY status
		btst	$motor_bit,d0	/ is motor on?
		bne.s	waitoff		/ yes, well check again

		move.w	$7,d0		/ deselect all drives, head 0
		bsr	setporta	/ do it

		movem.l (a7)+, $a6_d0	/ and restore the regs

		rts

/----------------------------------------------------------------------

/------ Tunable values (subject to tweaking):
retries		= 2	/ default # of retries - 1
midretry	= 1	/ "middle" retry (when to reseek)

timeout		= 0x10000	/ short   timeout (motor already on)
ltimeout	= 0x15000	/ long timeout (to startup motor)

/ HARDWARE equates:
/--- DMA chip: These should be okay.
diskctl		= 0x00ff8604	/ disk controller data access
fifo		= 0x00ff8606	/ DMA mode control / status
dmahigh		= 0x00ff8609	/ DMA base high
dmamid		= 0x00ff860b	/ DMA base medium
dmalow		= 0x00ff860d	/ DMA base low

/ --- 1770 select values. These are used as part A of selecting a FDC
/ register; next, you output the value. (DMA chip controls a0,a1 into FDC).

cmdreg		= 0x80		/ select command register
trkreg		= 0x82		/ select track register
secreg		= 0x84		/ select sector register
datareg		= 0x86		/ select data register

/ --- GI ("psg") sound chip: These are the drive A and B select lines.
/ already here for the select code
/giselect  	equ  $ffff8800 ; (W) sound chip register select
/giread         equ  $ffff8800 ; (R) sound chip read-data
/giwrite        equ  $ffff8802 ; (W) sound chip write-data
/giporta        equ  $e        ; GI register# for I/O port A

/ --- 68901 ("mfp") sticky chip: These should be okay (although
/ --- stay away from interrupts, we haff moved them.)
/ The IRQ line from the FDC comes to bit 5 of the GPIP in the MFP.
/ It doesn't generate an interrupt, but we can poll for it.
/ Note that "mfp" was formerly equate .. double def with Magic code.
fdcmfp		= 0x00fffa00		/ mfp base
fdcgpip		= fdcmfp+1		/ general purpose I/O

/************************************************
/ Dave's Dreaded Step Twanger			*
/ Sets step line to +5, so XL can take ahold of *
/ it, much like we'd all like to take ahold     *
/ of Brooke, but hey, like, I digress. 		*
/************************************************

stepout:
/
/ WARNING: DISK DRIVES SHOULD BE DESELECTED HERE. WE DON'T REALLY
/ WANT TO STEP THEM, JUST DIDDLE THE LINE IS ALL.
/
/ Perform a "step out" command (just steps one track out).
/

/
/ Okay, now we have to lie to FDC about current track number. It will
/ ignore the stepout if it thinks we're already on track 0.
/ So coerce the track register to a .gt. 0 track number.
/
/ first nuke the track, then step out once.  if it loses force a reset of the
/ FDC and try again.
/

ackmore:	lea	fifo,a6		/ we need this ptr for flopcmd to work.
		move.w	$trkreg,(a6)	/ select track register of FDC to write into
		move.w	$0x20,d7	/ set track number to $20
		bsr	wdiskctl	/ write it on out there bub

		lea	fifo,a6		/ we need this ptr for flopcmd to work.
		move.w	$0x60,d6	/ step-out, no ver, no motor,  6 ms step
		bsr	flopcmd		/ go do the seek-out command..

/ Returns status in d6; 0 = won, 1 = lost, it reset1770'd already.
		tst	d6
		beq.s	seekfine	/ all dun.

/ if it pukes reset and try again 
		bsr	reset1770
		bra	ackmore
	
seekfine:	rts

/
/
/ flopcmd - execute 1770 command (with timeout)
/ Passed: d6.w = 1770 command
/
/ Returns:     EQ/NE on success/failure
/ 		d7 = 1770 status bits
/
/ Note: does motor spinup, if cmd in d6 specs it (I would *hope*!)
/

flopcmd:	move.l	$timeout,d7		/ setup   timeout   count (assume short)
		move.w	$cmdreg,(a6)		/ select 1770 command register
		bsr	rdiskctl		/ read it to clobber READY status
		btst	$motor_bit,d0		/ is motor on?
		bne.s	flopcm			/ (yes, keep short timeout)
		move.l	$ltimeout,d7		/ extra timeout for motor startup

flopcm: 	bsr	wdiskct6		/ write command (in d6)

flopc1:		subq.l	$1,d7			/ timeout?
		beq.s	flopcto			/ (yes,   reset and return failure)
		btst	$5,fdcgpip		/ 1770 completion?
		bne.s	flopc1			/ (not yet, so wait some more)
		bsr	rdiskct7		/ return EQ + 1770 status in d7

		clr.w	d6
		rts

flopcto:
		bsr	reset1770		/ bash controller 
		moveq	$1,d6			/ and return NE
		rts

/*******************************************************
/+
/ setporta - set floppy  select bits in PORT A on the sound chip
/
/ Passed:      d0.b (low three     bits)
/
/ Returns:     d1 = value written to port A
/              d2 = old value read from port A
/
/ Uses:        d1
/
/-
setporta:
		move   sr,-(a7)			/ save our IPL
		ori    $0x0700,sr		/ start   critical section
		move.b $giporta,giselect	/ select port on GI chip
		move.b giread,d1		/ get current bits
		move.b d1,d2			/ save old bits for caller
		and.b  $0xff-7,d1		/ strip   low three bits there
		or.b   d0,d1			/ or-in   our new   bits
		move.b d1,giwrite		/ and write 'em     back out there
		move   (a7)+,sr			/ restore IPL to terminate CS, return
		rts

/**************************************************
/+
/ Primitives to     read/write 1770     controller chip     (DISKCTL register).
/
/ The 1770 can't keep up with full-tilt CPU accesses, so
/ we have to surround reads and    writes with delay loops.
/ This is not really as slow as it sounds.
/
/-
 
/ write   d6 to diskctl
wdiskct6:
		bsr     rwdelay		/ delay
		move.w  d6,diskctl	/ write it
		bra     rwdelay		/ delay and return

/ write   d7 to diskctl
wdiskctl:
		bsr     rwdelay		/ delay
		move.w  d7,diskctl	/ write it
		bra     rwdelay		/ delay and return

/ read diskctl into d7
rdiskct7:
		bsr     rwdelay		/ delay
		move.w  diskctl,d7	/ read it
		bra     rwdelay		/ delay and return

/ read diskctl into d0
rdiskctl:
		bsr     rwdelay		/ delay
		move.w  diskctl,d0	/ read it
					/ fall thru to delay

/ And here's the delay loop:
rwdelay:
		move    sr,-(a7)	/ save flags
		move.w  d7,-(a7)	/ save counter register
		move.w  $0x20,d7	/ 0x20 seems about right...
rwdly1:		dbra    d7,rwdly1	/ busy-loop: give 1770 time to settle
		move.w  (a7)+,d7	/ restore register, flags, and return
		move    (a7)+,sr
		rts

/*******************************************************
/+
/ reset1770 - reset disk controller after a catastrophe
/ Passed: nothing
/ Returns:     nothing
/ Uses:        d7
/ Gee, I hope the 1770 doesn't hang like the 1797, and require
/ the RESET line itself to *twang*. Gee, I hope.
/-
reset1770:
		move.w	$cmdreg,(a6)	/ execute 1770 "reset" command
		move.w	$0xd0,d7
		bsr	wdiskctl
		move.w	$15,d7		/ wait for 1770 to stop convulsing
r1770:		dbra	d7,r1770	/ (short delay loop)
		bsr	rdiskct7	/ return 1770 status in  d7
		rts

