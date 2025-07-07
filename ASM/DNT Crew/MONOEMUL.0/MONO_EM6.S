;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The Blitter Mono Emulator. V6.00 By Nullos//DNT-Crew 1992
;
; ...is based on the Mick West's MONO_EMU V5.00
; This new version contains more options, and was entirely recoded.
; Please use GENST 2.20 (or later) with "Tab setting: 11".
; Have fun, and keep the pressure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RSRESET
Mono	rs.l	1		; Base address of mono screen
Med	rs.l	1		; --------------- medium screen
MonoPos	rs.w	1		; Offset in both screens
MonoLines	rs.w	1		; Pairs of mono lines per VBL
Swap0	rs.w	1		; Odd and even lines, for the
Swap1	rs.w	1		; new algorith.
__size	rs.b	0		; Size of this struct.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Some sys-vars used in this program...
; Shifter
v_base_h	equ	$ffff8201
v_base_m	equ	$ffff8203
v_base_l	equ	$ffff820d
v_color0	equ	$ffff8240
v_color1	equ	$ffff8242
v_color2	equ	$ffff8244
v_color3	equ	$ffff8246
v_resol	equ	$ffff8260
; Blitter
BLIT_base	equ	$ffff8a00
b_raster	equ	$0
b_src_xinc	equ	$20
b_src_yinc	equ	$22
b_src_adr	equ	$24
b_mask1	equ	$28
b_mask2	equ	$2a
b_mask3	equ	$2c
b_dst_xinc	equ	$2e
b_dst_yinc	equ	$30
b_dst_adr	equ	$32
b_x_count	equ	$36
b_y_count	equ	$38
b_hop	equ	$3a
b_op	equ	$3b
b_ctrl	equ	$3c
b_mode	equ	$3d
;
flock	equ	$43e
_v_bas_ad	equ	$44e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	OPT	O+		; Optimiz branch and 0(An)
	OPT	W-		; No warning.
	OUTPUT	MONO_EM6.PRG	;

SystemSSP	bra	MAIN		; This place is further used
				; to store Super() result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the emulator run !.
LastWill	move.l	#XBIOS,$B8.w	; Set up the new XBIOS vector,
	move.l	#VBLANK,$70.w	; the new VBLANK vector and
	move.l	SystemSSP(pc),-(sp)	; Restore the Supervisor stack
	move.w	#$20,-(sp)		; And go back to User mode
	trap	#1		;
	clr.w	(sp)		; Exit ok for GEM
	move.l	a6,-(sp)		; Length of program + data space
	move.w	#$31,-(sp)		; terminate and stay resident (TSR)
	trap	#1		; Finished this AUTO program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is the new XBIOS routine
; We are allowed to use A0/D0 (and maybe D0-D2/A0-A2, but I'm not sure)
; without saving.
	dc.b	'XBRA'		; XBRA specifications
	dc.b	'MEMU'		; great name isn't it ?
	dc.l	0		; old_vec
XBIOS	lea	6(sp),a0		; a0=SSP+6, after SR&PC
	btst	#5,(sp)		; Call from Super ?
	bne.s	*+4		;
	move.l	usp,a0		; No, get the user stack
	move.w	(a0)+,d0		; Get XBIOS instruction code
	subq.w	#2,d0		; Physbase ?
	beq.s	.xphys		;
	subq.w	#2,d0		; Getrez ?
	beq.s	.xgrez		;
	subq.w	#1,d0		; Setscreen ?
	beq.s	.xset		;
.xend	move.l	XBIOS-4(pc),a0	; No, let the standard Xbios
	jmp	(a0)		; have fun with this call.

.xphys	move.l	VARS+Mono(pc),d0	; The pseudo-monochrome screen
	rte			;

.xgrez	moveq	#2,d0		; We are in monochrome, believe
	rte			; me...

.xset	addq.l	#4,a0		; Look for physbase
	move.l	(a0),d0		; get the wanted physbase
	bmi.s	.x0		; no change ?
	move.l	d0,VARS+Mono	; keep it in mind
.x0	moveq	#-1,d0		;
	move.l	d0,(a0)+		; No change of rezol
	move.w	d0,(a0)+		; and physbase
	bra.s	.xend		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Palette	dc.w	0,0,0
; This is the new VBLANK routine
	dc.b	'XBRA'		; XBRA specifications
	dc.b	'MEMU'		; Wooow, I love MEMU
	dc.l	0		; old_vec
VBLANK	movem.l	d0-a6,-(sp)	; Save all registers
	lea	VARS(pc),a6	; Var in memory

	moveq	#0,d0		; Set up colors in registers
	movem.w	Palette(pc),d1-d3	; D0 to D3 (D0=black)
	lsr.w	v_color0.w		; Check inverted (bit 0)
	bcc.s	*+4		; is it ?
	exg.l	d0,d3		; yes, invert B&W colors
	movem.w	d0-d3,v_color0.w	;
	moveq	#0,d0                 ;
	move.b	v_base_h.w,d0	; Video base
	lsl.l	#8,d0		; 
	move.b	v_base_m.w,d0	;
	lsl.l	#8,d0		;
	move.b	v_base_l.w,d0	; Don't forget low byte for STE!
	movea.l	Med(a6),a1		; a1 = phys.screen (Medium rez)
	cmp.l	a1,d0		; Another physical monoscreen
	beq.s	GetScreen		; is wanted ?
	move.l	d0,Mono(a6)	; Ok, remember its location
	move.l	a1,d0		; and put the Med screen back
	move.b	d0,v_base_l.w	; to its original position
	lsr.w	#8,d0		;
	move.l	d0,$ffff8200.w	;

GetScreen	movea.l	Mono(a6),a0	; get virtual mono phys.screen
	move.w	MonoPos(a6),d2	; Get position in the screen RAM
	move.w	d2,d3		; D3 is used later...
	mulu.w	#160,d2		; Address offset
	adda.l	d2,a0		; Offset position in mono screen
	adda.l	d2,a1		; Offset pos in real medium screen
	adda.w	Swap0(a6),a0	; First or second pass
	adda.w	Swap1(a6),a1	; 

	move.w	MonoLines(a6),d0	; get preset speed
	tst.w	flock.w		; Disk access ?.
	beq.s	*+4		; If yes, use low speed (2)
	moveq	#2,d0		; so TOS can run faster.

	lea	BLIT_base.w,a2	; Blitter registers
	move.w	b_y_count(a2),d4	; Y_count for fun
	tst.b	b_ctrl(a2)		; Is blitter active ?
	bpl.s	vbl_0		; no,skip this
	moveq	#0,d4		; 
wait_blit	tas	b_ctrl(a2)		; Wait end of its work
	bmi.s	wait_blit		;
vbl_0	movem.l	b_src_xinc(a2),d5-d7/a3-a5 ;Save all registers
	move.l	b_hop(a2),-(sp)	;
	moveq	#-1,d1		; Prepare mask
	move.l	d1,b_mask1(a2)	;
	move.w	d1,b_mask3(a2)	;
	bra.s	vbl_8		;

vbl_6	move.l	a0,b_src_adr(a2)	; Next mono line
	move.l	a1,b_dst_adr(a2)	; Next mid-rez line
	move.l	#$20052,b_src_xinc(a2); On mono line
	move.l	#$40004,b_dst_xinc(a2); Two planes,every mid-rez line
	move.w	#$0203,b_hop(a2)	; Source only& No logical op
	move.l	#$280005,b_x_count(a2); Please transfert 40 words*5
	move.w	#$c000,b_ctrl(a2)	; HOG on..and Blitter starts !
	addq.w	#5,b_y_count(a2)	; another 5*40...
	move.w	#$c000,b_ctrl(a2)	; The blitter refresh all its
				; registers, so the 2 transferts
				; can be linked easely.
vbl_7	lea	20*80(a0),a0	; next mono lines
	lea	10*160(a1),a1	; next mid-rez lines
	addi.w	#10,d3		; +10 lines
	cmpi.w	#200,d3		; end of screen
	bne.s	vbl_8		; no
	moveq	#0,d3		; yes !
	lea	-32000+$0050(a0),a0	; restart addresses for
	lea	-32000+$0002(a1),a1	; mono and mid-rez screen.
	eori.l	#$00500002,Swap0(a6)	; odd <-> even lines
	bne.s	vbl_8		; from even to odd lines ?
	lea	-160(a0),a0	; No, come back to the start
	subq.l	#4,a1		; of the two screens...
vbl_8	dbf	d0,vbl_6		; next group of lines

vbl_10	move.w	d3,MonoPos(a6)	; save position
	movem.l	d5-d7/a3-a5,b_src_xinc(a2);Restore all registers,except
	move.l	(sp)+,b_hop(a2)	; the y_count one
	tst.w	d4		; y_count must be restored ?
	beq.s	vbl_end		; No,skip this
	move.w	d4,b_y_count(a2)	; Hop !
vbl_end	movem.l	(sp)+,d0-a6	; Restore all registers
	move.l	VBLANK-4(pc),-(sp)	; Jump to normal VBLANK routine
	rts			; using XBRA field

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Resident datas for screen convertion.
VARS	dcb.b	__size,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here stands the mid-rez screen location...

;Main part of the program. Because it's here, we can save some bytes
;because this code will be killed (it's in the mid-rez screen location).
MAIN	lea	VARS(pc),a5	; 
	move.l	4(sp),a6		; Save the basepage address
	move.w	#4,-(sp)		;
	trap	#14		; Get screen resolution
	addq.l	#2,sp		;
	subq.w	#2,d0		; 
	blt.s	RunMEMU		; If resol>=2 (mono or TT-VGA)
	pea	Rez_error(pc)	; then break..
	move.w	#9,-(sp)		;
	trap	#1		;
	clr.w	(sp)		;
	trap	#1		; 

RunMEMU	clr.l	-(sp)		;
	move.w	#$20,-(sp)		;
	trap	#1		; Enter supervisor mode
	addq.l	#6,sp
	move.l	d0,SystemSSP	; Save the old supervisor stack

	movea.l	$70.w,a0		; Look for the XBRA "MEMU"
	moveq	#-1,d0		; in the VBL list.
Next_Xbra	cmpi.l	#"XBRA",-12(a0)	;
	bne.s	Next_Vect		;
	cmpi.l	#"MEMU",-8(a0)	; Is MEMU here ?
	beq.s	abort_prg		; yes,must quit
	move.l	-4(a0),a0		; next vector
	bra.s	Next_Xbra		;

Next_Vect	tst.w	d0		; Test done with Trap 14 ?
	beq.s	Ok		; yes, so it's really ok.
	movea.l	$b8.w,a0		;
	moveq	#0,d0		;
	bra.s	Next_Xbra		; Now, look for Trap 14

Ok	movea.l	a7,a0		; save current ssp
	movea.l	$8.w,a1		; save old vector
	move.l	#no_blitter,$8.w	; The new one !
	tst.w	BLIT_base.w	; Try to access blitter
	bra.s	blitter_is_here	; yes it is. 
no_blitter	move.l	a1,$8.w		; bus error,there's no blitter.
	movea.l	a0,a7		;
	pea	Blit_error(pc)	; Print "Schmuckhead !"
	move.w	#9,-(sp)		;
	trap	#1		;
	move.w	#7,(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
abort_prg	pea	Cls(pc)		;
	move.w	#9,-(sp)		;
	trap	#1		;
	move.l	SystemSSP(pc),(sp)	;
	move.w	#$20,-(sp)		;back to user mode
	trap	#1		;
	clr.w	(sp)		;abort prg.
	trap	#1		;

blitter_is_here
	move.l	a1,$8.w		; restore old vector
	pea	Present(pc)          	; What is it ?
	move.w	#9,-(sp)		; Print startup message
	trap	#1		;
	addq.l	#6,sp		;
GetSpeed	pea	SelectSpeed(pc)	;
	move.w	#9,-(sp)		; Print input message
	trap	#1		;
	move.w	#1,(sp)		;
NextKey	trap	#1		; Waiting for keyboard
	cmpi.w	#$1B,d0		; ESC pressed ?
	beq.s	abort_prg		; yes
	tst.w	d0		;
	beq.s	NextKey		; not an ASCII caract.
	cmpi.b	#"-",d0		; Old algorithm ?
	bne.s	*+8		; No
	bsr	CopyOldCode	; Yes, replace the code
	bra.s	NextKey		;
	addq.l	#6,sp		;
	sub.w	#"0",d0		; Convert ASCII to 0..9
	bmi.s	GetSpeed		;
	cmp.w	#10,d0		;
	bge.s	GetSpeed		;
	add.w	d0,d0		; D0=0,2,4,6,..,18
	bne.s	*+4		; But '0'=100/5=20
	moveq	#20,d0		;
	move.w	D0,MonoLines(a5)	;=>number of lines per VBL

GetPal	pea	SelectColors(pc)	;Select colours
	move.w	#9,-(sp)		;
	trap	#1		;
	move.w	#1,(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	moveq	#0,d1		;
	subi.w	#"1",d0		;
	bmi.s	SetPal		;
	cmpi.w	#2,d0		;
	bgt.s	SetPal		;
	move.w	d0,d1		;
SetPal	mulu	#6,d1		;
	lea	Pal_Buf(pc),a0	;
	adda.w	d1,a0		;
	lea	Palette(pc),a1	;
	move.l	(a0)+,(a1)+	;
	move.w	(a0)+,(a1)+	;

	move.l	_v_bas_ad.w,Mono(a5)	; Set "virtualy physic" screen
	move.l	$B8.w,XBIOS-4	; Get the old XBIOS address and
	move.l	$70.w,VBLANK-4	; VBLANK and insert into new versions
	clr.w	MonoPos(a5)	; Set offset to top of screen
	lea	MAIN+256(pc),a2	; A2 = start of free memory
	move.l	a2,d0		; Force it to a 256 byte boundry
	clr.b	d0		;
	move.l	d0,Med(a5)		; Set Med

	move.l	d0,d1		;
	move.b	d1,v_base_l.w	; Now, it's the definitive
	lsr.w	#8,d1		; physical screen (real physic)
	move.l	d1,$ffff8200.w	;

	sub.l	a6,d0		; Calculating memory used..
	move.l	d0,a6		; =screen end-code start
	lea	32000(a6),a6	; result in A6

	moveq	#-1,d0		;
	move.w	#2,-(sp)		; Hardware and Software to Mono
	move.l	d0,-(sp)		;
	move.l	d0,-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14		; Set high resolution
	lea	12(sp),sp		;
	move.l	#SingleVBL,$70.w	; Dummy VBL to avoid reset...
	move.w	#1,Vsync		; Set raster flag to 'not occured yet'

WaitSync	tst.w	Vsync		; If still not occured
	bne.s	WaitSync		; then loop until a vbl does occur
	move.b	#1,v_resol.w	; Back to medium hardware after VBL 
	bra	LastWill		; Install everything
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is a simple Vblank routine that just clears a flag 
SingleVBL
	clr.w	Vsync		; Indicate a Vertical blank has occured
	rte			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copy the old algortihm at the right place.
CopyOldCode
	movem.l	a0-a2,-(sp)	; Copy from high to low.
	lea	vbl_5+4(pc),a0	; Start from "dbf" in the
	lea	vbl_8+4(pc),a1	; source and destination
	lea	vbl_2(pc),a2	; code (4 bytes for dbf)
.bcl	move.w	-(a0),-(a1)	;
	cmpa.l	a0,a2		;
	bne.s	.bcl		;
	movem.l	(sp)+,a0-a2	;
	rts
;This is the old algorithm. It's 16 bytes shorter than the new one.
;So we can copy it directly.
vbl_2	moveq	#1,d2		; for DBF (2 planes)
vbl_3	move.l	a0,b_src_adr(a2)	; Next mono line
	move.l	a1,b_dst_adr(a2)	; Next mid-rez line
	move.l	#$20052,b_src_xinc(a2); On mono line
	move.l	#$40004,b_dst_xinc(a2); Two planes,every mid-rez line
	move.w	#$0203,b_hop(a2)	; Source only& No logical op
	move.l	#$280005,b_x_count(a2) ;Please transfert 40 words*5
	move.w	#$c000,b_ctrl(a2)	; HOG on and Blitter start

vbl_4	addq.l	#2,a1		; Now,the same but for the
	lea	80(a0),a0		; next mid-rez plane
	dbf	d2,vbl_3		;
	lea	10*80-160(a0),a0	; next mono lines
	lea	5*160-4(a1),a1	; next mid-rez lines
	addq.w	#5,d3		; +5 lines
	cmpi.w	#200,d3		; end of screen
	bne.s	vbl_5		; no
	moveq	#0,d3		; yes !
	lea	-32000(a0),a0	; restart addresses
	lea	-32000(a1),a1	;
vbl_5	dbf	d0,vbl_2		; next group of lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
;The three different palettes!. Change them if you think they're ugly,
;but please choose an odd Blue component (1,3,5,...,D,F) for the last
;one...
Pal_Buf	dc.w	$ccc,$ccc,$FFF
	dc.w	$354,$354,$DF7
	dc.w	$35d,$35d,$6FF
;

Present	dc.b	27,'E'
	DCB.B	40,$ed
	dc.b	13,10
	dc.b	$ed,'        ',27,'pThe Mono Emulator V6.0',27,'q        ',$ed,13,10
	dc.b	$ed,'--------------------------------------',$ed,13,10
	dc.b	$ed,'Feel free to give away copies of this,',$ed,13,10
	dc.b	$ed,'but please copy the whole folder.     ',$ed,13,10
	dc.b	$ed,'                                      ',$ed,13,10
	dc.b	$ed,'Send Problems to:    Sylvain LANGLADE ',$ed,13,10
	dc.b	$ed,'                62bis rue de l''Oradou ',$ed,13,10
	dc.b	$ed,'               63000 Clermont Ferrand ',$ed,13,10
	dc.b	$ed,'                               FRANCE ',$ed,13,10
	dc.b	$ed,'--------------------------------------',$ed,13,10
	dc.b	$ed,'     (C)oderight NulloS//DNT 1992     ',$ed,13,10
	DCB.B	40,$ed
	dc.b	13,10,10,0

SelectSpeed
	dc.b	13,10
	dc.b	'Please enter speed (ESC=Abort)...',13,10
	dc.b	"['1'=10,'2'=20...'9'=90,'0'=100]..?:",0

SelectColors
	dc.b	13,10
	dc.b	'And now, the colours (Default=White)',13,10
	dc.b	"['1'=White, '2'=Green, '3'=Blue]..?:",0

Blit_error	dc.b	13,10,"The Mono Emulator V6.00 can't",13,10
	dc.b	"run without blitter !!!....",13,10,0

Rez_error	dc.b	13,10,"The Mono Emulator V6.00 needs ST-Low or",13,10
	dc.b	"ST-Mid resolution... Sorry !",13,10,0

Cls	dc.b	13,27,'E ',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
Vsync	ds.w	1