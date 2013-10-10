;************************************************************************
;
; SNDXBIOS.S
;
;	All variables used in the sound routines.
;
;	Started:	06/23/93
;	Last Update:	07/13/92
;
;	Copyright Atari Corporation 1992
;
; Updates:
; 07/15/92  MS Changed setinterrupt due to doc error.
; 07/13/92  MS Changed rev added buffptr() to lowsnd.s
;	
;
;************************************************************************

.include "c:\\include\\atari.s"		; include "atari.s" ST definitions.


; --------------------------------------------------
; Internal variables
; --------------------------------------------------
	.globl	chanlock	; Channel locked semiphore.
	.globl	oldvol		; Old volume setting if reset occured.

; --------------------------------------------------
; Internal data constants.
; --------------------------------------------------


; --------------------------------------------------
; Defines
; --------------------------------------------------


REENTER		=	3	; # of times trap 14 reenters.


	.text
start:
	move.l	a7,a5		; save a7 so we can get the base page address
	lea	stack,a7	; set local stack
	move.l	4(a5),a5	; basepage address
	move.l	TLEN(a5),d0
	add.l	BLEN(a5),d0
	add.l	DLEN(a5),d0
	add.l	#BPSZ,d0	; add base page length
	move.l	d0,-(sp)	; save prg size.
	Mshrink a5,d0

; Set up Physical Bios.
	lea	cur_blk,a0
	move.l	a0,cur_blk		; Init reenter save area and ...

	Super				; Get into Super mode
	move.l	TRP14,sv_tp14		; Save old trap 14 handler.
	move.l	#htp14,TRP14		; Install our trap 14 monitor.
	User
;	
	Cconws	#sndvers	; Print SND xbios version
;
	move.l	(sp)+,d7	; get prg size.
	Ptermres d7,#0		; d7 = size of memory to keep



; ************************************************************************
; htp14		Monitoring trap #14 handler.
;
; On the stack:
;	From super-		From user
;	visor mode:		mode:
;	-----------		------------
;	N(sp) args		N(usp) args
;	6(sp) func#		6(usp) func#
;	2(sp) ret		2(ssp) ret
;	 (sp) SR		 (ssp) SR
;
; Monitors trap 14 calls for the Atari CD Extended Bios calls.
;
;************************************************************************
htp14:
	move.l	cur_blk,a0		; a0-> free variable stack area.
	move.l	sp,-(a0)		; save stack pointer
	move.w	#6,d0			; Init to supervisor offset
	btst	#5,(sp)			; If(in user mode)
	bne	.b_supr			; 
	move.l	usp,sp			; THEN use user stack
	clr.w	d0			; no supervisor offset
	bra	.cont
.b_supr:				; Test for TT or ST
	tst.w	_long_frame
	beq	.cont
	addq	#2,d0			; Accounts for TT word vector offset.
.cont:
	cmp.w	#$80,(sp,d0.w)		; IF(less than SND Xbios range) ||
	blt	old_tr14		;   (greater than SND Xbios range)
	cmp.w	#$9f,(sp,d0.w)		; THEN jump to the old handler
	bgt	old_tr14
					; ELSE this is a SND Xbios Call.
	cmp.w	#2,d0			; If(d0 <= 0) we are on user stack
	ble	.do_user

	move.w	(sp)+,-(a0)		; Save ST or TT status register.
	move.l	(sp)+,-(a0)		; Save ST or TT exception return addr.
	tst.w	_long_frame		; IF(0) We are on ST.
	beq	.st
	move.w	(sp)+,-(a0)		; Save TT vector offset.
.st:
	move.w	#1,-(a0)		; Set flag to super mode.
	bra	.do_func

.do_user:
	clr.w	-(a0)			; Set flag to user mode.
;
.do_func:
	movem.l	d3-d7/a3-a6,-(a0)	; Save registers.
	move.l	a0,cur_blk		; Update free block pointer.

	lea	vectbl,a1
	move.w	(sp),d1			; d1 = opcode.
	sub.w	#$80,d1			; ELSE ( Handle xbios Call )
	asl.w	#2,d1			; *4
	move.l	(a1,d1),a1		; Get function address.
	jsr	(a1)			; handle function
;
	move.l	cur_blk,a0		; Get variables.
	movem.l	(a0)+,d3-d7/a3-a6	; Restore registers.
;
restore:
	tst.w	(a0)+			; IF(0) User mode.
	beq	exit

	tst.w	_long_frame		; IF(0) We are on ST.
	beq	.st1
	move.w	(a0)+,-(sp)		; restore TT vector offset.
.st1:
	move.l	(a0)+,-(sp)		; restore ST or TT rte return addr.
	move.w	(a0)+,-(sp)		; restore ST or TT status register.
exit:
	move.l	(a0)+,sp		; restore stack pointer.
	move.l	a0,cur_blk		; Update current block pointer.
	rte


; --------------------------------------------------------------------------
; Old trap #14 handler.
;
; --------------------------------------------------------------------------
old_tr14:				; Let the Atari ST Bios Handle IT!
	move.l	(a0)+,sp		; restore stack pointer
	move.l	a0,cur_blk		; Update reenter pointer.
	move.l	sv_tp14,a0		; a0 pointer to save block
	jmp	(a0)			; jmp to old handler
	illegal				; let the old_hand return to the caller


		.bss
;
; These variables are for the sound system only
;
oldvol:		.ds.w	1		; old volume before mute operation.
chanlock:	.ds.b	1		; Sound semiphore.



;************************************************************************
; Xbios Block Storage Section For trap handler only
;************************************************************************
		.ds.b	512		; 512 bytes
stack:		.ds.l	1		; This programs stack area
sv_tp14:	.ds.l	1		; save the old trap 14 handler
		.ds.l	(6+12)*REENTER	; Reenter save area.
cur_blk:	.ds.l	1		; Trap 14 save area.


		.data
		.even
;************************************************************************
; Xbios Data Storage Section
;************************************************************************
		.even		; SNDBOS ver string (32 bytes).
sndvers:	.dc.b	"FALCON SND Xbios ver 0.10 7/15/92",CR,LF,0

		.even
;************************************************************************
; Function  Table	This table contains entries for all functions
;			mapped to $80 - $9f range.
;************************************************************************
vectbl:
	.dc.l	locksnd			; $80 Open a sound channel
	.dc.l	unlocksnd		; $81 Close a sound channel.
	.dc.l	soundcmd		; $82 Perform a sound functions.
	.dc.l	setbuffer		; $83 Set rec/play buffer location.
	.dc.l	setmode			; $84 Set sound 8/16 bit stereo/mono.
	.dc.l	settrack		; $85 Set number of tracks.
	.dc.l	setmontrack		; $86 Set monitor track.
	.dc.l	setinterrupt		; $87 Set interrupt type.
	.dc.l	buffoper		; $88 Set rec/play buffer operations.
	.dc.l	dsptristate		; $89 Tristates DSP bus
	.dc.l	gpio			; $8A Talks to gpio acording to mode.
	.dc.l	devconnect		; $8B connects src to dst devices.
	.dc.l	sndstatus		; $8C Get current sound status.
	.dc.l	buffptr			; $8D Get current buffer offsets.
	.dc.l	func_error		; 
	.dc.l	func_error		; 
	.dc.l	func_error		; 
	.dc.l	func_error		; 
	.dc.l	func_error		; $91 Not used.
	.dc.l	func_error		; $92 Not used.
	.dc.l	func_error		; $93 Not used.
	.dc.l	func_error		; $94 Not used.
	.dc.l	func_error		; $95 Not used.
	.dc.l	func_error		; $96 Not used.
	.dc.l	func_error		; $97 Not used.
	.dc.l	func_error		; $98 Not used.
	.dc.l	func_error		; $99 Not used.
	.dc.l	func_error		; $9A Not used.
	.dc.l	func_error		; $9B Not used.
	.dc.l	func_error		; $9C Not used.
	.dc.l	func_error		; $9D Not used.
	.dc.l	func_error		; $9E Not used.
	.dc.l	func_error		; $9F Not used.
	.end

