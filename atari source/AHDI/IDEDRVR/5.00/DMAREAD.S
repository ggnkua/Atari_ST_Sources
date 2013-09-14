.super
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 1991/11/06 22:42:16 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: dmaread.s,v $
* Revision 1.27  1991/11/06  22:42:16  apratt
* Fixed a BIG OOPS: at qd0 the label 'sdelay' was wrong so that
* the add of _hz_200 to d0 was INSIDE the loop.  Oops.  Fixed.
*
* Revision 1.26  1991/10/15  15:04:18  apratt
* Fixed a bug in the caller of strcmp.
*
* Revision 1.24  1991/09/30  18:04:38  apratt
* Previous version worked very badly.  One theory: Conner says that
* you need a delay between Identify and Init Parameters.  When Minna
* took out the Init Parameters call, she also took out the delay.
* Well, hmm, maybe the delay is required between Identify and
* ANYTHING ELSE.  So it's back.
*
* Revision 1.23  1991/09/30  16:45:06  apratt
* New from Minna: checks both READY and BUSY waiting for the right values.
* Seems some drives set READY before clearing BUSY.  Sigh.
*
* Revision 1.22  1991/09/13  17:45:58  apratt
* Oops - the delay was supposed to be 500us, not 500ms.  Made it
* two ticks, which is btw 5 and 10 ms.
*
* Revision 1.21  1991/09/13  00:46:52  apratt
* Minna added yet another delay: Conner wants 0.5sec between
* power up and the Identify command.
*
* Revision 1.20  1991/09/12  19:56:18  apratt
* Changed to assemble IDE_AT for ALL MACHINES, now that there's no
* distinction at assembly time between ST and STPLUS.
*
* Revision 1.19  1991/09/06  14:50:56  apratt
* Changed all "ifne" to "if" and "ifeq" to "if !" and "endc" to "endif."
*
* Revision 1.18  91/08/21  11:18:56  apratt
* Fixed two oopses: iderdy is now consistently _iderdy,
* and undev is outside IDEAT conditionals.
* 
* Revision 1.17  91/08/20  13:22:25  minna
* Added iderdy() to test if IDE drive is ready before 
* it's being talked to.  If the drive does not become
* ready in 5 sec., it's considered as an unknown device.
* 
* Revision 1.16  91/08/15  16:18:07  apratt
* Added code for IDE to wait until ATASR shows READY before
* doing anything else.  Also changed so IDE_AT is assembled for
* all STPLUS versions; the bus error detection will take care
* of failing out quick on those machines that don't really have
* an IDE bus.
* 
* Revision 1.15  91/08/02  16:21:23  minna
* Added delay between identify() and initparm(),
* and reversed changes made earlier today.
* 
* Revision 1.14  91/08/02  15:07:10  minna
* Added handling of final interrupt after data transfer
* on IDE drive.
* 
* Revision 1.13  91/07/29  12:37:45  minna
* _atread() and _atwrite modified to not use the
* ATSC (sector count register) to count down on
* multiple sectors read or write.  Some vendors
* decrement the register too early.
* 
* To test if the IDE interface exists, instead of
* reading from bAT (the data register), read from
* ATASR (the alternate status register.)
* 
* Revision 1.12  91/03/27  12:36:36  apratt
* Base address of IDE has moved to $F00000.  This code assumes that the base
* address is on a longword boundary.  Added guards against missing IDE bus,
* and against missing ACSI (bus error when accessing DMA chip).  This is
* for prototype PADs only, and may go away soon.
* 
* Changed switches to SCSI and IDE_AT, which are set based on TT and STPAD at
* the top of the file.
* 
* Revision 1.11  91/02/26  17:58:37  minna
* Base address of IDE bus has been moved to $F00000.  Note that this code
* relies on the base address of the IDE bus being on a longword boundary.
* 
* Revision 1.10  90/10/29  15:52:12  minna
* Base address of IDE bus has been moved to $C00040 (long word boundary).
* 
* Revision 1.9  90/10/19  16:05:22  minna
* Added code to handle drives on the IDE-AT bus.
* 
* Revision 1.8  90/08/03  13:22:48  apratt
* TTOS FINAL RELEASE
* 
* Revision 1.7  90/03/06  16:09:16  apratt
* Moved .globl _resetscsi into the TT conditional; otherwise
* MAS thinks it's external, even though it's never used!
* 
* Revision 1.6  90/03/02  17:46:34  apratt
* This rev is the source for the 3/1/90 ROM.
* 
* Revision 1.5  90/03/01  17:27:00  apratt
* Checkin of Minna's changes, including adding better spin-up delays
* and the dmawrite call.
* 
* Revision 1.4  89/09/22  16:42:55  apratt
* THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
* No functional changes from previous revision, which is the last to
* require Alcyon's AS68 assembler.
* 
* Revision 1.3  89/09/07  16:30:02  apratt
* Added delay after (potentially) resetting ACSI DMA chip; see SLOWACSI
* code in flop.b.
* 
* Revision 1.2  89/08/25  16:49:18  apratt
* Moved lastacstm from text seg to bss.
* 
* Revision 1.1  89/08/25  16:45:32  apratt
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.27 $
* =======================================================================
*
* $Source: e:/tos/bios\RCS\dmaread.s,v $
* =======================================================================
*
*************************************************************************

* TT and STPAD equates are in switches.s

.include "switches.s"

* The code you get in assembling this file depends on the switches SCSI and
* IDE_AT.  For now (2/91), only TT has SCSI and all STPLUSes have IDE.
*
* Those STPLUS machines which use these ROMs but don't actually have an IDE
* bus will still get the IDE code, but using it will fail right away
* because it always probes for the IDE bus and returns if it doesn't exist.
*
* As of 9/91 we want One Rom To Rule Them All, so ALL machines have IDE_AT.
*

SCSI		=	TT
IDE_AT		=	1	; Always! (AKP 9/91)

;+
; DMAREAD(), DMAWRITE() - 
;	New XBIOS calls to read from or write to hard disk on the
; ACSI, SCSI or IDE-AT bus.  This is a low-level read/write which 
; does not do a lot of checking.  Amount of data requested on each 
; ACSI read or write MUST be smaller than or equal to 255 physical
; (512-byte) sectors.  On SCSI, all I/O are done by handshaking.  
; Amount of data requested on each IDE-AT read or write MUST be 
; smaller than or equal to 256 physical (512-byte) sectors.
;
; Jul-24-1989	ml.	Started this from AHDI 3.50 of Jul 24 1989.
; Aug-23-1989	ml.	Added in code to do hand-shake I/O, instead of
;			DMA.
; Dec-11-1989	ml.	Adjusted time-outs.
; Feb-08-1990	ml.	Updated according to corrections made to the
;			TT driver (DRIVER.PRG v3.63)
;			Renamed as dmarw() after adding code to handle
;			writes also.
; Feb-28-1990	ml.	Split dmarw() to become dmaread() and dmawrite()
;			as requested by AKP.  Modified time-out handling.
;			If system was up for less than UPTIME clicks, use
;			UPTIME as time-out counter rather than the regular
;			SC?TMOUT value.
; Mar-02-1990	ml.	Undid (again?!!) modifications made since Feb 28.
;			Will use regular SC?TMOUT values.  BIOS will keep
;			calling _dmaread() at boot time until the drive
;			responses, BIOS' time-out count expires, or when 
;			Bios receive a quit message from the user.
; Oct-16-1990	ml.	Added in code to handle drives on the IDE-AT bus
;			also.  The code comes from DRIVER.PRG v4.50 (dated
;			Oct 16 1990), and is slightly modified.
; Oct-29-1990	ml.	Base address of the IDE bus has been moved to
;			$C00040 (long word boundary).
; Feb-22-1991	ml.	Base address of the IDE bus has been moved to
;			$F00000 (long word boundary).
; Jul-29-1991	ml.	Do not use the IDE Sector Count Register 
;			to count down mulitiple sectors read or
;			write.  Some vendors (e.g. Conner and 
;			Seagate) seem to update this register 
;			too early, and every now and then, the
;			last sector of data would remain in the
;			internal sector buffer.  
;			
;			Code in ideread() and idewrite() are modified
;			not to use the IDE Sector Count Register.
;
;			To check if the IDE bus is there, read from
;			the alternate status register instead of the
;			data register.
;
; Aug-02-1991	ml.	Added handling of final interrupt from the
;			IDE drive after data transfer. (Routines that 
;			call readbuf() and wrtbuf() are modified).
;
; Aug-02-1991	ml.	Change again!  Conner now says there is no
;			final interrupt after data transfer, but need
;			a delay between the identify() and initparm().
;
; Aug-15-1991	ml.	Added a check to see if IDE drive is ready before
;			sending it the identify() command, by testing the
;			DRDY (driver ready) bit in the Alternate Status
;			Register.
;
; Aug-20-1991	ml.	Added iderdy() to check if an IDE drive is ready
;			or not, this includes the check for the existence 
;			of the slave drive (IDE unit 1.)
;
; Sep-12-1991	ml.	Added in yet another delay for IDE drive.  Conner
;			requires a 500us delay before calling identify()
;			after power on.
;
; Sep-24-1991	ml.	In order to accomodate the Conner CP-2024 (2.5"
;			IDE drive,) the readbuf() and wrtbuf() routines
;			need to do move.w instead of move.l to transfer
;			data.  A tower of 8 move.w is used to speed up
;			the transfer.
;
; Sep-25-1991	ml.	Extended time-out (>= 1.5s) for data hand-shake 
;			to account for slow SCSI devices (e.g. CDAR-505 
;			CD-ROM.)  The extended time-out is only needed 
;			between the end of command phase to the beginning 
;			of data	phase.  The code has the extended time-out 
;			for every byte of data to be hand-shaken, but this
;			should not affect performance because it should
;			not time-out between data bytes.
;
;			Modified _resetscsi() to clear the SCSI reset 
;			interrupt request (should anyone ever want to
;			use interrupts for watching the 5380) by reading 
;			from the 5380's reset error/interrupt register.
;
; Sep-26-1991	ml.	If a time-out occurs BEYOND the selection phase,
;			a SCSI RESET is done to clear the SCSI bus from
;			any odd state.
;
;			Deleted code which initializes IDE drive parameters.
;			Just use parameters returned by _identify().  So,
;			delay added between _identify() and _initparm() was
;			also deleted.
;
;			To take care of the bigger sector size (2K) of the
;			CD-ROM, the ACSI DMA counter is always set at the 
;			maximum of 255 512-byte blocks.  This basically 
;			disables the DMA counter and let the counter on 
;			the device determines when the transfer is finished.
;			This implies the maximum number of sectors that can
;			be transferred to or from the CD-ROM is 63.  This
;			limit should be enforced by the caller of _dmaread()
;			and _dmawrite().
;
; Sep-27-1991	ml.	Instead of just checking the ready bit in the IDEASR
;			in _iderdy(), check the entire byte for the value
;			0x50 (the ready status.)
;
; Sep-30-1991	ml.	Added delay in _fdone() and _qdone() to take care of
;			slow ACSI devices, for example the laser printer, to
;			guard against applications which call dmaread() or
;			dmawrite() on such devices.
;
;			Delay that was taken out with the _initparm() is
;			put back.  Conner drives probably needs that delay
;			between _identify() and any command!
;
; Oct-11-1991	ml.	Special-cased Conner CP2024 when getting current 
;			drive parameters.  Conner CP2024's current drive
;			parameters are not stored in the _identify() data.
;			
; Nov-06-1991	ml.	Big OOPS!!!  When delay was added in to take care of
;			slow ACSI devices, the label "sdelay" for the branch
;			accidentally includes the "add" instruction.  So, it
;			takes a long time before we exit the loop.
;-

.globl	_dmaread
.globl	_dmawrite


; System variables
flock	    equ	    $43e    ; FIFO lock variable
_hz_200	    equ	    $4ba    ; system 200hz timer

; For ACSI and SCSI drives
READ	    equ	    $08	    ; opcode for Read sectors
WRITE	    equ	    $0a	    ; opcode for Write sectors
NCMD	    equ	    6	    ; normal command length (6 bytes)
MAXACSI	    equ	    7	    ; highest ACSI unit#
MAXSCSI	    equ	    15	    ; highest SCSI unit#

; For IDE-AT drives
IDEREAD	    equ	    $20	    ; opcode for Read sectors
IDEWRITE    equ	    $30	    ; opcode for Write sectors
IDENTIFY    equ	    $ec	    ; opcode for Identify Drive
D_IDENTIFY  equ	    2	    ; delay between power on and identify() (500us)
D_WORST	    equ	    2000    ; worst case delay (10s)
IDERDY	    equ	    1000    ; delay to wait for IDE drive to be ready
MAXIDE	    equ	    16	    ; highest IDE-AT unit# (unit 0 ONLY)

; Error codes to return to BIOS
EUNDEV	    equ	    (-15)   ; UNknown DEVice
EREADF	    equ	    (-11)   ; READ Fault
EWRITF	    equ	    (-10)   ; WRITe Fault

; Offsets for registers addressing on data bus
REGBASE	    equ	    1	    ; most are on odd part of data bus
REGSTEP	    equ	    2	    ; for regs that are on word boundaries
REGLSTEP    equ	    4	    ; for regs that are on long word boundaries


;+
; Declarations
;-
.bss
lastacstm:	ds.l	1	; controller last accessed time
_cmdblk:	ds.b	10	; command block
rwflag:		ds.b	1	; 0: read   1: write
.even

.if IDE_AT
sbuf:		ds.l	129	; scratch buffer (must be on long word
				;	boundary)
.even

.endif

.text

;+
; dmaread() - read from a DMA device.
; dmawrite() - write to a DMA device.
;
; LONG	sectnum		$4(sp).l
; WORD	count		$8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;
; Returns 0 if successful.
; Returns a negative number if failure: 
;	EUNDEV (-15L) if unknown device (bad dev number)
;	EREADF (-11L) if read failure
;	EWRITF (-10L) if write failure
;	       (-1L)  if timed-out
;
; Comments:
;	ACSI, SCSI and IDE-AT drives are supported.
;-
	.globl	_dmaread
_dmaread:
	move.b	#0,rwflag		; rwflag = 0 => a read
	move.w	#READ,d1		; d1 = opcode for READ
	bra.b	dmarw
	
	.globl	_dmawrite
_dmawrite:
	move.b	#1,rwflag		; rwflag = 1 => a write
	move.w	#WRITE,d1		; d1 = opcode for WRITE
	
dmarw:
.if IDE_AT
	cmpi.w	#MAXIDE,$e(sp)		; unit# > IDE-AT unit# 16?
.else
.if SCSI
	cmpi.w	#MAXSCSI,$e(sp)		; unit# > SCSI unit# 8-15?
.else
	cmpi.w	#MAXACSI,$e(sp)		; unit# > ACSI unit# 0-7?
.endif
.endif
	bhi	undev			; if so, return unknow device

.if IDE_AT
	cmp.w	#MAXSCSI,$e(sp)		; an IDE-AT unit?
	bhi	ide0			; if so, talk IDE-AT
.endif
					; else talk ACSI or SCSI
	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	d1,(a0)+		; byte 0 = opcode
	move.b	5(sp),(a0)+		; byte 1 = msb of logical block addr
	move.b	6(sp),(a0)+		; byte 2 = logical block addr
	move.b	7(sp),(a0)+		; byte 3 = lsb of logical block addr
	move.b	9(sp),(a0)+		; byte 4 = transfer length (in blocks)
	clr.b	(a0)			; byte 5 = control byte
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = buffer
	tst.b	rwflag			; read or write?
	bne.b	rw0			; it's a write
	bsr	_dorcmd			; send a receive data command
	bra	rw1
rw0:	bsr	_dowcmd			; send a write data command

.if IDE_AT
	bra	rw1			; branch will take place for 
					;	non-IDE drives
*
* Before doing anything with the IDE bus, make sure it's there.
* (The label noide is before at just because it fits better.)
*

noide:	move.l	a1,sp			; got the bus error on IDEASR;
	move.l	a0,$8			; restore vector & sp, return EUNDEV
	bra	undev

ide0:	move.l	$8,a0
	move.l	sp,a1
	move.l	#noide,$8
	tst.b	IDEASR			; read a register to probe for IDE bus
	move.l	a1,sp			; hey! no bus error!
	move.l	a0,$8			; restore vector & sp and continue.

	move.b	$f(sp),d0		; IDE unit#
	bsr	_iderdy			; wait for drive to be ready
	beq	undev			; if drive never gets ready, return
					;   with unknown device
					; else
	move.l	#D_IDENTIFY,d0		; delay required by Conner drives
	add.l	_hz_200,d0		;  between power on and identify()
ide1:	cmp.l	_hz_200,d0
	bcc.b	ide1

	pea	sbuf			; scratch buffer for drive parameters
	move.w	$12(sp),-(sp)		; IDE unit#
	bsr	_identify		; identify()
	addq.w	#6,sp			; clean up stack
	tst.w	d0			; successful?
	bmi	rwend			; if timed-out, return
	bne	rw2			; if error, return with error code
					; else can do read or write
	move.l	#D_IDENTIFY,d0		; delay required by Conner drives
	add.l	_hz_200,d0		;  between identify() and r/w
ide4:	cmp.l	_hz_200,d0
	bcc.b	ide4

	pea	sbuf			; beginning of _identify() data
	bsr	_gcparm			; get drive current parameters
	addq	#4,sp			; clean up stack

	move.w	$e(sp),-(sp)		; physical unit #
	move.l	$c(sp),-(sp)		; buffer
	move.w	$e(sp),-(sp)		; count
	move.l	$c(sp),-(sp)		; logical block address
	move.w	d2,-(sp)		; # sectors per track
	move.w	d1,-(sp)		; # data heads
	tst.b	rwflag			; read or write?
	bne.b	ide2			; (write)
	bsr	_ideread		; read sectors
	bra.b	ide3
ide2:	bsr	_idewrite		; write sectors
ide3:	adda	#16,sp			; clean up stack
.endif	
rw1:	
.if	SCSI
	move.w	sr,-(sp)		; go to IPL 7
	ori	#$700,sr		; no interrupts right now please
	movec	cacr,d1			; d1 = (cache control register)
	ori.w	#$0808,d1		; dump both the I and D cache
	movec	d1,cacr			; update cache control register
	move.w	(sp)+,sr		; restore interrupt state
.endif
	tst.w	d0			; successful?
	ble.b	rwend			; if no error or timed-out, return
					; else
rw2:	moveq	#EREADF,d0		; assume it's a read error
	tst.b	rwflag			; read or write?
	beq.b	rwend			; if read, done
	moveq	#EWRITF,d0		; else, it's a write error
rwend:	rts

undev:	moveq	#EUNDEV,d0
	bra.b	rwend

;+++++++++++++++++++++++++++++++;
;				;
;    ACSI and SCSI specific	;
;				;
;+++++++++++++++++++++++++++++++;

;+
; dorcmd() - send a command which will receive data from the target
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_dorcmd:
.if SCSI
	cmp.w	#MAXACSI,d0		; unit# > ACSI unit# 0 - 7?
	bls.b	rcacsi			; if not, it's an ACSI device
	bsr	_rcvscsi		; else, it's a SCSI device
	rts
.endif
rcacsi:	bsr	_rcvacsi		; it's an ACSI device
	rts


;+
; dowcmd() - send a command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_dowcmd:
.if	SCSI
	cmp.w	#MAXACSI,d0		; unit# > ACSI unit# 0 - 7?
	bls.b	wracsi			; if not, it's an ACSI device
	bsr	_wrtscsi		; else, it's a SCSI device
	rts
.endif
wracsi:	bsr	_wrtacsi		; it's an ACSI device
	rts

	

;+++++++++++++++++++++++++++++++;
;				;
;	ACSI specific		;
;				;
;+++++++++++++++++++++++++++++++;

;+
;  Hardware definitions for ACSI
;-
WDC		equ	$ffff8604
WDL		equ	$ffff8606
WDCWDL		equ	WDC		; used for long writes
XWDL		equ	WDL-WDC		; offset from wdc to wdl

DMAHI		equ	$ffff8609
DMAMID		equ	DMAHI+2
DMALOW		equ	DMAMID+2
GPIP		equ	$fffffa01


;+
;  Tunable (delay) values for ACSI
;-
ACLTMOUT	equ	600		; long time-out (3 s)
ACSTMOUT	equ	20		; short time-out (100 ms)


;+
; LONG _qdone() - Wait for command byte handshake
; LONG _fdone() - Wait for operation complete
; Passed:	nothing
;
; Returns:	EQ: no time-out
;		MI: time-out condition
;
; Uses:		D0
;
;-
_fdone:	move.l	#ACLTMOUT,d0
	bra.b	qd0

_qdone:	move.l	#ACSTMOUT,d0

qd0:	move.l	d0,-(sp)		; save timeout value
	moveq	#2,d0			; busy-wait delay for slow ACSI
	add.l	_hz_200,d0		; minimum 20 microsec.
sdelay:	cmp.l	_hz_200,d0
	bge.b	sdelay
	move.l	(sp)+,d0		; restore timeout value

	add.l	_hz_200,d0
qd1:	cmp.l	_hz_200,d0		; time-out?
	bcs.b	qdq			; (i give up, return NE)
	btst	#5,GPIP			; interrupt?
	bne.b	qd1			; (not yet)

	moveq	#0,d0			; return EQ (no time-out)
	rts

qdq:	moveq	#-1,d0
	rts


;+
; Wait for end of SASI command
;
; Passed:	d1 value to be written to wdl
;
; Returns:	EQ: success (error code in D0.W)
;		MI: time-out (-1 in D0.W)
;		NE: failure (SASI error code in D0.W)
;
; Uses:		d0
;-
_endcmd:
	bsr	_fdone			; wait for operation complete
	bmi.b	endce			; (timed-out, so complain)

.if	SCSI				; dump D cache
	move.w	sr,-(sp)		; go to IPL 7
	ori.w	#$700,sr		; no interrupts right now kudasai
	movec	cacr,d0			; d0 = (cache control register)
	ori.w	#$800,d0		; dump the D cache
	movec	d0,cacr			; update cache control register
	move.w	(sp)+,sr		; restore interrupt state
.endif

	move.w	d1,WDL
	move.w	WDC,d0			; get the result
	and.w	#$00ff,d0		; (clean it up) if non-0 should do a
					; RequestSense command to learn more
endce:	move.l	_hz_200,lastacstm	; update controller last accessed time
	addq.l	#2,lastacstm		; lastacstm = _hz_200 + 2;
	rts				


;+
;  Handle command time-out;
;  Unlock DMA chip and return completion status;
;-
_hdone:	move.w	#$80,WDL	; Landon's code seems to presume we put 
				;  $80 there
	sf	flock		; NOW, signal that we are done
	rts


;+
; delay()
;	5 - 10ms kludge delay for message byte sent back by controller.
;-
_delay:	move.l	d0,-(sp)		; preserve d0
	move.l	lastacstm,d0		; d0 = controller last accessed time
wait:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastacstm)
	bcc.b	wait			;	wait()
	move.l	(sp)+,d0		; restore d0
	rts


;+
; rcvacsi() - send a ACSI command which receives data from target.
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_rcvacsi:

* check to see if the ACSI bus actually exists! Needed for prototype PADs
	move.l	$8,a1
	move.l	sp,a2
	move.l	#noacsi,$8
	tst.w	WDL			; harmless or bus erorr
	move.l	a1,$8			; no bus error - restore & continue
	move.l	a2,sp

	st	flock			; lock FIFO
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$190,XWDL(a1)	;WDL	; toggle DMA chip to direction
	bsr	rstdelay		; delay
	move.w	#$090,XWDL(a1)	;WDL	;  for receiving data
	bsr	rstdelay		; delay
	bsr	setacnt			; set DMA count

	lea	_cmdblk,a0		; a0 = address of command block
	moveq	#0,d1			; direction of DMA is IN
	bsr	sblkacsi		; send the command block
raend:	bra	_hdone			; cleanup after IRQ


;+
; wrtacsi() - send an ACSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_wrtacsi:

* check to see if the ACSI bus actually exists! Needed for prototype PADs
	move.l	$8,a1
	move.l	sp,a2
	move.l	#noacsi,$8
	tst.w	WDC			; harmless or bus erorr
	move.l	a1,$8			; no bus error - restore & continue
	move.l	a2,sp

	st	flock			; lock FIFO
	bsr	_delay
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$90,XWDL(a1)	;WDL	; toggle DMA chip for "send"
	bsr	rstdelay		; delay 
	move.w	#$190,XWDL(a1)	;WDL
	bsr	rstdelay		; delay
	bsr	setacnt			; set DMA count
	
	move.l	#$0100,d1		; d1 = direction of DMA is OUT
	bsr	sblkacsi		; send the command block

waend:	bra	_hdone			; cleanup after IRQ

* You get to this label if there is a bus error when probing for
* the ACSI bus: it's meant for prototype PADs, which don't
* have an ACSI DMA chip.

noacsi:	moveq.l	#-15,d0			; return EUNDEV
	move.l	a2,sp
	move.l	a1,$8
	rts

;+
; sblkacsi() - send command block
;
; Passed:
;	d0.w = physical unit number
;	d1.l = direction of DMA ($0000 for IN or $0100 for OUT)
;	d2.w = command length (NCMD or LCMD)
;	a1.l = pointer to DMA chip
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if time-out
;
; Trashes:
;	d0, d1, d2, a2
;-
sblkacsi:
	move.b	#$88,d1			; next byte is the opcode
	move.w	d1,XWDL(a1)	;WDL

	move.b	#$8a,d1			; following bytes are operands
	lea	_cmdblk,a2		; a2 = address of command block
					; integrate unit # into cmd blk
	lsl.b	#5,d0			; shift unit number into place
	or.b	d0,(a2)			; first command byte = unit # | opcode
					; control byte is sent seperately
	subq.w	#2,d2			; and dbra likes one less 
sa1:	swap	d1			; d1.hw = operand
	move.b	(a2)+,d1		; d1.lw = tells controller next byte
	swap	d1			;	  is an operand
	move.l	d1,(a1)		;WDCWDL
	bsr	_qdone
	bmi.b	sbaend			; if time-out, returns
	dbra	d2,sa1			; else send rest of command block

	move.w	d1,XWDL(a1)	;WDL	; get ready to send control byte
	move.b	#0,d1			; signal sending control byte
	swap	d1			; d1.hw = control byte
	move.b	(a2),d1			; d1.lw = tells controller it's end
	swap	d1			;	  of command
	move.l	d1,(a1)			; send it

	move.b	#$8a,d1			; d1 = wdl value
	bsr	_endcmd			; wait for command completion
sbaend: rts				; heading home


;+
; setadma() - set the ACSI DMA pointer
;
; Passed:
;	a0.l = buffer address
;-
setadma:
	move.l	a0,-(sp)		; move it on stack
	move.b	3(sp),DMALOW		; set low-byte of address
	move.b	2(sp),DMAMID		; set mid-byte of address
	move.b	1(sp),DMAHI		; set high-byte of address
	addq.l	#4,sp			; clean up stack
	rts


;+
; setacnt() - set the ACSI DMA counter
;
; Comments:
;	26-Sep-1991 ml	DMA counter is always set at the maximum 
; (255 sectors) to force the use of the device counter.
;
; Passed:
;	a1.l = pointer to DMA chip
;-
setacnt:
	move.w	#$ff,(a1)		;WDC	; set DMA count
	rts


;+
; Rstdelay()
;	After talking to the DMA chip in a way that may reset it, 
; we need a 8 8Mhz clocks (ie. 1 microsec) delay, before we can
; talk to the chip again.
;-
rstdelay:
	tst.b	GPIP			; delay for 1 microsec
	tst.b	GPIP			; this amounts to 16 16Mhz clocks
	tst.b	GPIP
	tst.b	GPIP
	rts


.if	SCSI

;+++++++++++++++++++++++++++++++;
;				;
;	SCSI specific		;
;				;
;+++++++++++++++++++++++++++++++;

.globl	_resetscsi

; SCSI Interface (NCR 5380) for READ operations
bSCSI	equ	$FFFF8780+REGBASE
SCSIDB	equ	bSCSI+($00*REGSTEP)	; current SCSI data bus
SCSIICR	equ	bSCSI+($01*REGSTEP)	; initiator command register
SCSIMR	equ	bSCSI+($02*REGSTEP)	; mode register
SCSITCR	equ	bSCSI+($03*REGSTEP)	; target command register
SCSICR	equ	bSCSI+($04*REGSTEP)	; current SCSI control register
SCSIDSR	equ	bSCSI+($05*REGSTEP)	; DMA status register
SCSIIDR	equ	bSCSI+($06*REGSTEP)	; input data register
SCSIREI	equ	bSCSI+($07*REGSTEP)	; reset error / interrupt

; SCSI Interface (NCR 5380) for WRITE operations
SCSIODR	equ	bSCSI+($00*REGSTEP)	; output data register
;SCSIICR	bSCSI+($01*REGSTEP)	; initiator command register
;SCSIMR		bSCSI+($02*REGSTEP)	; mode register
;SCSITCR	bSCSI+($03*REGSTEP)	; target command register
SCSIISR	equ	bSCSI+($04*REGSTEP)	; ID select register
SCSIDS	equ	bSCSI+($05*REGSTEP)	; start DMA send
SCSIDTR	equ	bSCSI+($06*REGSTEP)	; start DMS target receive
SCSIDIR	equ	bSCSI+($07*REGSTEP)	; start DMA initiator receive

; SCSI DMA Controller
SDMACTL		equ	$FFFF8714	; WORD

;+
; Tunable (delay) values (in number of _hz_200 ticks) for SCSI
;-
SCLTMOUT	equ	301		; long time-out (at least 1.5 s)
SCSTMOUT	equ	51		; short time-out (at least 250 ms)

;+
; rcvscsi() - send a SCSI command which receives data back.
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_rcvscsi:
	move.l	a0,-(sp)		; save buffer address
	andi.w	#7,d0			; mask off the flags to get unit num
	bsr	sblkscsi		; send command block
	movea.l	(sp)+,a0		; restore buffer address
	tst.w	d0			; successful?
	bmi.b	rsend			; if not successful, return

	movea.l	a0,a1			; a1 -> buffer to read into
	movea.l	#bSCSI,a2		; a2 -> 5380
	move.b	#1,SCSITCR		; set data in phase
	move.b	SCSIREI,d0		; clear potential interrupt

	;+
	; 25-Sep-91 ml.	The long time-out is used instead of the short
	;		time-out to accomodate slow SCSI devices.
	;-
rs0:	bsr	setscltmout		; set up time-out
	bsr	w4req			; wait for REQ to come
	bmi.b	rsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data in phase?
	beq	w4stat			; no, go get status
	move.b	(a2),(a1)+		; read the data byte
	bsr	doack
	bra.b	rs0			; do next byte
rsend:	bsr	_resetscsi		; timed-out, reset SCSI bus
	rts


;+
; wrtscsi() - send a SCSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_wrtscsi:
	andi.w	#7,d0			; mask off the flags to get unit num
	move.l	a0,-(sp)		; save beginning buffer address
	move.w	d2,-(sp)		; save command length
	bsr	sblkscsi		; send command block
	move.w	(sp)+,d2		; restore command length
	move.l	(sp)+,a0		; a0 = where DMA ends
	tst.w	d0			; successful?
	bmi.b	wsend			; if failure, return

	movea.l	a0,a1			; a1 -> buffer to write from
	movea.l	#bSCSI,a2		; a2 -> 5380
	move.b	#0,SCSITCR		; set data out phase
	move.b	SCSIREI,d0		; clear potential interrupt

	;+
	; 25-Sep-91 ml.	The long time-out is used instead of the short
	;		time-out to accomodate slow SCSI devices.
	;-
ws0:	bsr	setscltmout
	bsr	w4req			; wait for REQ to come
	bmi.b	wsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data out phase?
	beq	w4stat			; no, go get status
	move.b	(a1)+,(a2)		; write the data byte
	bsr	doack
	bra.b	ws0			; do next byte
wsend:	bsr	_resetscsi		; timed-out, reset SCSI bus
	rts



;+
; sblkscsi() - send command block
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if time-out
;-
sblkscsi:
	move.l	d2,-(sp)		; save command length
	move.w	d0,-(sp)		; physical unit #
	bsr	selscsi			; select the unit
	addq	#2,sp			; clean up stack
	move.l	(sp)+,d2		; restore command length
	tst.w	d0			; selection successful?
	bmi.b	sbsend			; if timed out, return
					; else proceed
	move.b	#2,SCSITCR		; assert C/D
	move.b	#1,SCSIICR		; assert data bus

	lea	_cmdblk,a1		; a1 -> command block
	subq.w	#1,d2			; dbra likes one less

	bsr	setscstmout		; set a short time-out
ss1:	move.b	(a1)+,d0		; d0.b = byte to be sent
	bsr	hshake			; write that byte
	tst.w	d0
	bmi.b	sbsend			; if timed-out, returns
	dbra	d2,ss1			; until whole command block is sent
	moveq	#0,d0			; all operations successful
sbsend: rts				; heading home


;+
; BOOLEAN selscsi(SCSIUnit) 
; WORD SCSIUnit;
;-
selscsi:
	bsr	setscstmout		; set up a short time-out
sels0:	btst	#6,SCSICR		; STILL busy from last time?
	beq.b	sels1			; if not, it's available
	cmp.l	(a0),d1			; time-out?
	bhi.b	sels0			; not yet, wait some more
	bra.b	sels4			; else, return error

sels1:	move.b	#0,SCSITCR		; data out phase
	move.b	#0,SCSIISR		; no interrupt from selection
	move.b	#$0c,SCSIICR		; assert BSY and SEL
; set dest SCSI IDs
	clr.w	d0
	move.w	4(sp),d1		; get the SCSI unit desired
	bset	d1,d0			; set the appropriate bit
	move.b	d0,SCSIODR		; (real code would set ours too)

	move.b	#$0d,SCSIICR		; assert BUSY, SEL and data bus
	andi.b	#$FE,SCSIMR		; clear arbitrate bit
	andi.b	#$F7,SCSIICR		; clear BUSY

* there must be two "deskew delays" here, but that's only 100ns total...
* the following computations take at least that long before we read
* SCSICR again.

	bsr	setscstmout		; use short time-out
sels3:	btst	#6,SCSICR		; wait for bus to be busy
	bne.b	sels5
	cmp.l	(a0),d1
	bhi.b	sels3

sels4:	moveq	#-1,d0			; time out
	bra.b	sels6
	
sels5:	clr.w	d0			; selection successful
sels6:	move.b	#$0,SCSIICR		; clear SEL and data bus assertion
	rts


;+
; w4stat - wait for status byte and message byte.
;
; Returns:
;	d0.l = returned status or time-out error
;-
w4stat:	bsr	setscstmout		; set up time-out for REQ and ACK
	move.b	#3,SCSITCR		; status in phase
	move.b	SCSIREI,d0		; clear potential interrupt

	bsr	w4req			; wait for status byte
	bmi.b	wstto			; if timed-out, handle it
	moveq	#0,d0			; clear d0
	move.b	SCSIDB,d0		; get the status byte
	bsr	setscstmout		; set up time-out for REQ and ACK
	move.l	d0,-(sp)		; save the status byte
	bsr	doack			; signal that status byte is here
	tst.w	d0			; timed-out?
	beq.b	wst4			; if not, wait for message byte

wst3:	addq.l	#4,sp			; else clean up stack
wstto:	bsr	_resetscsi		; timed-out, reset SCSI bus
	bra.b	wstend			; and return

wst4:	bsr	setscstmout		; set up time-out for REQ and ACK
	bsr	w4req			; wait for message byte
	bmi.b	wst3			; if timed-out, returns

	move.b	SCSIDB,d0		; get and ignore message byte
	bsr	doack			; signal that message byte is here
	tst.w	d0			; timed-out?
	bmi.b	wst3			; if so, return time-out
	move.l	(sp)+,d0		; recall the status byte
wstend:	rts


;+
; w4req() - wait for REQ to come
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
w4req:
wr0:	btst	#5,SCSICR		; waiting for REQ to come
	bne.b	wr1			; if REQ comes, done
	cmp.l	(a0),d1			; time's up?
	bhi.b	wr0			; if not, wait some more
	moveq	#-1,d0			; else, returns timed out
	bra.b	wrend
wr1:	moveq	#0,d0			; returns successful
wrend:	rts


;+
; doack() - assert ACK
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
doack:	ori.b	#$11,SCSIICR		; assert ACK (and data bus)
da0:	btst	#5,SCSICR		; wait for REQ to go away
	beq.b	da1			; if REQ goes away, done
	cmp.l	(a0),d1			; time's up?
	bhi.b	da0			; if not, wait some more
	moveq	#-1,d0			; else returns timed out
	bra.b	daend
da1:	moveq	#0,d0			; returns successful
daend:	andi.b	#$ef,SCSIICR		; clear ACK
	rts


;+
; hshake() - hand shake a byte over to the controller
;
; Passed:
;	d0.b = byte to be handed over
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	Whatever w4req() or doack() returns, which is:
;		 0 - if successful
;		-1 - times out
;-
hshake:	move.w	d0,-(sp)		; preserve d0.w
	bsr	w4req			; wait for REQ to come
	bmi.b	hsend			; if timed out, returns
	move.b	1(sp),SCSIDB		; write a byte out to data bus
	bsr	doack			; assert ACK
hsend:	addq.l	#2,sp			; clean up stack
	rts


*+
* VOID resetscsi();
*-

_resetscsi:
	move.b	#$80,SCSIICR	; assert RST
	bsr	setscstmout	; wait (at least) 250 ms
rst0:	cmp.l	(a0),d1
	bhi.b	rst0
	move.b	#$00,SCSIICR
	bsr	setscltmout	; wait (at least) 1000 ms
rst1:	cmp.l	(a0),d1
	bhi.b	rst1
	move.b	SCSIREI,d1	; clear potential interrupt
	rts


;+
; setscstmout - set up a time-out count for the SCSI for SCSTMOUT ticks
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
setscstmout:
	movea.l	#_hz_200,a0	; a0 -> 200 hz clock
	move.l	#SCSTMOUT,d1	; d0 = SCSTMOUT _hz_200 clicks
	add.l	(a0),d1		; d0 = curr time + # clicks to wait
	rts


;+
; setscltmout - set up a time-out count for the SCSI for SCLTMOUT long
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
setscltmout:
	movea.l	#_hz_200,a0	; a0 -> 200 hz clock
	move.l	#SCLTMOUT,d1	; d0 = SCLTMOUT _hz_200 clicks
	add.l	(a0),d1		; d0 = curr time + # clicks to wait
	rts

.endif



.if IDE_AT

;+++++++++++++++++++++++++++++++;
;				;
;	IDE-AT specific		;
;				;
;+++++++++++++++++++++++++++++++;

; IDE disk interface I/O locations for Read functions

bIDE	equ	$FFF00000+REGBASE	; base address

IDEDR	equ	bIDE-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
IDEER	equ	bIDE+($01*REGLSTEP)	; Error Register
IDESC	equ	bIDE+($02*REGLSTEP)	; Sector Count
IDESN	equ	bIDE+($03*REGLSTEP)	; Sector Number
IDECL	equ	bIDE+($04*REGLSTEP)	; Cylinder Low
IDECH	equ	bIDE+($05*REGLSTEP)	; Cylinder High (2 bits)
IDESDH	equ	bIDE+($06*REGLSTEP)	; SDH register
IDESR	equ	bIDE+($07*REGLSTEP)	; Status Register
IDEASR	equ	bIDE+($0E*REGLSTEP)	; Alternate Status Register
IDEDAR	equ	bIDE+($0F*REGLSTEP)	; Drive Address Register



; IDE disk interface I/O locations for Write functions

;IDEDR	equ	bIDE-REGBASE+($00*REGLSTEP); Data Register (16-bit reg)
IDEWPR	equ	bIDE+($01*REGLSTEP)	; Write Precomp Register (not used)
;IDESC	equ	bIDE+($02*REGLSTEP)	; Sector Count
;IDESN	equ	bIDE+($03*REGLSTEP)	; Sector Number
;IDECL	equ	bIDE+($04*REGLSTEP)	; Cylinder Low
;IDECH	equ	bIDE+($05*REGLSTEP)	; Cylinder High (2 bits)
;IDESDH	equ	bIDE+($06*REGLSTEP)	; SDH register
IDECR	equ	bIDE+($07*REGLSTEP)	; Command Register
IDEDOR	equ	bIDE+($0E*REGLSTEP)	; Digital Output Register


; Byte indices into buffer return by the Identify command

NCYL	equ	2		; offset to # of fixed cylinders
NHEAD	equ	6		; offset to number of heads
NSPT	equ	12		; offset to number of sectors/track
MDLNUM	equ	54		; offset to model number of drive
CONMDL	equ	MDLNUM+26	; offset to Conner's model number


; Default drive parameters of Conner Peripherals - CP2024
CP20NCYL	equ	615	; # of cylinders
CP20NHEAD	equ	4	; # of heads
CP20NSPT	equ	17	; # of sectors/track


;+
; Wait for status to come back
;-
w4int:	move.l	#D_WORST,d0	; d0 = time-out limit
	add.l	_hz_200,d0	; d0 = expiration time
wi0:	btst.b	#5,GPIP		; interrupt?
	beq.b	wi1		; if so, out of the loop
	cmp.l	_hz_200,d0	; time-out?
	bhi.b	wi0		; if not, wait some more
	moveq	#-1,d0		; else, return time-out
	bra.b	wi3
wi1:	moveq	#0,d0		; clear d0
	move.b	IDESR,d0	; d0.b = status returned
	btst	#0,d0		; any error?
	bne.b	wi2		; if yes, return error code
	btst	#3,d0		; else DRQ?
	bne.b	wi3		; if so, just return
	moveq	#0,d0		; else return OK
	bra.b	wi3
wi2:	move.b	IDEER,d0	; else d0.b = error bits
wi3:	rts			; return status or error code



;+
; ideread() - reads from 1 to 256 sectors as specified in the Task File,
;		beginning at the specified sector.
;	   - sector count equal to 0 requests 256 sectors.
;
; ideread(nhd, nspt, sectnum, count, buf, pdev)
; WORD	nhd;		4(sp).w		; # of data heads on pdev
; WORD	nspt;		6(sp).w		; # of physical sectors per track
; LONG	sectnum;	8(sp).l		; logical block address
; WORD	count;		$c(sp).w	; # of sectors to read
; BYTE	*buf;		$e(sp).l	; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD	pdev;		$12(sp).w	; physical device number
;-
	.globl	_ideread
_ideread:
	bsr	set_dhcs	; set physical address
	move.l	$e(sp),a0	; a0 -> buffer to read into
	move.b	$d(sp),IDESC	; set sector count

	move.w	$c(sp),d1	; d1.w = # of sectors to read
	subq	#1,d1		; dbra likes one less

	move.b	#0,IDEDOR	; enable interrupt
	move.b	#IDEREAD,IDECR	; set command code
ider0:	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.b	ider1		; if timed-out, return

	btst	#3,d0		; DRQ?
	beq.b	ider1		; if not, return

	bsr	readbuf		; fill sector buffer
	dbra	d1,ider0	; more to read?
	moveq	#0,d0		; everything's fine
ider1:	rts


;+
; idewrite() - writes from 1 to 256 sectors as specified in the Task File,
;		beginning at the specified sector.
;	    - sector count equal to 0 requests 256 sectors.
;
; idewrite(nhd, nspt, sectnum, count, buf, pdev)
; WORD	nhd;		4(sp).w		; # of data heads on pdev
; WORD	nspt;		6(sp).w		; # of physical sectors per track
; LONG	sectnum;	8(sp).l		; logical block address
; WORD	count;		$c(sp).w	; # sectors to read
; BYTE	*buf;		$e(sp).l	; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD	pdev;		$12(sp).w	; physical device number
;-
	.globl	_idewrite
_idewrite:	
	bsr	set_dhcs	; set physical address
	move.l	$e(sp),a0	; a0 -> buffer to write from
	move.b	$d(sp),IDESC	; set sector count

	move.w	$c(sp),d1	; d1.w = # of sectors to read
	subq	#1,d1		; dbra likes one less

	move.b	#0,IDEDOR	; enable interrupt
	move.b	#IDEWRITE,IDECR	; set command code
idew0:	btst.b	#3,IDEASR	; DRQ?
	beq.b	idew0		; if not, wait longer
idew1:	bsr	wrtbuf		; fill sector buffer
	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.b	idew2		; if timed-out, return
	btst	#3,d0		; DRQ?
	beq.b	idew2		; if not, return
	dbra	d1,idew1	; else go transfer data
	moveq	#0,d0		; everything's fine
idew2:	rts


;+
; set_dhcs() - convert a logical block address into a physical address.
;	     - set drive #, head #, cylinder # and sector # in task file.
;
; Passed:
;	8(sp).w = nhd = # of data heads
;	$a(sp).w = nspt = # of physical sectors per track
;	$c(sp).l = logical block address
;	$16(sp).w = physical unit #
;-
set_dhcs:
	move.l	$c(sp),d1	; d1.l = logical block address
	move.w	8(sp),d2	; d2.w = # of data heads
	move.w	$a(sp),d0	; d0.w = # of physical sectors per track
	mulu	d0,d2		; d2.l = # of sectors per cylinder
				;      = # heads * # of sectors per track
	divu.w	d2,d1		; d1.w = cylinder #
				;      = log block addr / #spc
	move.b	d1,IDECL	; set cylinder low
	lsr.l	#8,d1		; d1.b = cylinder high
	move.b	d1,IDECH	; set cylinder high
	lsr.l	#8,d1		; d1.l = sector # within the cyl
	divu.w	d0,d1		; d1.w = head #
				;      = sector # within cyl / #spt
	move.w	$16(sp),d0	; d0.w = physical unit #
	andi.b	#7,d0		; mask off flags from physical unit #
	lsl.b	#4,d0		; shift unit # to place
	or.b	d0,d1		; or in drive #
	move.b	d1,IDESDH	; set drive and head #
	swap	d1		; d1.w = sector # (base 0)
	addq.w	#1,d1		;      = sector # + 1 (base 1)
	move.b	d1,IDESN	; set sector #
	rts

;+
; identify() - allows the Host to receive parameter information from
;	       the drive.
;
; identify(pdev, buf)
; WORD	pdev;	4(sp).w		; physical unit #
; BYTE	*buf;	6(sp).l		; buffer to put data
;-
	.globl	_identify
_identify:
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.l	6(sp),a0	; a0 -> buffer

	move.b	#0,IDEDOR	; enable interrupt
	move.b	#IDENTIFY,IDECR	; set command code
	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.b	id0		; if timed-out, return
	btst	#3,d0		; DRQ?
	beq.b	id0		; if not, return with error

	bsr	readbuf		; read data
	moveq	#0,d0		; everything's fine

id0:	rts 


;+
; readbuf() - reads 512 bytes (128 longs) of data into sector buffer.
;
; Passed:
;	a0.l = buffer to store data read from sector buffer
;-
readbuf:
	moveq	#31,d0		; d0 = (# of words of data to read / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
rb0:	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	dbra	d0,rb0		; repeat until all done
	rts


;+
; wrtbuf() - writes 512 bytes (128 longs) of data to sector buffer.
;
; Passed:
;	a0.l = buffer with data to write to sector buffer
;-
wrtbuf:
	moveq	#31,d0		; d0 = (# of words of data to read / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
wb0:	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	dbra	d0,wb0		; repeat until all done
	rts


;+
; _iderdy() - test if the IDE drive is ready
;
; Passed:
;	d0.b = IDE drive unit #
;
; Returns: 0 - if drive is NOT ready
;	   1 - if drive is ready
;-
	.globl	_iderdy
_iderdy:
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#$50,d1		; ready status
	move.l	#IDERDY,d0	; set up timer
	add.l	_hz_200,d0
ir0:	cmp.b	IDEASR,d1	; is drive ready and not busy?
	beq.b	ir1		; if so, return with drive ready
	cmp.l	_hz_200,d0	; time-out yet?
	bcc.b	ir0		; if not, wait longer
	moveq	#0,d0		; else return drive NOT ready
	rts
ir1:	moveq	#1,d0		; else, drive is ready
	rts

;+
; gcparm() - get current drive parameters
;
; gcparm(buf)
; char	*buf;	$4(sp).l    /* -> data returned by identify() */
;
; Returns:
;	d0.w = # of default cylinders
;	d1.w = # of default heads
;	d2.w = # of default sectors per track
;-
	.globl	_gcparm
_gcparm:
	move.l	4(sp),a0	; a0 -> data buffer
	add.l	#CONMDL,a0	; a0 -> where Conner model number is
	move.l	a0,-(sp)
	pea	cp2024
	move.w	#6,-(sp)
	bsr	strcmp		; compare model# with "CP2024"
	adda	#10,sp		; clean up stack
	tst.w	d0		; is unit the CP2024 (Kato 20Mb)?
	bne.b	gcp0		; if not, handle the normal way
				; else return default values of CP2024
	move.w	#CP20NCYL,d0	; d0.w = # of cylinders
	move.w	#CP20NHEAD,d1	; d1.w = # of heads
	move.w	#CP20NSPT,d2	; d2.w = # of spt
	bra.b	gcpend

gcp0:	move.l	4(sp),a0
	move.w	NCYL(a0),d0	; d0.w = # of cylinders
	move.w	NHEAD(a0),d1	; d1.w = # of heads
	move.w	NSPT(a0),d2	; d2.w = # of sectors per track

gcpend:	rts



conner:	dc.b	"Conner",0
.even
cp2024:	dc.b	"CP2024",0
.even


;+
; strcmp() - compare two strings
;
; Passed:
;	4(sp).w  = n (# of bytes to compare)
;	6(sp).l  = address of first string
;	10(sp).l = address of second string
;
; Returns:
;	d0.w = 0	if first n bytes of the 2 strings are the same
;	     = non-0    otherwise
;-
strcmp:	movem.l	d1/a0-a1,-(sp)	; save registers d1, a0 and a1
	move.w	16(sp),d1	; d1 = byte count
	subq.w	#1,d1		; dbra likes one less
	move.l	18(sp),a0	; a0 -> string 1
	move.l	22(sp),a1	; a1 -> string 2
	moveq	#1,d0		; assume strings are not the same
str0:	cmpm.b	(a0)+,(a1)+	; characters the same?
	bne.b	str1		; if not, return
	dbra	d1,str0		; else compare next character
	moveq	#0,d0		; the strings are the same
str1:	movem.l	(sp)+,d1/a0-a1	; restore registers d1, a0 and a1
	rts


.endif


