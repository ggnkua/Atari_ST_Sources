;
;	ACCSTART.S	4/30/85			MIKE SCHMAL
;
;	DESK ACCESSORY STARTUP PROGRAM
;
; This version only contains what is necessary for a desk accessory to run
; All other garbage has been removed as not to waste memory.
;
;	Revised 3/14/88 - RMS
;	1/12/89 for mixers.   RZ
;

	.text

	.globl  _donoise
	.globl	_crystal
	.globl	_ctrl_cnts
	.globl	_gemdos
	.globl	_set_state
	.globl	_val_slider
	.globl	_xbios
;
;	SYSTEM CONSTANTS
;
conterm	=	$0484
ucr	=	$FFFA29
tddr	=	$FFFA25
tdcr	=	$FFFA1D

;
;  Must be first object file in link statement
;
_start:

	move.l	#ustk,a7	; get program stack
	jsr	_main		; go to program
	move.l	#0,(a7)		; back to gemdos
	trap	#1
;
; necessary for the binds to work, everyone gets one
;

_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts
;
;	trap14	Taken straight from the hitchhikers guide
;

_xbios:
	move.l	(sp)+,saveret	; pop return address
	trap	#14
	move.l	saveret,-(sp)	; restore return address
	rts
;
;	trap1	Virtually identical to trap14
;
_gemdos:
	move.l	(sp)+,saveret	; pop return address
	trap	#1
	move.l	saveret,-(sp)	; restore return address
	rts


;
;
;	Added 3/3/89               R.Z.
;
;
;	VAL_SLIDER  Display a Color-Mix Slider value
;
;	val_slider(value,string)
;		Insert ASCII equivalent of value into string
;		NOTE: value must be less than 100
;

_val_slider:
	move.l	6(sp),a0	; a0 = String ptr
	moveq	#0,d0
	move	4(sp),d0	; d0 = Hex value
	divu	#10,d0
	beq	.noten
	add.b	#'0',d0		; Ten's place
	move.b	d0,(a0)+
.noten:	swap	d0
	add.b	#'0',d0
	move.b	d0,(a0)+	; One's place
	move.b	#0,(a0)+
	rts


; ==================================================
;  	SET STATE OF RS232 PORT
; ==================================================

_set_state:
	move.w	#$ffff,-(sp)	; scr
	move.w	#$ffff,-(sp)	; tsr
	move.w	#$ffff,-(sp)	; rsc
	move.w	#$ffff,-(sp)	; ucr
;
	lea	_rsave,a0	; flow control
	move.b	4(a0),d0
	ext.w	d0
	move.w	d0,-(sp)	; flow control to stack
;
	clr.w	d0
	move.b	1(a0),d0	; baud rate
	lea	_remap2,a1
	move.b	(a1,d0.w),d0
	ext.w	d0
	move.w	d0,-(sp)	; baud rate to stack
	move.w	#15,-(sp)
	trap	#14
	adda.w	#$e,sp		; clean up the stack	

	bsr	super		; into supervisor

	clr.w	d0
	lea	_rsave,a0	; flow control
	move.b	1(a0),d0	; get baud rate
	cmp.b	#14,d0		; This code is necessary in order to fix
	blt	no_bugfix	; the bug in the 11/20/85 release of the roms.
	movea.l	#tdcr,a0	; Timer d+c control reg
	move.b	(a0),d1		; involving baud rates of 50 and 75.
	and.b	#$f0,d1		; mask out old value
	or.b	#$02,d1		; or in new value
	move.b	d1,(a0)		; stuff it in
	movea.l	#tddr,a0	; a0 ->timer d data reg
	cmp.w	#14,d0
	bne	do_50
	move.b	#102,(a0)	; set new data value for 75 baud
	bra	no_bugfix
do_50:
	move.b	#154,(a0)	; set new data value for 50 baud
no_bugfix:
	movea.l	#ucr,a0
	move.b	(a0),d0		; get ucr byte
	lea	_rsave,a0
	moveq	#0,d1
	move.b	3(a0),d1	; bits/char
	asl.b	#5,d1
	and.b	#$99,d0		; clear bits 1,2,5,6
	or.b	d1,d0
	moveq	#0,d1
	move.b	2(a0),d1	; parity
	bne	prty1
	bclr	#2,d0		; disable parity
	bra	prtyout
prty1:
	bset	#2,d0		; enable parity
	bclr	#1,d0		; clear odd/even
	cmp.b	#2,d1
	bne	prtyout		; since bit=0 odd parity
	bset	#1,d0		; select even parity
prtyout:
	move.b	d0,ucr		; store new state
	bsr unsuper
	rts

; =================================================
; GET INTO SUPERVISOR MODE
; =================================================

super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp
	rts

; =================================================
; GET OUT OF SUPERVISOR MODE
; =================================================

unsuper:
	move.l	savessp,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; return to user mode
	addq.l	#6,sp
	rts


;
;	DONOISE	Set console noise bits
;
;	param 0 = click on/off (word)
;	param 1 = bell on/off (word)
;
_donoise:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp	; save old ssp

	move.w	4(sp),d0
	lsl.w	#2,d0
	or.w	6(sp),d0
	and.b	#$0fa,conterm
	or.b	d0,conterm	; set new bell and click values

	move.l	savessp,-(sp)	; restore old ssp
	move.w	#$20,-(sp)
	trap	#1		; exit supervisor mode
	addq.l	#6,sp
	rts

;
;	Constant Data
;
	.data
    	.even
_ctrl_cnts:			 	;	Application Manager
	.dc.b	0, 1, 0			; func 010		
      	.dc.b	2, 1, 1			; func 011		
       	.dc.b	2, 1, 1 		; func 012		
	.dc.b	0, 1, 1			; func 013		
	.dc.b	2, 1, 1			; func 014		
	.dc.b	1, 1, 1			; func 015		
	.dc.b	0, 0, 0			; func 016		
	.dc.b	0, 0, 0			; func 017		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 1, 0			; func 019		
;							 Event Manager
	.dc.b	0, 1, 0			; func 020		
	.dc.b	3, 5, 0			; func 021		
	.dc.b	5, 5, 0			; func 022		
	.dc.b	0, 1, 1			; func 023		
	.dc.b	2, 1, 0			; func 024		
	.dc.b	16, 7, 1 		; func 025		
	.dc.b	2, 1, 0			; func 026		
	.dc.b	0, 0, 0			; func 027		
	.dc.b	0, 0, 0			; func 028		
	.dc.b	0, 0, 0			; func 009		
;							 Menu Manager
	.dc.b	1, 1, 1			; func 030		
	.dc.b	2, 1, 1			; func 031		
	.dc.b	2, 1, 1			; func 032		
	.dc.b	2, 1, 1			; func 033		
	.dc.b	1, 1, 2			; func 034		
	.dc.b	1, 1, 1			; func 005		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0			; func 009		
;							 Object Manager
	.dc.b	2, 1, 1			; func 040		
	.dc.b	1, 1, 1			; func 041		
  	.dc.b	6, 1, 1			; func 042		
	.dc.b	4, 1, 1			; func 043		
	.dc.b	1, 3, 1			; func 044		
	.dc.b	2, 1, 1			; func 045		
	.dc.b	4, 2, 1			; func 046		
	.dc.b	8, 1, 1			; func 047		
	.dc.b	0, 0, 0			; func 048		
	.dc.b	0, 0, 0			; func 049		
;							 Form Manager
	.dc.b	1, 1, 1			; func 050		
	.dc.b	9, 1, 1			; func 051		
	.dc.b	1, 1, 1			; func 002		
	.dc.b	1, 1, 0			; func 003		
	.dc.b	0, 5, 1			; func 004		
	.dc.b	0, 0, 0			; func 005		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0			; func 009		
;							 Dialog Manager
	.dc.b	0, 0, 0			; func 060		
	.dc.b	0, 0, 0			; func 061		
	.dc.b	0, 0, 0			; func 062		
	.dc.b	0, 0, 0			; func 003		
	.dc.b	0, 0, 0			; func 004		
	.dc.b	0, 0, 0			; func 005		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0			; func 009		
;							Graphics Manager
	.dc.b	4, 3, 0			; func 070		
	.dc.b	8, 3, 0			; func 071		
	.dc.b	6, 1, 0			; func 072		
	.dc.b	8, 1, 0			; func 073		
	.dc.b	8, 1, 0			; func 074		
	.dc.b	4, 1, 1			; func 075		
	.dc.b	3, 1, 1			; func 076		
	.dc.b	0, 5, 0			; func 077		
	.dc.b	1, 1, 1			; func 078		
	.dc.b	0, 5, 0			; func 009		
;							Scrap Manager
	.dc.b	0, 1, 1			; func 080		
	.dc.b	0, 1, 1			; func 081		
	.dc.b	0, 0, 0			; func 082		
	.dc.b	0, 0, 0			; func 083		
	.dc.b	0, 0, 0			; func 084		
	.dc.b	0, 0, 0			; func 005		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0			; func 009		
;							fseler Manager
	.dc.b	0, 2, 2			; func 090		
	.dc.b	0, 0, 0			; func 091		
	.dc.b	0, 0, 0			; func 092		
	.dc.b	0, 0, 0			; func 003		
	.dc.b	0, 0, 0			; func 004		
	.dc.b	0, 0, 0			; func 005		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0 		; func 009		
;							Window Manager
	.dc.b	5, 1, 0			; func 100		
	.dc.b	5, 1, 0			; func 101		
	.dc.b	1, 1, 0			; func 102		
	.dc.b	1, 1, 0			; func 103		
	.dc.b	2, 5, 0			; func 104		
	.dc.b	6, 1, 0			; func 105		
	.dc.b	2, 1, 0			; func 106		
	.dc.b	1, 1, 0			; func 107		
	.dc.b	6, 5, 0			; func 108		
	.dc.b	0, 0, 0 		; func 009		
;							Resource Manger
	.dc.b	0, 1, 1			; func 110		
	.dc.b	0, 1, 0			; func 111		
	.dc.b	2, 1, 0			; func 112		
	.dc.b	2, 1, 1			; func 113		
	.dc.b	1, 1, 1			; func 114		
	.dc.b	0, 0, 0			; func 115		
	.dc.b	0, 0, 0			; func 006		
	.dc.b	0, 0, 0			; func 007		
	.dc.b	0, 0, 0			; func 008		
	.dc.b	0, 0, 0			; func 009		
;							Shell Manager
	.dc.b	0, 1, 2			; func 120		
	.dc.b	3, 1, 2			; func 121		
	.dc.b	1, 1, 1			; func 122		
	.dc.b	1, 1, 1			; func 123		
	.dc.b	0, 1, 1			; func 124		
	.dc.b	0, 1, 2			; func 125		

;
;	Random Store
;
	.bss
	.even
saveret:
	.ds.l	1
	.ds.l	256
ustk:	
	.ds.l	1
savessp:
	.ds.l	1

	.end
