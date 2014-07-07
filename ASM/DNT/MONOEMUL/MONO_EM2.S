	OUTPUT	PRG

; The Auto Mono Emulator. V5.10 By Mick West & NulloS

; This Blitter version by NulloS from DNT-Crew
; With blitter,the speed is increased about 50%.It's not very impressive,
; but don't forget that the MC68000 is not so slow when you don't use
; binary shifts (sprites,for example).Code for blitter is written with
; small letters.
; Hey man,you think it's easy to control blitter with LineA using it in
; the same time ??
; You're so wrong...Two long days to find that $FF8A38 is a motherfucker !!
; I'm using the HOG bit because the blitter works two times faster,but it
; must be on a few number of lines (otherwise there's problems with ITs).

; Please note that colors and screen base are made for STE-shifters.
; But it runs correctly with old STF-shifter (the fourth bit of color
; register isn't used,and memory access to $FF820D has no effect).
; I did optimise the original code too (it's shorter now),and i add the
; XBRA compatibility.Name used for XBRA is MEMU
; So this version 5.10,November 29th 1991
; Be seeing you !

	include	hard_sys.s		; My own hard/soft registers list..
MAIN	MOVE.L	4(A7),A6		; Save the basepage address
	MOVE.W	#4,-(SP)
	TRAP	#14		; Get screen Resolution
	ADDQ.L	#2,SP
	CMP.W	#2,D0		; If not high then carry on
	BNE.s	NOTHIGH        
	MOVE.L	(SP)+,D6		; else tidy up the stack
	MOVE.W	#0,-(SP)		; return ok to,GEM
	TRAP	#1		; Then exit back to desktop
NOTHIGH	CLR.L	-(SP)
	MOVE.W	#32,-(SP)
	TRAP	#1		; Enter supervisor mode
	ADDQ.L	#6,SP
	MOVE.L	D0,SAVESTACK	; Save the old supervisor stack

	movea.l	$70.w,a0		; Look for the XBRA "MEMU"
NEXBRA	cmpi.l	#"XBRA",-12(a0)	;
	bne.s	OK		;
	cmpi.l	#"MEMU",-8(a0)	; Is MEMU here ?
	beq.s	abort_prg		; yes,must quit
	move.l	-4(a0),a0		; next vector
	bra.s	NEXBRA

OK	movea.l	A7,A0		; save current SSP
	move.w	sr,d0		; save current IPL
	or.w	#$700,sr		; No interrupt allowed
	movea.l	$8.w,a1		; save old vector
	move.l	#no_blitter,$8.w	; The new one !
	tst.w	BLIT_base.w	; Try to access blitter
	bra.s	blitter_is_here	; yes it is. 
no_blitter	move.l	a1,$8.w		; bus error,there's no blitter.
	move.w	d0,sr		; restore old 68000 status
	movea.l	a0,a7
	pea	Blit_error(pc)
	move.w	#9,-(sp)
	trap	#1
	move.w	#7,(sp)
	trap	#1
	addq.l	#6,sp	
abort_prg	pea	Cls(pc)
	move.w	#9,-(sp)
	trap	#1
	move.l	SAVESTACK(pc),(sp)
	move.w	#$20,-(sp)		;back to user mode
	trap	#1
	clr.w	(sp)		;abort prg.
	trap	#1

blitter_is_here
	move.l	a1,$8.w		; restore old vector
	move.w	d0,sr		; and the IPL
	PEA	MESSAGE(PC)          	; Address of start of message
	MOVE.W	#9,-(SP)		; Print startup message
	TRAP	#1
	ADDQ.L	#6,SP
INLOOP	PEA	INPUT(PC)
	MOVE.W	#9,-(SP)		; Print input message
	TRAP	#1
	MOVE.W	#1,(SP)
NEXTKEY	TRAP	#1		; Waiting for keyboard
	CMPI.L	#$0001001B,d0	; ESC pressed ?
	beq.s	abort_prg		; yes
	TST.W	D0
	BEQ.S	NEXTKEY		; not an ASCII caract.
	ADDQ.L	#6,SP
	SUBI.W	#"0",D0		; A-J==>0-9
	BMI.S	INLOOP
	CMPI.W	#10,D0
	BGE.S	INLOOP
	ADD.W	D0,D0
	MOVE.W	SPEED(PC,D0.W),D0
	BRA.S	NEXTSTUFF

SPEED	DC.W	10/5,20/5,30/5,40/5,50/5
	DC.W	60/5,70/5,80/5,90/5,100/5	;Speeds allowed.

NEXTSTUFF
	MOVE.L	_v_bas_ad.W,MED	; Set MED
	MOVE.L	$B8.W,XBIOS-4	; Get the old XBIOS address and
	MOVE.L	$70.W,VBLANK-4	; VBLANK and insert into new versions
	MOVE.W	D0,MONOLINES	; number of lines per VBL
	CLR.W	MONOPOS		; Set offset to top of screen
	LEA	RASTER_FLAG(PC),A2
	MOVE.L	A2,D0		; A2 = start of free memory
	ADDI.L	#512,D0		; Force it to a 512 byte boundry
	ANDI.W	#$FE00,D0
	MOVE.L	D0,_v_bas_ad.W	; And that is the monochrome screen
	MOVE.L	D0,MONO		; Set MONO

	SUB.L	A6,D0		; Calculating memory used..
	MOVE.L	D0,A6		; screen end-code start=used mem
	LEA	32000(A6),A6	; result in A6

	MOVEQ	#-1,d0
	MOVE.W	#$0002,-(SP)	; Hardware and Software to Mono
	MOVE.L	d0,-(SP)
	MOVE.L	d0,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14		; Set high resolution
	LEA	12(SP),SP
	MOVE.L	#SIMPLE_VBLANK,$70.W	; set up my VBL
	MOVE.W	#1,RASTER_FLAG	; Set raster flag to 'not occured yet'

WAIT_RASTER
	TST.W	RASTER_FLAG	; If still not occured
	BNE.S	WAIT_RASTER	; then loop until a vbl does occur
	MOVE.B	#1,$FFFF8260.W	; Back to medium hardware after VBL 
	MOVE.L	#XBIOS,$B8.W	; Set up the new XBIOS vector
	MOVE.L	#VBLANK,$70.W	; And the new VBLANK vector
	MOVE.L	SAVESTACK(PC),-(SP)	; Restore the Supervisor stack
	MOVE.W	#32,-(SP)		; And go back to User mode
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.W	-(SP)		; Exit ok for GEM
	MOVE.L	A6,-(SP)		; Length of program + data space
	MOVE.W	#$31,-(SP)		; terminate and stay resident (TSR)
	TRAP	#1		; Finished this AUTO program




; This is the new XBIOS routine
	dc.b	'XBRA'		; XBRA specifications
	dc.b	'MEMU'		; great name isn't it ?
	dc.l	0		; old_vec
XBIOS	MOVEM.L	A1/A2,-(SP)	; Save A1 and A2
	MOVE.L	SP,A2		; A2 = the stack
	ADDQ.L	#8,A2		; offset over A1 and A2
	BTST	#5,(A2)		; Test if called from user mode
	BNE.s	NOTUSER		; Skip if it is
	MOVE.L	USP,A2		; Otherwise get A2 = User stack
	SUBQ.L	#6,A2		; Offset it as if it were the SSP
NOTUSER	MOVE.W	$6(A2),D0		; Get XBIOS instruction code
	CMP.W	#2,D0		; If it is _PHYSBASE 
	BEQ.s	PHYSBASE		; then jump to new PHYSBASE routine
	CMP.W	#4,D0		; If it is _GETREZ 
	BEQ.s	GETREZ		; then jump to new GETREZ routine
	CMP.W	#5,D0		; If it is NOT _SETSCREEN
	BNE.s	NORM_XBIOS		; Then continue with the normal XBIOS
	MOVE.W	#-1,16(A2)		; Else alter rez.W to -1 (No change)
	MOVE.L	12(A2),D0		; ploc.L parameter is <0 ?
	BMI.s	NORM_XBIOS		; then continue with normal XBIOS
	MOVE.L	D0,MONO		; Otherwise, new value goes to MONO
	MOVE.L	#-1,12(A2)		; Set ploc.L to -1 (no change)
NORM_XBIOS	MOVEM.L	(SP)+,A1/A2	; Tidy the stack up
	MOVE.L	XBIOS-4(pc),-(sp)	; And jump into the normal XBIOS
	RTS			; using the XBRA field
PHYSBASE	MOVE.L	MONO(PC),D0	; Get address of mono screen
EXBIOS	MOVEM.L	(SP)+,A1/A2	; Tidy stack
	RTE			; Return mono screen location
GETREZ	MOVEQ	#2,D0		; Pretend we are in mono resolution
	BRA.s	EXBIOS




; This is the new VBLANK routine
	dc.b	'XBRA'		; XBRA specifications
	dc.b	'MEMU'		; WoooW,i love MEMU
	dc.l	0		; old_vec
VBLANK	MOVEM.L	D0-A6,-(SP)	; Save all registers
	MOVE.W	#$BBB,v_color1.w	; Set up colours, grey for thin lines
	MOVE.W	#$BBB,v_color2.w	; (1 vert mono pixel = 1 grey med pix)
	BTST	#0,v_color0.w	; Check inverted
	BEQ.s	INVERT		; Jump if so
	MOVE.W	#$FFF,v_color0.w	; White background (normal)
	CLR.W	v_color3.w		; Black ink
	BRA.S	NOINVERT
INVERT	CLR.W	v_color0.w		; Black background (inverted)
	MOVE.W	#$FFF,v_color3.w	; White ink
NOINVERT	MOVEQ.L	#0,D0                 
	MOVE.B	v_base_h.W,D0	; Video base high
	LSL.L	#8,D0		; times 256
	MOVE.B	v_base_m.W,D0
	LSL.L	#8,D0		; All times 256
	MOVE.B	v_base_l.W,D0	; Don't forget low byte for STE!
	MOVEA.L	MONO(pc),A0	; A0 = virtual mono screen
	MOVEA.L	MED(pc),A1		; A1 = real medium screen
	CMP.L	A1,D0		; Check if the real screen has moved
	BEQ.s	MEDOK		; Skip this if not
	MOVE.L	D0,MONO		; Set MONO From rea screen address
	MOVE.L	A1,D0		; And put the real screen back 
	MOVE.B	d0,v_base_l.w
	LSR.L	#8,D0		; to its origional position
	MOVE.B	D0,v_base_m.w
	LSR.L	#8,D0
	MOVE.B	D0,v_base_h.w

MEDOK:	MOVE.W	MONOPOS(pc),D2	; Get position in the screen RAM
	MOVE.W	D2,D3		; D3 is used later...
	MULU.W	#160,D2		; Address offset
	ADDA.L	D2,A0		; Offset position in mono screen
	ADDA.L	D2,A1		; Offset pos in real medium screen
	MOVE.W	MONOLINES(pc),D0	; get preset speed
	TST.W	flock.w		; Test flock system variable
	BEQ	COPYMOVE		; Ok
	lsr.w	#1,d0		; half speed
COPYMOVE	lea	BLIT_base.w,a2	; Blitter registers
	move.w	b_y_count(a2),d4	; Y_count for fun
	tst.b	b_ctrl(a2)		; Is blitter active ?
	bpl.s	vbl_0		; no,skip this
	moveq	#0,d4
wait_blit	tas	b_ctrl(a2)		; Wait end of its work
	bmi.s	wait_blit
vbl_0	movem.l	b_src_xinc(a2),d5-7/a3-5 ;Save all registers
	move.l	b_hop(a2),a6	;
	moveq	#-1,d1		; Prepare mask
	move.l	d1,b_mask1(a2)	;
	move.w	d1,b_mask3(a2)	;
	bra.s	vbl_4

vbl_2	moveq	#1,d2		; for DBF (2 planes)
vbl_3	move.l	a0,b_src_adr(a2)	; Next mono line
	move.l	a1,b_dst_adr(a2)	; Next mid-rez line
	move.l	#$20052,b_src_xinc(a2); On mono line
	move.l	#$40004,b_dst_xinc(a2); Two planes,every mid-rez line
	move.w	#$0203,b_hop(a2)	; Source only& No logical op
	move.l	#$280005,b_x_count(a2) ;Please transfert 40 words*5
	move.w	#$C000,b_ctrl(a2)	; HOG on and Blitter start
	addq.l	#2,a1		; Now,the same but for the
	lea	80(a0),a0		; next mid-rez plane
	dbf	d2,vbl_3
	lea	4*160(a0),a0	; next mono lines
	lea	5*160-4(a1),a1	; next mid-rez lines
	addq.w	#5,d3		; +5 lines
	cmpi.w	#200,d3		; end of screen
	bne.s	vbl_4		; no
	moveq	#0,d3		; yes !
	lea	-32000(a0),a0	; restart addresses
	lea	-32000(a1),a1
vbl_4	dbf	d0,vbl_2		; next group of lines
	move.w	d3,MONOPOS		; save position
	movem.l	d5-7/a3-5,b_src_xinc(a2) ;Restore all registers,except
	move.l	a6,b_hop(a2)	; the y_count one
	tst.w	d4		; y_count must be restored ?
	beq.s	VBLEXIT		; No,skip this
	move.w	d4,b_y_count(a2)	; Hop !
VBLEXIT	MOVEM.L	(SP)+,D0-A6	; Restore all registers
	MOVE.L	VBLANK-4(pc),-(sp)	; Jump to normal VBLANK routine
	RTS			; using XBRA field


; This is a simple Vblank routine that just clears a flag 
SIMPLE_VBLANK
	CLR.W	RASTER_FLAG	; Indicate a Vertical blank has occured
	RTE





	EVEN
SAVESTACK:	DC.L	0
MONO:	DC.L	0		; Base address of mono screen
MED:	DC.L	0		; Base address of medium screen
MONOPOS:	DC.W	0		; Offset in both screens in bytes
MONOLINES: DC.L	0		; Pairs of mono lines to do per VBLANK 
RASTER_FLAG:  DC.W	0		; Flag cleared every raster (tempory)
MESSAGE:
 DC.B 27,'E',27,'pThe Mono Emulator',27,'q - Mick West 1988',13,10
 DC.B 9,9,'    NulloS    1991',13,10
 DC.B 'V5.10. Should be in AUTO Folder',13,10
 DC.B 'Will run with any TOS',13,10,10
 DC.B 'This is Freeware',13,10
 DC.B 'Send Problems to:',13,10
 DC.B 'Sylvain LANGLADE [NulloS]',13,10
 DC.B '62bis rue de l''Oradou',13,10
 DC.B '63000 Clermont Ferrand',13,10
 DC.B 'FRANCE',13,10,10
 DC.B 'Feel free to give away copies of this',13,10
 DC.B 'But please copy the whole folder',13,10,10
 DC.B 'This Blitter Version by NulloS//DNT 1991',13,10
 DC.B '(Send me money ... if you want !!)',13,10,10,0
INPUT:
 DC.B 13,10
 DC.B 'Please enter speed (ESC=Abort)...',13,10
 DC.B "['1'=10,'2'=20,...,'9'=90,'0'=100] : ?..",0
Blit_error:
 DC.B "This Blitter version of MONO_EMUL",10,13
 DC.B "can't run without blitter !!!!!!!",$0
Cls
 DC.B 13,27,'E ',0
